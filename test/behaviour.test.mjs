// Behaviour tests: the template's tags run in a fake page together with the real Clikgate scripts (the web script and
// the App banners loader, as served). Run inside the Clikgate repository, where the served scripts live; elsewhere
// the tests are skipped.
//
//   node test/behaviour.test.mjs
import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import vm from "node:vm";
import { createEnvironment, loadTemplate, root, runTemplate, say } from "./harness.mjs";

const SERVED = join(root, "..", "..", "src", "static");
const SCRIPTS = {
  // CLIKGATE_WEB_SCRIPT / CLIKGATE_APP_BANNERS: test another build (for example the readable source)
  "https://sdk.clikgate.com/v1/static/clikgate.js": process.env.CLIKGATE_WEB_SCRIPT || join(SERVED, "clikgate.js"),
  "https://api.clikgate.com/v1/static/app-banners.js": process.env.CLIKGATE_APP_BANNERS || join(SERVED, "app-banners.js"),
};
const CLICK = "clk_01JAB0CDEFGHJKMNPQRSTVWXYZ";
const IPHONE = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148 Safari/604.1";
const JRN = "jrn_01JAB0CDEFGHJKMNPQRSTVWXYZ";

if (!Object.values(SCRIPTS).every(existsSync)) {
  say("skipped: the served Clikgate scripts aren't in this checkout");
  process.exit(0);
}
const template = loadTemplate();

class Element {
  constructor(tag) {
    this.tagName = tag.toUpperCase();
    this.children = [];
    this.attributes = {};
    this.listeners = {};
    this.style = { setProperty() {} };
    this.textContent = "";
    this.className = "";
  }
  setAttribute(k, v) { this.attributes[k] = String(v); }
  getAttribute(k) { return this.attributes[k] ?? null; }
  appendChild(c) { c.parentNode = this; this.children.push(c); return c; }
  removeChild(c) { this.children = this.children.filter((x) => x !== c); }
  addEventListener(t, f) { (this.listeners[t] ||= []).push(f); }
  attachShadow() { this.shadowRoot = new Element("#shadow"); return this.shadowRoot; }
  focus() {}
  all() { return [this, ...[...this.children, ...(this.shadowRoot ? [this.shadowRoot] : [])].flatMap((c) => c.all())]; }
}

// A page with a cookie jar, localStorage, a recording fetch and a GTM container (the template's environment)
function page({ search = "", pathname = "/", consent = {}, banners = [] } = {}) {
  const cookies = new Map();
  const storage = new Map();
  const requests = [];
  const document = {
    currentScript: null,
    createElement: (t) => new Element(t),
    querySelector: () => null,
    querySelectorAll: () => [],
    getElementById: () => null,
    get cookie() { return [...cookies].map(([k, v]) => `${k}=${v}`).join("; "); },
    set cookie(v) {
      const [pair, ...attrs] = v.split("; ");
      const [k, val] = pair.split("=");
      if (attrs.includes("max-age=0")) cookies.delete(k); else cookies.set(k, val);
    },
  };
  document.body = new Element("body");
  document.documentElement = document.body;
  const window = {
    document,
    location: { search, pathname, protocol: "https:", href: `https://shop.example.com${pathname}${search}`, origin: "https://shop.example.com" },
    navigator: { userAgent: IPHONE, maxTouchPoints: 5 },
    localStorage: { getItem: (k) => storage.get(k) ?? null, setItem: (k, v) => storage.set(k, String(v)), removeItem: (k) => storage.delete(k) },
    console: { warn() {}, info() {}, error() {} },
    addEventListener() {},
    setTimeout: (f) => { Promise.resolve().then(f); return 1; },
    clearTimeout() {},
    fetch(url, init = {}) {
      requests.push({ url: String(url), init });
      const body = String(url).includes("/v1/public/app-banners?")
        ? { app_banners: banners, country: null }
        : String(url).includes("/v1/web/config") ? { click_id_param: "cgid", allow_labels: false } : { status: "waiting", counted: false };
      return Promise.resolve({ ok: true, status: String(url).includes("/v1/web/goals") ? 202 : 200, json: () => Promise.resolve(body) });
    },
    URLSearchParams, URL, JSON, Date, Math, Promise, parseFloat, encodeURIComponent, decodeURIComponent,
  };
  window.window = window;
  vm.createContext(window);
  const inject = (url) => {
    const file = SCRIPTS[url];
    if (!file) return false;
    const element = { src: url, getAttribute: () => null };
    document.currentScript = element;
    vm.runInContext(readFileSync(file, "utf8"), window, { filename: url });
    document.currentScript = null;
    return true;
  };
  const env = createEnvironment({ permissions: template.permissions, window, consent, inject });
  return {
    window, cookies, storage, requests, env,
    tag: (data) => runTemplate(template, env, data),
    goals: () => requests.filter((r) => r.url.endsWith("/v1/web/goals")).map((r) => JSON.parse(r.init.body)),
  };
}

const settle = () => new Promise((resolve) => setImmediate(resolve));
const BASE = { tagType: "base", webKey: "cgw_live_abc123", clickIdParam: "cgid", days: "30", consentMode: "gcm" };
const GOAL = { tagType: "goal", goalKey: "signup", consentMode: "gcm" };
const PAYMENT = { tagType: "payment", paymentGoalKey: "order_paid", provider: "paystack", paymentReference: "T123456", consentMode: "gcm" };
const BANNERS = { tagType: "app_banners", siteKey: "cg_site_live_abc123", consentMode: "none" };
const BANNER = {
  id: JRN, type: "smart_banner", cta_url: `https://ciz.to/menu?jrn=${JRN}`, deep_link_from_page: false,
  content: { title: "Order faster in the app", cta_text: "Open" }, targeting: { platforms: ["ios", "android"] }, display: {},
};

const tests = [];
const test = (name, fn) => tests.push([name, fn]);
const assert = (ok, message) => { if (!ok) throw new Error(message); };

test("a goal tag that fires before the base script is queued, then sent by the script with source gtm", async () => {
  const p = page();
  p.tag(GOAL);
  assert(Array.isArray(p.window.clikgateQueue) && p.window.clikgateQueue.length === 1, "the goal wasn't queued");
  p.tag(BASE);
  await settle();
  const sent = p.goals();
  assert(sent.length === 1, `expected 1 goal sent, got ${sent.length}`);
  assert(sent[0].goal === "signup" && sent[0].source === "gtm" && sent[0].web_key === "cgw_live_abc123", `goal body: ${JSON.stringify(sent[0])}`);
  assert(p.window.clikgateQueue.length === 0, "the queue wasn't emptied");
});

test("after the script loaded, goal tags call Clikgate.goal directly", async () => {
  const p = page();
  p.tag(BASE);
  await settle();
  p.tag(GOAL);
  await settle();
  const sent = p.goals();
  assert(sent.length === 1 && sent[0].source === "gtm", `goal body: ${JSON.stringify(sent)}`);
});

test("the click ID from a Clikgate link is kept in the _cg_ cookie and sent with goals", async () => {
  const p = page({ search: `?cgid=${CLICK}` });
  p.tag(BASE);
  await settle();
  assert(p.cookies.get("_cg_cgid") === CLICK, "the click ID cookie wasn't set");
  p.tag(GOAL);
  await settle();
  assert(p.goals()[0].click_id === CLICK, "the goal didn't carry the click ID");
});

test("analytics_storage denied: no cookie, and the goal is sent without a click ID", async () => {
  const p = page({ search: `?cgid=${CLICK}`, consent: { analytics_storage: "denied" } });
  p.tag(BASE);
  await settle();
  assert(!p.cookies.has("_cg_cgid"), "a cookie was set without consent");
  p.tag(GOAL);
  await settle();
  const sent = p.goals();
  assert(sent.length === 1, "the goal wasn't sent (it should be counted, not attributed)");
  assert(!("click_id" in sent[0]), "the goal carried a click ID without consent");
  assert(sent[0].consent && sent[0].consent.attribution === "denied", "consent wasn't sent");
});

test("consent granted later is passed to the script, which then keeps the click ID", async () => {
  const p = page({ search: `?cgid=${CLICK}`, consent: { analytics_storage: "denied" } });
  p.tag(BASE);
  await settle();
  p.env.setConsent("analytics_storage", "granted");
  await settle();
  assert(p.cookies.get("_cg_cgid") === CLICK, "the click ID wasn't kept after consent");
});

test("the payment tag reports provider and reference only, with source gtm", async () => {
  const p = page();
  p.tag(BASE);
  p.tag(PAYMENT);
  await settle();
  const [sent] = p.goals();
  assert(sent && sent.goal === "order_paid" && sent.provider === "paystack" && sent.reference === "T123456", `payment body: ${JSON.stringify(sent)}`);
  assert(sent.source === "gtm" && !("value" in sent) && !("currency" in sent), "the report carried an amount or no source");
});

test("the base script counts as loaded with one config fetch (source gtm)", async () => {
  const p = page();
  p.tag(BASE);
  await settle();
  const fetches = p.requests.filter((r) => r.url.includes("/v1/web/config"));
  assert(fetches.length === 1 && fetches[0].url.includes("source=gtm"), `config fetches: ${fetches.map((r) => r.url)}`);
});

test("App banners: the loader reads the site key from the template's config", async () => {
  const p = page({ pathname: "/product/jollof-box" });
  p.tag(BANNERS);
  await settle();
  const config = p.requests.find((r) => r.url.includes("/v1/public/app-banners?"));
  assert(config && config.url.includes("site_key=cg_site_live_abc123"), "the loader didn't fetch the site's banners");
});

test("App banners: no banner on a checkout page", async () => {
  const p = page({ pathname: "/thank-you", banners: [BANNER] });
  p.tag({ ...BANNERS, pageType: "checkout" });
  await settle();
  await settle();
  const shown = p.window.document.body.all().some((e) => e.getAttribute && e.getAttribute("data-clikgate-app-banner"));
  assert(!shown, "a banner was shown on checkout");
});

test("App banners: on a product page the banner's link carries the product", async () => {
  const p = page({ pathname: "/product/jollof-box", banners: [BANNER] });
  p.tag({ ...BANNERS, pageType: "product", productId: "42", sku: "JOL-BOX", productSlug: "jollof-box" });
  await settle();
  await settle();
  const link = p.window.document.body.all().find((e) => e.tagName === "A");
  assert(link, "no banner was shown on the product page");
  const href = decodeURIComponent(link.getAttribute("href"));
  assert(href.includes("cg_page=/product/jollof-box") && href.includes("wc_product_id=42"), `CTA: ${href}`);
});

let failed = 0;
for (const [name, fn] of tests) {
  try {
    await fn();
    say(`ok - ${name}`);
  } catch (e) {
    failed++;
    console.error(`not ok - ${name}\n    ${e.message}`);
  }
}
say(`${tests.length} behaviour tests, ${failed} failed`);
process.exit(failed ? 1 : 0);
