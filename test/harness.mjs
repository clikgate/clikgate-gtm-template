// Runs template.tpl's own tests (the ___TESTS___ scenarios) in node, against mocked Google Tag Manager APIs that
// follow Google's documented behaviour, and checks the template's structure for the Community Template Gallery.
//
//   node test/harness.mjs
//
// Unlike Google's runner, every API call is checked against ___WEB_PERMISSIONS___ (also for mocked APIs): a call
// with no matching permission, an injected URL that isn't listed or a global key without the right access fails.
// The same mocked environment is exported for test/behaviour.test.mjs, which loads the real scripts.
import { readFileSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import vm from "node:vm";

const here = dirname(fileURLToPath(import.meta.url));
export const root = join(here, "..");

// TEMPLATE FILE

export function sections(text) {
  const out = {};
  let name = null;
  for (const line of text.replace(/^﻿/, "").split("\n")) {
    const m = /^___([A-Z_]+)___$/.exec(line.trim());
    if (m) {
      name = m[1];
      out[name] = [];
    } else if (name) {
      out[name].push(line);
    }
  }
  for (const k of Object.keys(out)) out[k] = out[k].join("\n").trim();
  return out;
}

// The ___TESTS___ YAML as the template editor writes it: `scenarios:` items with `name` and a `code: |-` block, and
// an optional `setup: |-` block (block scalars only, which is all this template uses)
export function parseTests(yaml) {
  const lines = yaml.split("\n");
  const scenarios = [];
  let setup = "";
  const blockAt = (start, indent) => {
    const body = [];
    let i = start;
    for (; i < lines.length; i++) {
      const line = lines[i];
      if (line.trim() === "") { body.push(""); continue; }
      if (!line.startsWith(" ".repeat(indent))) break;
      body.push(line.slice(indent));
    }
    while (body.length && body[body.length - 1] === "") body.pop();
    return [body.join("\n"), i];
  };
  let i = 0;
  while (i < lines.length) {
    const line = lines[i];
    const name = /^- name: (.*)$/.exec(line);
    if (name) {
      if (!/^ {2}code: \|[-+]?$/.test(lines[i + 1] || "")) throw new Error(`scenario "${name[1]}": expected a code block`);
      const [code, next] = blockAt(i + 2, 4);
      scenarios.push({ name: name[1].trim(), code });
      i = next;
      continue;
    }
    if (/^setup: \|[-+]?$/.test(line)) {
      const [code, next] = blockAt(i + 1, 2);
      setup = code;
      i = next;
      continue;
    }
    i++;
  }
  return { scenarios, setup };
}

const value = (v) => {
  if (!v) return undefined;
  if (v.type === 1) return v.string;
  if (v.type === 8) return v.boolean;
  if (v.type === 2) return (v.listItem || []).map(value);
  if (v.type === 3) {
    const o = {};
    v.mapKey.forEach((k, idx) => { o[value(k)] = value(v.mapValue[idx]); });
    return o;
  }
  throw new Error(`unknown permission value type ${v.type}`);
};

export function parsePermissions(json) {
  const out = {};
  for (const p of JSON.parse(json)) {
    const params = {};
    for (const param of p.instance.param || []) params[param.key] = value(param.value);
    out[p.instance.key.publicId] = params;
  }
  return out;
}

export function loadTemplate(path = join(root, "template.tpl")) {
  const s = sections(readFileSync(path, "utf8"));
  return {
    sections: s,
    info: JSON.parse(s.INFO),
    parameters: JSON.parse(s.TEMPLATE_PARAMETERS),
    code: s.SANDBOXED_JS_FOR_WEB_TEMPLATE,
    permissions: parsePermissions(s.WEB_PERMISSIONS),
    tests: parseTests(s.TESTS || ""),
  };
}

// VALUES ACROSS THE SANDBOX BOUNDARY

const SANDBOX_TYPES = new Set(["undefined", "null", "boolean", "number", "string", "array", "object", "function"]);
export function getType(v) {
  if (v === null) return "null";
  if (Array.isArray(v)) return "array";
  return typeof v;
}
// Values are copied across (functions pass as callables); anything else (a Promise, a DOM node) becomes undefined
function cross(v, seen = new Set()) {
  const t = getType(v);
  if (t === "function" || t !== "object" && t !== "array") return SANDBOX_TYPES.has(t) ? v : undefined;
  if (seen.has(v)) return undefined;
  if (t === "object" && Object.getPrototypeOf(v) !== Object.prototype && Object.getPrototypeOf(v) !== null &&
      v.constructor && v.constructor.name !== "Object") return undefined;
  seen.add(v);
  if (t === "array") return v.map((x) => cross(x, seen));
  const o = {};
  for (const k of Object.keys(v)) o[k] = cross(v[k], seen);
  return o;
}

export function deepEqual(a, b) {
  if (a === b) return true;
  const ta = getType(a), tb = getType(b);
  if (ta !== tb || (ta !== "object" && ta !== "array")) return false;
  const ka = Object.keys(a), kb = Object.keys(b);
  if (ka.length !== kb.length) return false;
  return ka.every((k) => Object.prototype.hasOwnProperty.call(b, k) && deepEqual(a[k], b[k]));
}

// URL match patterns: exact, or `*` as a wildcard (the template lists exact URLs)
const urlAllowed = (patterns, url) =>
  (patterns || []).some((p) => new RegExp("^" + p.split("*").map((x) => x.replace(/[.+?^${}()|[\]\\/]/g, "\\$&")).join(".*") + "$").test(url));

export class PermissionError extends Error {}

// Test output (stdout)
export const say = (line) => { process.stdout.write(`${line}\n`); };

// THE MOCKED GTM ENVIRONMENT

export function createEnvironment({ permissions, window = {}, consent = {}, inject = null } = {}) {
  const calls = {};
  const mocks = {};
  const later = [];
  const storage = new Map();
  const listeners = [];
  const tokens = new Map();
  const logs = [];
  const record = (name, args) => { (calls[name] = calls[name] || []).push(args); };
  const deny = (message) => { throw new PermissionError(`permission: ${message}`); };
  const globalAccess = (key, need) => {
    const keys = (permissions.access_globals || {}).keys || [];
    const entry = keys.find((k) => k.key === key);
    if (!entry || need.some((n) => !entry[n])) deny(`access_globals ${need.join("+")} on ${key} is not granted`);
  };
  const consentRead = (type) => {
    const types = (permissions.access_consent || {}).consentTypes || [];
    if (!types.some((t) => t.consentType === type && t.read)) deny(`access_consent read on ${type} is not granted`);
  };
  const path = (key) => key.split(".");
  const read = (key) => path(key).reduce((o, k) => (o == null ? undefined : o[k]), window);
  const write = (key, v) => {
    const parts = path(key);
    let o = window;
    for (const k of parts.slice(0, -1)) {
      if (o[k] == null) throw new Error(`setInWindow: the parent of ${key} doesn't exist`);
      o = o[k];
    }
    o[parts[parts.length - 1]] = v;
  };

  const real = {
    setInWindow(key, v, overrideExisting) {
      globalAccess(key, ["write"]);
      if (read(key) !== undefined && !overrideExisting) return false;
      write(key, cross(v));
      return true;
    },
    copyFromWindow(key) {
      globalAccess(key, ["read"]);
      return cross(read(key));
    },
    createQueue(key) {
      globalAccess(key, ["read", "write"]);
      if (read(key) === undefined) write(key, []);
      const queue = read(key);
      // Through the array's own push (the dataLayer pattern), so a script that replaced push sees every item
      return (...items) => { queue.push(...items.map((x) => cross(x))); };
    },
    callInWindow(key, ...args) {
      globalAccess(key, ["execute"]);
      const parts = path(key);
      const owner = parts.length > 1 ? read(parts.slice(0, -1).join(".")) : window;
      const fn = owner == null ? undefined : owner[parts[parts.length - 1]];
      if (typeof fn !== "function") return undefined;
      return cross(fn.apply(owner, args.map((x) => cross(x))));
    },
    injectScript(url, onSuccess, onFailure, cacheToken) {
      if (!urlAllowed((permissions.inject_script || {}).urls, url)) deny(`inject_script does not allow ${url}`);
      const done = (ok) => later.push(() => { const cb = ok ? onSuccess : onFailure; if (typeof cb === "function") cb(); });
      if (cacheToken && tokens.has(cacheToken)) {
        const t = tokens.get(cacheToken);
        if (t.done) done(t.ok); else t.waiting.push(done);
        return;
      }
      const t = { done: false, ok: false, waiting: [done] };
      if (cacheToken) tokens.set(cacheToken, t);
      later.push(() => {
        t.ok = inject ? inject(url) !== false : true;
        t.done = true;
        for (const w of t.waiting) w(t.ok);
      });
    },
    isConsentGranted(type) {
      consentRead(type);
      return consent[type] === undefined || consent[type] === "granted";
    },
    addConsentListener(type, listener) {
      consentRead(type);
      listeners.push({ type, listener });
    },
    logToConsole(...args) {
      if (permissions.logging) logs.push(args.map(String).join(" "));
    },
    getType,
    makeString: (v) => String(v),
    makeNumber: (v) => Number(v),
    makeInteger: (v) => Math.trunc(Number(v)),
    encodeUriComponent: (v) => { try { return encodeURIComponent(v); } catch { return undefined; } },
    callLater(fn) { later.push(fn); },
    queryPermission() { return true; },
    // Present so a call is caught: none of these permissions is granted
    getCookieValues() { deny("get_cookies is not granted"); },
    setCookie() { deny("set_cookies is not granted"); },
    sendPixel() { deny("send_pixel is not granted"); },
    injectHiddenIframe() { deny("inject_hidden_iframe is not granted"); },
    copyFromDataLayer() { deny("read_data_layer is not granted"); },
    localStorage: { getItem() { deny("access_local_storage is not granted"); }, setItem() { deny("access_local_storage is not granted"); } },
  };
  real.templateStorage = {
    getItem: (k) => storage.get(k),
    setItem: (k, v) => { storage.set(k, v); },
    removeItem: (k) => { storage.delete(k); },
    clear: () => { storage.clear(); },
  };

  const checks = {
    setInWindow: (key) => globalAccess(key, ["write"]),
    copyFromWindow: (key) => globalAccess(key, ["read"]),
    createQueue: (key) => globalAccess(key, ["read", "write"]),
    callInWindow: (key) => globalAccess(key, ["execute"]),
    injectScript: (url) => { if (!urlAllowed((permissions.inject_script || {}).urls, url)) deny(`inject_script does not allow ${url}`); },
    isConsentGranted: (type) => consentRead(type),
    addConsentListener: (type) => consentRead(type),
    templateStorage: () => { if (!("access_template_storage" in permissions)) deny("access_template_storage is not granted"); },
    getCookieValues: () => deny("get_cookies is not granted"),
    setCookie: () => deny("set_cookies is not granted"),
    sendPixel: () => deny("send_pixel is not granted"),
  };

  const api = (name) => {
    if (name === "templateStorage") {
      checks.templateStorage();
      const target = mocks.templateStorage || real.templateStorage;
      const wrapped = {};
      for (const m of Object.keys(real.templateStorage)) {
        wrapped[m] = (...args) => { record(`templateStorage.${m}`, args); return target[m] ? target[m](...args) : undefined; };
      }
      return wrapped;
    }
    if (!(name in real)) throw new Error(`require('${name}'): unknown API`);
    if (typeof real[name] !== "function") return real[name];
    return (...args) => {
      record(name, args);
      if (name in mocks) {
        if (checks[name]) checks[name](...args);
        const m = mocks[name];
        return typeof m === "function" ? m(...args) : m;
      }
      return real[name](...args);
    };
  };

  const flush = () => {
    for (let n = 0; later.length && n < 1000; n++) later.shift()();
  };

  return {
    calls, mocks, logs, window, consent, storage,
    require: api,
    flush,
    setConsent(type, state) {
      const before = consent[type] === undefined || consent[type] === "granted";
      consent[type] = state;
      const after = state === "granted";
      if (before !== after || (consent[type] !== undefined && state === "denied")) {
        for (const l of listeners) if (l.type === type) l.listener(type, after);
      }
      flush();
    },
  };
}

// Static checks of the sandboxed code (the sandbox has no `new`, `this` or global constructors; regular expressions
// and try/catch aren't documented, so the template doesn't use them)
export function checkSandboxedCode(code) {
  const problems = [];
  const stripped = code.replace(/'(?:[^'\\]|\\.)*'/g, "''").replace(/\/\/.*$/gm, "");
  const rules = [
    [/\bnew\s/, "uses new"],
    [/\bthis\b/, "uses this"],
    [/\btry\s*\{/, "uses try/catch"],
    [/\bRegExp\b/, "uses RegExp"],
    [/[=(,:]\s*\/[^/*\s]/, "uses a regular expression literal"],
    [/\b(window|document|JSON|Math|Object|Date|Number|String|Array|Promise|setTimeout)\s*[.(]/, "uses a browser or JavaScript global"],
    [/`/, "uses a template literal"],
  ];
  for (const [re, what] of rules) if (re.test(stripped)) problems.push(what);
  return problems;
}

export function compile(code) {
  return new vm.Script(`(function (require, data) {\n${code}\n})`, { filename: "template.tpl (sandboxed code)" });
}

// Runs the template once with `data` in `env`; the callbacks the template schedules run after it returns
export function runTemplate(template, env, data) {
  const fn = compile(template.code).runInNewContext({});
  const d = { ...data };
  for (const cb of ["gtmOnSuccess", "gtmOnFailure"]) {
    const original = d[cb];
    d[cb] = (...args) => { (env.calls[cb] = env.calls[cb] || []).push(args); if (typeof original === "function") original(...args); };
  }
  fn(env.require, d);
  env.flush();
}

// THE TEMPLATE'S OWN SCENARIOS

function assertThat(subject, message) {
  const fail = (what) => { throw new Error(`${message ? message + ": " : ""}expected ${JSON.stringify(subject)} ${what}`); };
  const m = {
    isEqualTo: (x) => { if (!deepEqual(subject, x)) fail(`to equal ${JSON.stringify(x)}`); },
    isNotEqualTo: (x) => { if (deepEqual(subject, x)) fail(`not to equal ${JSON.stringify(x)}`); },
    isStrictlyEqualTo: (x) => { if (subject !== x) fail(`to be ${JSON.stringify(x)}`); },
    isTrue: () => { if (subject !== true) fail("to be true"); },
    isFalse: () => { if (subject !== false) fail("to be false"); },
    isTruthy: () => { if (!subject) fail("to be truthy"); },
    isFalsy: () => { if (subject) fail("to be falsy"); },
    isUndefined: () => { if (subject !== undefined) fail("to be undefined"); },
    isDefined: () => { if (subject === undefined) fail("to be defined"); },
    isNull: () => { if (subject !== null) fail("to be null"); },
    isNotNull: () => { if (subject === null) fail("not to be null"); },
    contains: (...xs) => { for (const x of xs) if (!(typeof subject === "string" ? subject.includes(x) : subject.some((s) => deepEqual(s, x)))) fail(`to contain ${JSON.stringify(x)}`); },
    doesNotContain: (...xs) => { for (const x of xs) if (typeof subject === "string" ? subject.includes(x) : subject.some((s) => deepEqual(s, x))) fail(`not to contain ${JSON.stringify(x)}`); },
    containsExactly: (x) => { if (!deepEqual(subject, x)) fail(`to contain exactly ${JSON.stringify(x)}`); },
    hasLength: (n) => { if (!subject || subject.length !== n) fail(`to have length ${n}`); },
    isEmpty: () => { if (!subject || subject.length !== 0) fail("to be empty"); },
    isNotEmpty: () => { if (!subject || subject.length === 0) fail("not to be empty"); },
    isString: () => { if (typeof subject !== "string") fail("to be a string"); },
    isObject: () => { if (getType(subject) !== "object") fail("to be an object"); },
    isArray: () => { if (!Array.isArray(subject)) fail("to be an array"); },
    isFunction: () => { if (typeof subject !== "function") fail("to be a function"); },
  };
  return m;
}

export function runScenario(template, scenario, setup) {
  const env = createEnvironment({ permissions: template.permissions });
  const assertApi = (name) => {
    const list = () => env.calls[name] || [];
    const show = (args) => JSON.stringify(args);
    return {
      wasCalled: () => { if (!list().length) throw new Error(`expected ${name} to be called`); },
      wasNotCalled: () => { if (list().length) throw new Error(`expected ${name} not to be called, got ${list().map(show).join("; ")}`); },
      wasCalledWith: (...args) => {
        if (!list().some((c) => deepEqual(c.slice(0, args.length), args) && c.length >= args.length)) {
          throw new Error(`expected ${name} to be called with ${show(args)}, got ${list().map(show).join("; ") || "no calls"}`);
        }
      },
      wasNotCalledWith: (...args) => {
        if (list().some((c) => deepEqual(c.slice(0, args.length), args))) throw new Error(`expected ${name} not to be called with ${show(args)}`);
      },
    };
  };
  const context = {
    mock: (name, v) => { env.mocks[name] = v; },
    mockObject: (name, o) => { env.mocks[name] = o; },
    assertApi,
    assertThat,
    fail: (message) => { throw new Error(message || "failed"); },
    runCode: (data) => runTemplate(template, env, data),
    require: env.require,
  };
  vm.runInNewContext(`${setup}\n;\n${scenario.code}`, context, { filename: scenario.name });
}

// STRUCTURE CHECKS FOR THE GALLERY

const CATEGORIES = new Set(["ADVERTISING", "AFFILIATE_MARKETING", "ANALYTICS", "ATTRIBUTION", "CHAT", "CONVERSIONS",
  "DATA_WAREHOUSING", "EMAIL_MARKETING", "EXPERIMENTATION", "HEAT_MAP", "LEAD_GENERATION", "MARKETING",
  "PERSONALIZATION", "REMARKETING", "SALES", "SESSION_RECORDING", "SOCIAL", "SURVEY", "TAG_MANAGEMENT", "UTILITY"]);
const FORBIDDEN_PERMISSIONS = ["send_pixel", "send_beacon", "get_cookies", "set_cookies", "access_local_storage", "read_data_layer"];

export function structureProblems(template) {
  const p = [];
  const s = template.sections;
  for (const name of ["TERMS_OF_SERVICE", "INFO", "TEMPLATE_PARAMETERS", "SANDBOXED_JS_FOR_WEB_TEMPLATE", "WEB_PERMISSIONS", "TESTS"]) {
    if (!s[name]) p.push(`missing ___${name}___`);
  }
  const cats = template.info.categories || [];
  if (cats.length < 1 || cats.length > 3 || cats.some((c) => !CATEGORIES.has(c))) p.push(`categories must be 1-3 of the gallery list: ${cats}`);
  if (template.info.type !== "TAG" || !(template.info.containerContexts || []).includes("WEB")) p.push("must be a web TAG template");
  for (const f of FORBIDDEN_PERMISSIONS) if (f in template.permissions) p.push(`permission ${f} must not be requested`);
  const urls = (template.permissions.inject_script || {}).urls || [];
  if (!urls.every((u) => u.startsWith("https://"))) p.push("inject_script URLs must be https");
  const names = new Set(template.parameters.map((x) => x.name));
  const used = new Set([...template.code.matchAll(/\bdata\.([A-Za-z]+)/g)].map((m) => m[1]));
  for (const u of used) if (!names.has(u) && u !== "gtmOnSuccess" && u !== "gtmOnFailure") p.push(`code reads data.${u}, which is no field`);
  for (const m of template.code.matchAll(/require\('([^']+)'\)/g)) {
    try { createEnvironment({ permissions: template.permissions }).require(m[1]); } catch (e) {
      if (!(e instanceof PermissionError)) p.push(`unknown API ${m[1]}`);
    }
  }
  p.push(...checkSandboxedCode(template.code).map((x) => `sandboxed code ${x}`));
  // Inside the Clikgate repository the provider list must match the API's Provider enum
  const openapi = join(root, "..", "..", "docs", "openapi.json");
  if (existsSync(openapi)) {
    const enumValues = JSON.parse(readFileSync(openapi, "utf8")).components.schemas.Provider.enum;
    const listed = /const PROVIDERS = \[([^\]]*)\]/.exec(template.code);
    const codeValues = listed ? [...listed[1].matchAll(/'([a-z_]+)'/g)].map((m) => m[1]) : [];
    const select = (template.parameters.find((x) => x.name === "provider") || {}).selectItems || [];
    if (!deepEqual(codeValues, enumValues)) p.push("PROVIDERS in the code differ from the Provider enum");
    if (!deepEqual(select.map((x) => x.value), enumValues)) p.push("the provider field differs from the Provider enum");
  }
  for (const field of template.parameters) {
    if (/amount/i.test(field.name) || (field.name === "currency" && !(field.enablingConditions || []).every((c) => c.paramValue === "goal"))) {
      p.push(`field ${field.name}: payments never carry an amount`);
    }
  }
  return p;
}

export function filesProblems() {
  const p = [];
  const meta = existsSync(join(root, "metadata.yaml")) ? readFileSync(join(root, "metadata.yaml"), "utf8") : "";
  if (!/^homepage: "https:\/\//m.test(meta)) p.push("metadata.yaml: homepage");
  if (!/^documentation: "https:\/\//m.test(meta)) p.push("metadata.yaml: documentation");
  if (!/^versions:\n(\s+#.*\n)*\s+- sha: [0-9a-f]{40}\n\s+changeNotes: .+/m.test(meta)) p.push("metadata.yaml: versions with sha and changeNotes");
  const licence = existsSync(join(root, "LICENSE")) ? readFileSync(join(root, "LICENSE"), "utf8") : "";
  if (!licence.includes("Apache License") || !licence.includes("Version 2.0, January 2004") || !licence.includes("Copyright 2026 Clikgate")) {
    p.push("LICENSE: the Apache 2.0 text with the copyright line filled in");
  }
  return p;
}

// MAIN

if (process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1]) {
  const template = loadTemplate();
  let failed = 0;
  const problems = [...structureProblems(template), ...filesProblems()];
  for (const problem of problems) { console.error(`not ok - structure: ${problem}`); failed++; }
  if (!problems.length) say("ok - structure, permissions and gallery files");
  if (!template.tests.scenarios.length) { console.error("not ok - no scenarios"); failed++; }
  for (const scenario of template.tests.scenarios) {
    try {
      runScenario(template, scenario, template.tests.setup);
      say(`ok - ${scenario.name}`);
    } catch (e) {
      failed++;
      console.error(`not ok - ${scenario.name}\n    ${e.message}`);
    }
  }
  // The harness itself must catch a permission the template doesn't have
  try {
    const wider = { ...template, code: "require('setInWindow')('dataLayer', [], true); data.gtmOnSuccess();" };
    runScenario(wider, { name: "self-check", code: "runCode({});" }, "");
    console.error("not ok - harness: a write to an unlisted global was not caught");
    failed++;
  } catch (e) {
    if (e instanceof PermissionError || /permission/.test(e.message)) say("ok - harness catches calls without permission");
    else { console.error(`not ok - harness self-check: ${e.message}`); failed++; }
  }
  say(`${template.tests.scenarios.length} scenarios, ${failed} failed`);
  process.exit(failed ? 1 : 0);
}
