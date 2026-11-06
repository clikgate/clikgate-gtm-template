___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Clikgate",
  "categories": [
    "ATTRIBUTION",
    "CONVERSIONS",
    "ANALYTICS"
  ],
  "brand": {
    "id": "github.com_clikgate",
    "displayName": "Clikgate"
  },
  "description": "Add the Clikgate web script, send goals and report payments (counted only after your payment provider confirms them), and show Clikgate App banners. One template with a tag type selector.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "SELECT",
    "name": "tagType",
    "displayName": "Tag type",
    "macrosInSelect": false,
    "simpleValueType": true,
    "alwaysInSummary": true,
    "defaultValue": "base",
    "selectItems": [
      {
        "value": "base",
        "displayValue": "Clikgate: base script (all pages)"
      },
      {
        "value": "goal",
        "displayValue": "Clikgate: goal"
      },
      {
        "value": "payment",
        "displayValue": "Clikgate: payment reported (needs confirmation)"
      },
      {
        "value": "app_banners",
        "displayValue": "Clikgate: App banners (all pages)"
      }
    ],
    "help": "One template for every Clikgate tag. Add the base script on all pages first, then goal and payment tags on the pages where they happen."
  },
  {
    "type": "TEXT",
    "name": "webKey",
    "displayName": "Web key",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "valueHint": "cgw_live_...",
    "enablingConditions": [
      {
        "paramName": "tagType",
        "paramValue": "base",
        "type": "EQUALS"
      }
    ],
    "valueValidators": [
      {
        "type": "NON_EMPTY",
        "errorMessage": "Paste your web key from Clikgate (Developers, SDKs, Website)."
      },
      {
        "type": "REGEX",
        "args": [
          "^cgw_(live|test)_[A-Za-z0-9_]+$"
        ],
        "errorMessage": "A web key starts with cgw_live_ or cgw_test_."
      }
    ],
    "help": "Your organisation's publishable web key. It isn't a secret and only works on your verified websites."
  },
  {
    "type": "TEXT",
    "name": "clickIdParam",
    "displayName": "Click ID parameter",
    "simpleValueType": true,
    "defaultValue": "cgid",
    "enablingConditions": [
      {
        "paramName": "tagType",
        "paramValue": "base",
        "type": "EQUALS"
      }
    ],
    "valueValidators": [
      {
        "type": "REGEX",
        "args": [
          "^[a-z][a-z0-9_]{0,31}$"
        ],
        "errorMessage": "Lowercase letters, digits or _."
      }
    ],
    "help": "The address parameter that carries the click ID on your Clikgate links (cgid unless you changed it)."
  },
  {
    "type": "TEXT",
    "name": "days",
    "displayName": "Days to keep the click ID",
    "simpleValueType": true,
    "defaultValue": "30",
    "enablingConditions": [
      {
        "paramName": "tagType",
        "paramValue": "base",
        "type": "EQUALS"
      }
    ],
    "valueValidators": [
      {
        "type": "REGEX",
        "args": [
          "^[0-9]{1,3}$"
        ],
        "errorMessage": "A whole number of days from 1 to 400."
      }
    ],
    "help": "How long the web script keeps the click ID on this browser. Some browsers keep script-saved data for less time; a server endpoint helps."
  },
  {
    "type": "TEXT",
    "name": "serverEndpoint",
    "displayName": "Server endpoint (optional)",
    "simpleValueType": true,
    "valueHint": "/cg/keep",
    "enablingConditions": [
      {
        "paramName": "tagType",
        "paramValue": "base",
        "type": "EQUALS"
      }
    ],
    "valueValidators": [
      {
        "type": "REGEX",
        "args": [
          "^(/[^/\\s][^\\s]*)?$"
        ],
        "errorMessage": "A path on this website, for example /cg/keep."
      }
    ],
    "help": "A route on your own website that saves the click ID from your server, so it lasts longer. Leave empty if you don't have one."
  },
  {
    "type": "TEXT",
    "name": "goalKey",
    "displayName": "Goal key",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "valueHint": "signup",
    "enablingConditions": [
      {
        "paramName": "tagType",
        "paramValue": "goal",
        "type": "EQUALS"
      }
    ],
    "valueValidators": [
      {
        "type": "NON_EMPTY",
        "errorMessage": "Copy the goal key from Goals in Clikgate."
      },
      {
        "type": "REGEX",
        "args": [
          "^[a-z][a-z0-9_]{1,39}$"
        ],
        "errorMessage": "Goal keys are lowercase letters, digits and _."
      }
    ],
    "help": "A Standard goal from Goals in Clikgate, for example signup. For payments use the payment reported tag type with a Payment goal."
  },
  {
    "type": "TEXT",
    "name": "reference",
    "displayName": "Reference (optional)",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "tagType",
        "paramValue": "goal",
        "type": "EQUALS"
      }
    ],
    "help": "Your own ID for this goal (an order or form ID). The same reference sent twice is counted once."
  },
  {
    "type": "TEXT",
    "name": "value",
    "displayName": "Value (optional)",
    "simpleValueType": true,
    "valueHint": "1500.50",
    "enablingConditions": [
      {
        "paramName": "tagType",
        "paramValue": "goal",
        "type": "EQUALS"
      }
    ],
    "valueValidators": [
      {
        "type": "REGEX",
        "args": [
          "^([0-9]+(\\.[0-9]+)?)?$"
        ],
        "errorMessage": "A number in normal units, such as 1500.50."
      }
    ],
    "help": "Standard goals only. Values sent from a web page can be changed by anyone visiting it, so don't use them for sales: send payments with the payment reported tag type on a Payment goal instead. Clikgate refuses values on goals it suggests should be Payment goals."
  },
  {
    "type": "TEXT",
    "name": "currency",
    "displayName": "Currency (optional)",
    "simpleValueType": true,
    "valueHint": "NGN",
    "enablingConditions": [
      {
        "paramName": "tagType",
        "paramValue": "goal",
        "type": "EQUALS"
      }
    ],
    "valueValidators": [
      {
        "type": "REGEX",
        "args": [
          "^([A-Za-z]{3})?$"
        ],
        "errorMessage": "A 3-letter currency code."
      }
    ]
  },
  {
    "type": "CHECKBOX",
    "name": "isFirst",
    "checkboxText": "This is the person's first time (for example a first order)",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "tagType",
        "paramValue": "goal",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "paymentGoalKey",
    "displayName": "Payment goal key",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "valueHint": "order_paid",
    "enablingConditions": [
      {
        "paramName": "tagType",
        "paramValue": "payment",
        "type": "EQUALS"
      }
    ],
    "valueValidators": [
      {
        "type": "NON_EMPTY",
        "errorMessage": "Copy the key of a Payment goal from Goals in Clikgate."
      },
      {
        "type": "REGEX",
        "args": [
          "^[a-z][a-z0-9_]{1,39}$"
        ],
        "errorMessage": "Goal keys are lowercase letters, digits and _."
      }
    ],
    "help": "A goal whose kind is Payment. Its amount always comes from the confirmed payment."
  },
  {
    "type": "SELECT",
    "name": "provider",
    "displayName": "Payment provider",
    "macrosInSelect": true,
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "tagType",
        "paramValue": "payment",
        "type": "EQUALS"
      }
    ],
    "defaultValue": "paystack",
    "selectItems": [
      {
        "value": "paystack",
        "displayValue": "Paystack"
      },
      {
        "value": "flutterwave",
        "displayValue": "Flutterwave"
      },
      {
        "value": "monnify",
        "displayValue": "Monnify"
      },
      {
        "value": "squad",
        "displayValue": "Squad"
      },
      {
        "value": "opay",
        "displayValue": "OPay"
      },
      {
        "value": "interswitch",
        "displayValue": "Interswitch"
      },
      {
        "value": "remita",
        "displayValue": "Remita"
      },
      {
        "value": "korapay",
        "displayValue": "Korapay"
      },
      {
        "value": "paga",
        "displayValue": "Paga"
      },
      {
        "value": "moniepoint",
        "displayValue": "Moniepoint"
      },
      {
        "value": "hubtel",
        "displayValue": "Hubtel"
      },
      {
        "value": "mpesa",
        "displayValue": "M-Pesa (Daraja)"
      },
      {
        "value": "pesapal",
        "displayValue": "Pesapal"
      },
      {
        "value": "mtn_momo",
        "displayValue": "MTN MoMo"
      },
      {
        "value": "airtel_money",
        "displayValue": "Airtel Money"
      },
      {
        "value": "yoco",
        "displayValue": "Yoco"
      },
      {
        "value": "payfast",
        "displayValue": "Payfast"
      },
      {
        "value": "peach_payments",
        "displayValue": "Peach Payments"
      },
      {
        "value": "dpo_pay",
        "displayValue": "DPO Pay"
      },
      {
        "value": "stripe",
        "displayValue": "Stripe"
      },
      {
        "value": "paypal",
        "displayValue": "PayPal"
      },
      {
        "value": "adyen",
        "displayValue": "Adyen"
      },
      {
        "value": "square",
        "displayValue": "Square"
      },
      {
        "value": "checkout_com",
        "displayValue": "Checkout.com"
      },
      {
        "value": "shopify",
        "displayValue": "Shopify (order, not a gateway)"
      },
      {
        "value": "woocommerce",
        "displayValue": "WooCommerce (order key, not a gateway)"
      },
      {
        "value": "custom",
        "displayValue": "Other"
      }
    ],
    "valueValidators": [
      {
        "type": "NON_EMPTY",
        "errorMessage": "Choose the payment provider."
      }
    ],
    "help": "The gateway that took the payment. Shopify and WooCommerce aren't gateways: use them only with their order reference as described in the documentation."
  },
  {
    "type": "TEXT",
    "name": "paymentReference",
    "displayName": "Payment reference",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "enablingConditions": [
      {
        "paramName": "tagType",
        "paramValue": "payment",
        "type": "EQUALS"
      }
    ],
    "valueValidators": [
      {
        "type": "NON_EMPTY",
        "errorMessage": "The payment reference is required."
      }
    ],
    "help": "This won't count as a sale until your payment provider confirms it. Use the gateway's transaction reference (for Paystack, the transaction reference), usually from a data layer variable on the order confirmation page."
  },
  {
    "type": "TEXT",
    "name": "siteKey",
    "displayName": "App banner site key",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "valueHint": "cg_site_live_...",
    "enablingConditions": [
      {
        "paramName": "tagType",
        "paramValue": "app_banners",
        "type": "EQUALS"
      }
    ],
    "valueValidators": [
      {
        "type": "NON_EMPTY",
        "errorMessage": "Paste the site key from App banners, Sites in Clikgate."
      },
      {
        "type": "REGEX",
        "args": [
          "^cg_site_(live|test)_[A-Za-z0-9_]+$"
        ],
        "errorMessage": "A site key starts with cg_site_live_ or cg_site_test_."
      }
    ],
    "help": "Banners are designed in Clikgate (App banners). They never show on checkout pages."
  },
  {
    "type": "SELECT",
    "name": "pageType",
    "displayName": "Page type (optional)",
    "macrosInSelect": true,
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "tagType",
        "paramValue": "app_banners",
        "type": "EQUALS"
      }
    ],
    "selectItems": [
      {
        "value": "",
        "displayValue": "Not set"
      },
      {
        "value": "product",
        "displayValue": "product"
      },
      {
        "value": "category",
        "displayValue": "category"
      },
      {
        "value": "shop",
        "displayValue": "shop"
      },
      {
        "value": "cart",
        "displayValue": "cart"
      },
      {
        "value": "checkout",
        "displayValue": "checkout"
      },
      {
        "value": "account",
        "displayValue": "account"
      },
      {
        "value": "home",
        "displayValue": "home"
      },
      {
        "value": "post",
        "displayValue": "post"
      },
      {
        "value": "page",
        "displayValue": "page"
      },
      {
        "value": "other",
        "displayValue": "other"
      }
    ],
    "help": "Pick a variable that returns product, category, shop, cart, checkout, account, home, post, page or other. Banners never show when it is checkout."
  },
  {
    "type": "TEXT",
    "name": "productId",
    "displayName": "Product ID (optional)",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "tagType",
        "paramValue": "app_banners",
        "type": "EQUALS"
      }
    ],
    "help": "Digits only. Passed to your app so it can open the same product."
  },
  {
    "type": "TEXT",
    "name": "sku",
    "displayName": "SKU (optional)",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "tagType",
        "paramValue": "app_banners",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "productSlug",
    "displayName": "Product slug (optional)",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "tagType",
        "paramValue": "app_banners",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "productName",
    "displayName": "Product name (optional)",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "tagType",
        "paramValue": "app_banners",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "categorySlugs",
    "displayName": "Category slugs (optional)",
    "simpleValueType": true,
    "valueHint": "meals,rice",
    "enablingConditions": [
      {
        "paramName": "tagType",
        "paramValue": "app_banners",
        "type": "EQUALS"
      }
    ],
    "help": "Comma-separated."
  },
  {
    "type": "SELECT",
    "name": "consentMode",
    "displayName": "Consent",
    "macrosInSelect": false,
    "simpleValueType": true,
    "defaultValue": "gcm",
    "selectItems": [
      {
        "value": "gcm",
        "displayValue": "Use Google consent mode (wait for analytics_storage)"
      },
      {
        "value": "none",
        "displayValue": "Consent isn't required on this website"
      }
    ],
    "help": "With Google consent mode, the click ID is kept only after analytics_storage is granted, and goals sent without it are counted but not credited to a link. ad_storage and ad_user_data decide whether goals may be sent to ad platforms; ad_personalization is passed on."
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// Clikgate for Google Tag Manager: one template, four tag types (base script, goal, payment reported, App banners).
// The web script and the App banners loader do the work; this code only passes settings and goals to them.
const addConsentListener = require('addConsentListener');
const callInWindow = require('callInWindow');
const createQueue = require('createQueue');
const getType = require('getType');
const injectScript = require('injectScript');
const isConsentGranted = require('isConsentGranted');
const logToConsole = require('logToConsole');
const makeNumber = require('makeNumber');
const makeString = require('makeString');
const setInWindow = require('setInWindow');
const templateStorage = require('templateStorage');

const SCRIPT_URL = 'https://sdk.clikgate.com/v1/static/clikgate.js';
const BANNERS_URL = 'https://api.clikgate.com/v1/static/app-banners.js';
const QUEUE = 'clikgateQueue';
const LOWER = 'abcdefghijklmnopqrstuvwxyz';
const UPPER = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const DIGITS = '0123456789';
const KEY_CHARS = LOWER + UPPER + DIGITS + '_';
const CONSENT_TYPES = ['analytics_storage', 'ad_storage', 'ad_user_data', 'ad_personalization'];
const PAGE_TYPES = ['product', 'category', 'shop', 'cart', 'checkout', 'account', 'home', 'post', 'page', 'other'];
const PROVIDERS = ['paystack', 'flutterwave', 'monnify', 'squad', 'opay', 'interswitch', 'remita', 'korapay', 'paga', 'moniepoint', 'hubtel', 'mpesa', 'pesapal', 'mtn_momo', 'airtel_money', 'yoco', 'payfast', 'peach_payments', 'dpo_pay', 'stripe', 'paypal', 'adyen', 'square', 'checkout_com', 'shopify', 'woocommerce', 'custom'];

const usesConsent = data.consentMode !== 'none';

const fail = (message) => {
  logToConsole('Clikgate: ' + message);
  data.gtmOnFailure();
};

const text = (value) => {
  const type = getType(value);
  if (type !== 'string' && type !== 'number') return '';
  return makeString(value).trim();
};

const onlyChars = (value, chars) => {
  for (let i = 0; i < value.length; i++) {
    if (chars.indexOf(value.charAt(i)) < 0) return false;
  }
  return true;
};

const startsWith = (value, prefix) => value.indexOf(prefix) === 0;

const validWebKey = (key) =>
  (startsWith(key, 'cgw_live_') || startsWith(key, 'cgw_test_')) && key.length > 9 && key.length <= 64 &&
  onlyChars(key, KEY_CHARS);

const validSiteKey = (key) =>
  (startsWith(key, 'cg_site_live_') || startsWith(key, 'cg_site_test_')) && key.length > 13 && key.length <= 64 &&
  onlyChars(key, KEY_CHARS);

const validGoalKey = (key) =>
  key.length >= 2 && key.length <= 40 && LOWER.indexOf(key.charAt(0)) >= 0 && onlyChars(key, LOWER + DIGITS + '_');

const validValue = (value) => {
  const parts = value.split('.');
  if (parts.length > 2) return false;
  for (let i = 0; i < parts.length; i++) {
    if (parts[i].length === 0 || !onlyChars(parts[i], DIGITS)) return false;
  }
  return true;
};

const state = (granted) => (granted ? 'granted' : 'denied');

// GTM consent types -> Clikgate's purposes. Unset types count as granted (isConsentGranted).
const consentState = () => {
  const measurement = isConsentGranted('analytics_storage');
  return {
    analytics: state(measurement),
    attribution: state(measurement),
    ad_user_data: state(isConsentGranted('ad_storage') && isConsentGranted('ad_user_data')),
    ad_personalization: state(isConsentGranted('ad_personalization'))
  };
};

const command = (args) => {
  createQueue(QUEUE)(args);
};

const sendGoal = (key, options) => {
  options.source = 'gtm';
  if (usesConsent) options.consent = consentState();
  if (templateStorage.getItem('cg_loaded')) {
    callInWindow('Clikgate.goal', key, options);
  } else {
    // The web script runs queued commands as soon as it loads
    command(['goal', key, options]);
  }
  data.gtmOnSuccess();
};

const baseScript = () => {
  const webKey = text(data.webKey);
  if (!validWebKey(webKey)) return fail('the web key is missing or invalid (it starts with cgw_live_ or cgw_test_).');
  const config = { 'data-web-key': webKey };
  const param = text(data.clickIdParam) || 'cgid';
  if (param.length > 32 || LOWER.indexOf(param.charAt(0)) < 0 || !onlyChars(param, LOWER + DIGITS + '_')) {
    return fail('the click ID parameter must be lowercase letters, digits or _ (default cgid).');
  }
  config['data-param'] = param;
  const daysText = text(data.days) || '30';
  const days = makeNumber(daysText);
  if (!onlyChars(daysText, DIGITS) || days < 1 || days > 400) return fail('days to keep must be a whole number from 1 to 400.');
  config['data-days'] = makeString(days);
  const endpoint = text(data.serverEndpoint);
  if (endpoint) {
    if (!startsWith(endpoint, '/') || startsWith(endpoint, '//') || endpoint.length > 200 || endpoint.indexOf(' ') >= 0) {
      return fail('the server endpoint must be a path on this website, for example /cg/keep.');
    }
    config['data-server-endpoint'] = endpoint;
  }
  if (usesConsent) config['data-consent'] = 'required';
  setInWindow('ClikgateConfig', config, true);
  if (usesConsent) {
    command(['setConsent', consentState()]);
    if (!templateStorage.getItem('cg_listening')) {
      templateStorage.setItem('cg_listening', true);
      CONSENT_TYPES.forEach((type) => {
        addConsentListener(type, () => {
          command(['setConsent', consentState()]);
        });
      });
    }
  }
  injectScript(
    SCRIPT_URL,
    () => {
      templateStorage.setItem('cg_loaded', true);
      data.gtmOnSuccess();
    },
    () => fail('the Clikgate web script could not be loaded.'),
    'clikgate'
  );
};

const goal = () => {
  const key = text(data.goalKey);
  if (!validGoalKey(key)) return fail('the goal key is missing or invalid (copy it from Goals in Clikgate).');
  const options = {};
  const reference = text(data.reference);
  if (reference) {
    if (reference.length > 128) return fail('the reference is longer than 128 characters.');
    options.reference = reference;
  }
  const value = text(data.value);
  if (value) {
    if (!validValue(value)) return fail('the value must be a number in normal units, for example 1500.50.');
    options.value = value;
    const currency = text(data.currency).toUpperCase();
    if (currency) {
      if (currency.length !== 3 || !onlyChars(currency, UPPER)) return fail('the currency must be a 3-letter code such as NGN.');
      options.currency = currency;
    }
  }
  if (data.isFirst === true) options.isFirst = true;
  sendGoal(key, options);
};

const payment = () => {
  const key = text(data.paymentGoalKey);
  if (!validGoalKey(key)) return fail('the Payment goal key is missing or invalid (copy it from Goals in Clikgate).');
  const provider = text(data.provider).toLowerCase();
  if (PROVIDERS.indexOf(provider) < 0) return fail('choose the payment provider that took the payment.');
  const reference = text(data.paymentReference);
  if (!reference) return fail('the payment reference is missing; nothing was sent.');
  if (reference.length > 128) return fail('the payment reference is longer than 128 characters.');
  sendGoal(key, { provider: provider, reference: reference });
};

const appBanners = () => {
  const siteKey = text(data.siteKey);
  if (!validSiteKey(siteKey)) return fail('the App banner site key is missing or invalid (it starts with cg_site_live_ or cg_site_test_).');
  setInWindow('ClikgateAppBannersConfig', { siteKey: siteKey }, true);
  const page = {};
  let hasPage = false;
  const type = text(data.pageType).toLowerCase();
  if (type) {
    if (PAGE_TYPES.indexOf(type) >= 0) {
      page.type = type;
      hasPage = true;
    } else {
      logToConsole('Clikgate: page type "' + type + '" is not one of ' + PAGE_TYPES.join(', ') + '; it was left out.');
    }
  }
  const productId = text(data.productId);
  if (productId) {
    if (productId.length <= 20 && onlyChars(productId, DIGITS)) {
      page.product_id = productId;
      hasPage = true;
    } else {
      logToConsole('Clikgate: the product ID must be digits only; it was left out.');
    }
  }
  const limits = { sku: 64, product_slug: 120, name: 200 };
  const fields = { sku: data.sku, product_slug: data.productSlug, name: data.productName };
  ['sku', 'product_slug', 'name'].forEach((field) => {
    const value = text(fields[field]);
    if (value) {
      page[field] = value.slice(0, limits[field]);
      hasPage = true;
    }
  });
  const categories = text(data.categorySlugs);
  if (categories) {
    page.category_slugs = categories
      .split(',')
      .map((slug) => slug.trim().slice(0, 120))
      .filter((slug) => slug.length > 0)
      .slice(0, 20);
    hasPage = true;
  }
  if (hasPage) setInWindow('ClikgatePage', page, true);
  injectScript(
    BANNERS_URL,
    data.gtmOnSuccess,
    () => fail('the App banners loader could not be loaded.'),
    'clikgate-app-banners'
  );
};

if (data.tagType === 'base') {
  baseScript();
} else if (data.tagType === 'goal') {
  goal();
} else if (data.tagType === 'payment') {
  payment();
} else if (data.tagType === 'app_banners') {
  appBanners();
} else {
  fail('choose a tag type.');
}


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "ClikgateConfig"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "ClikgateAppBannersConfig"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "ClikgatePage"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "clikgateQueue"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "Clikgate.goal"
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "inject_script",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://sdk.clikgate.com/v1/static/clikgate.js"
              },
              {
                "type": 1,
                "string": "https://api.clikgate.com/v1/static/app-banners.js"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_consent",
        "versionId": "1"
      },
      "param": [
        {
          "key": "consentTypes",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "analytics_storage"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "ad_storage"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "ad_user_data"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "ad_personalization"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_template_storage",
        "versionId": "1"
      },
      "param": []
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Base script: injects the web script and passes its settings
  code: |-
    runCode(base);
    assertApi('setInWindow').wasCalledWith('ClikgateConfig', {'data-web-key': 'cgw_live_abc123', 'data-param': 'cgid', 'data-days': '30', 'data-consent': 'required'}, true);
    assertApi('injectScript').wasCalled();
    assertApi('gtmOnSuccess').wasCalled();
    assertApi('gtmOnFailure').wasNotCalled();
- name: Base script: the script URL is the published one, loaded once per page
  code: |-
    let urls = [];
    let tokens = [];
    mock('injectScript', (url, onSuccess, onFailure, token) => { urls.push(url); tokens.push(token); onSuccess(); });
    runCode(base);
    assertThat(urls).containsExactly([SCRIPT_URL]);
    assertThat(tokens).containsExactly(['clikgate']);
- name: Base script: optional server endpoint, custom parameter and days
  code: |-
    base.serverEndpoint = '/cg/keep';
    base.clickIdParam = 'ref';
    base.days = '90';
    base.consentMode = 'none';
    runCode(base);
    assertApi('setInWindow').wasCalledWith('ClikgateConfig', {'data-web-key': 'cgw_live_abc123', 'data-param': 'ref', 'data-days': '90', 'data-server-endpoint': '/cg/keep'}, true);
    assertApi('gtmOnSuccess').wasCalled();
- name: Base script: a missing web key fails without loading anything
  code: |-
    base.webKey = '';
    runCode(base);
    assertApi('injectScript').wasNotCalled();
    assertApi('setInWindow').wasNotCalled();
    assertApi('gtmOnFailure').wasCalled();
    assertApi('gtmOnSuccess').wasNotCalled();
- name: Base script: a key that isn't a web key is refused
  code: |-
    base.webKey = 'cg_live_secretkey';
    runCode(base);
    assertApi('injectScript').wasNotCalled();
    assertApi('gtmOnFailure').wasCalled();
- name: Base script: an endpoint on another host is refused
  code: |-
    base.serverEndpoint = '//evil.example/keep';
    runCode(base);
    assertApi('injectScript').wasNotCalled();
    assertApi('gtmOnFailure').wasCalled();
- name: Base script: days out of range are refused
  code: |-
    base.days = '0';
    runCode(base);
    assertApi('gtmOnFailure').wasCalled();
- name: Base script: the script failing to load fails the tag
  code: |-
    mock('injectScript', (url, onSuccess, onFailure) => { onFailure(); });
    runCode(base);
    assertApi('gtmOnFailure').wasCalled();
    assertApi('gtmOnSuccess').wasNotCalled();
- name: Base script: consent mode passes the current consent and listens for changes
  code: |-
    mock('isConsentGranted', (type) => type !== 'ad_user_data');
    runCode(base);
    assertThat(queued[0]).isEqualTo(['setConsent', {analytics: 'granted', attribution: 'granted', ad_user_data: 'denied', ad_personalization: 'granted'}]);
    assertApi('addConsentListener').wasCalled();
- name: Base script: a consent change is passed on to the web script
  code: |-
    let listeners = [];
    let analytics = false;
    mock('isConsentGranted', (type) => type === 'analytics_storage' ? analytics : true);
    mock('addConsentListener', (type, listener) => { listeners.push(listener); });
    runCode(base);
    assertThat(queued[0][1].attribution).isEqualTo('denied');
    analytics = true;
    listeners[0]('analytics_storage', true);
    assertThat(queued[1]).isEqualTo(['setConsent', granted]);
- name: Base script: without consent mode nothing about consent is sent
  code: |-
    base.consentMode = 'none';
    runCode(base);
    assertThat(queued).isEmpty();
    assertApi('addConsentListener').wasNotCalled();
    assertApi('isConsentGranted').wasNotCalled();
- name: Goal: queued before the script has loaded, with source gtm and consent
  code: |-
    runCode(goal);
    assertThat(queued).containsExactly([['goal', 'signup', {source: 'gtm', consent: granted}]]);
    assertApi('callInWindow').wasNotCalled();
    assertApi('gtmOnSuccess').wasCalled();
- name: Goal: called directly once the script has loaded
  code: |-
    mockObject('templateStorage', {getItem: (key) => key === 'cg_loaded', setItem: () => {}, removeItem: () => {}, clear: () => {}});
    goal.reference = 'NL-1';
    goal.value = '1500.50';
    goal.currency = 'ngn';
    goal.isFirst = true;
    runCode(goal);
    assertApi('callInWindow').wasCalledWith('Clikgate.goal', 'signup', {reference: 'NL-1', value: '1500.50', currency: 'NGN', isFirst: true, source: 'gtm', consent: granted});
    assertThat(queued).isEmpty();
- name: Goal: consent denied is sent as denied (the web script then leaves the click ID out)
  code: |-
    mock('isConsentGranted', false);
    runCode(goal);
    assertThat(queued[0][2].consent).isEqualTo({analytics: 'denied', attribution: 'denied', ad_user_data: 'denied', ad_personalization: 'denied'});
    assertApi('gtmOnSuccess').wasCalled();
- name: Goal: consent not required sends no consent object
  code: |-
    goal.consentMode = 'none';
    runCode(goal);
    assertThat(queued).containsExactly([['goal', 'signup', {source: 'gtm'}]]);
- name: Goal: a missing goal key fails and sends nothing
  code: |-
    goal.goalKey = '';
    runCode(goal);
    assertThat(queued).isEmpty();
    assertApi('gtmOnFailure').wasCalled();
- name: Goal: an invalid goal key fails
  code: |-
    goal.goalKey = 'Sign Up';
    runCode(goal);
    assertApi('gtmOnFailure').wasCalled();
- name: Goal: a value in minor units or with symbols is refused
  code: |-
    goal.value = '₦1,500';
    runCode(goal);
    assertThat(queued).isEmpty();
    assertApi('gtmOnFailure').wasCalled();
- name: Goal: an invalid currency is refused
  code: |-
    goal.value = '10';
    goal.currency = 'NAIRA';
    runCode(goal);
    assertApi('gtmOnFailure').wasCalled();
- name: Payment reported: provider and reference, never an amount
  code: |-
    runCode(payment);
    assertThat(queued).containsExactly([['goal', 'order_paid', {provider: 'paystack', reference: 'T123456', source: 'gtm', consent: granted}]]);
    assertApi('gtmOnSuccess').wasCalled();
- name: Payment reported: a missing reference fails and sends nothing
  code: |-
    payment.paymentReference = '   ';
    runCode(payment);
    assertThat(queued).isEmpty();
    assertApi('gtmOnFailure').wasCalled();
- name: Payment reported: a missing Payment goal key fails
  code: |-
    payment.paymentGoalKey = '';
    runCode(payment);
    assertApi('gtmOnFailure').wasCalled();
- name: Payment reported: an unknown provider fails
  code: |-
    payment.provider = 'cash';
    runCode(payment);
    assertApi('gtmOnFailure').wasCalled();
- name: Payment reported: a provider from a variable is accepted in any case
  code: |-
    payment.provider = 'Flutterwave';
    runCode(payment);
    assertThat(queued[0][2].provider).isEqualTo('flutterwave');
- name: App banners: injects the loader with the site key
  code: |-
    let urls = [];
    mock('injectScript', (url, onSuccess) => { urls.push(url); onSuccess(); });
    runCode(banners);
    assertApi('setInWindow').wasCalledWith('ClikgateAppBannersConfig', {siteKey: 'cg_site_live_abc123'}, true);
    assertApi('setInWindow').wasNotCalledWith('ClikgatePage', {}, true);
    assertThat(urls).containsExactly([BANNERS_URL]);
    assertApi('gtmOnSuccess').wasCalled();
- name: App banners: page type and product fields become the page context
  code: |-
    banners.pageType = 'product';
    banners.productId = '42';
    banners.sku = 'JOL-BOX';
    banners.productSlug = 'jollof-box';
    banners.productName = 'Jollof box';
    banners.categorySlugs = 'meals, rice ,';
    runCode(banners);
    assertApi('setInWindow').wasCalledWith('ClikgatePage', {type: 'product', product_id: '42', sku: 'JOL-BOX', product_slug: 'jollof-box', name: 'Jollof box', category_slugs: ['meals', 'rice']}, true);
- name: App banners: checkout pages are passed as checkout
  code: |-
    banners.pageType = 'checkout';
    runCode(banners);
    assertApi('setInWindow').wasCalledWith('ClikgatePage', {type: 'checkout'}, true);
- name: App banners: unknown page types and non-numeric product IDs are left out
  code: |-
    banners.pageType = 'landing';
    banners.productId = '42; drop';
    runCode(banners);
    assertApi('setInWindow').wasNotCalledWith('ClikgatePage', {type: 'landing'}, true);
    assertApi('gtmOnSuccess').wasCalled();
- name: App banners: a missing site key fails
  code: |-
    banners.siteKey = 'cgw_live_abc123';
    runCode(banners);
    assertApi('injectScript').wasNotCalled();
    assertApi('gtmOnFailure').wasCalled();
- name: No cookie, pixel or beacon API is used by any tag type
  code: |-
    runCode(base);
    runCode(goal);
    runCode(payment);
    runCode(banners);
    assertApi('getCookieValues').wasNotCalled();
    assertApi('setCookie').wasNotCalled();
    assertApi('sendPixel').wasNotCalled();
- name: No tag type chosen fails
  code: |-
    runCode({});
    assertApi('gtmOnFailure').wasCalled();
setup: |-
  const SCRIPT_URL = 'https://sdk.clikgate.com/v1/static/clikgate.js';
  const BANNERS_URL = 'https://api.clikgate.com/v1/static/app-banners.js';
  const base = {tagType: 'base', webKey: 'cgw_live_abc123', clickIdParam: 'cgid', days: '30', serverEndpoint: '', consentMode: 'gcm'};
  const goal = {tagType: 'goal', goalKey: 'signup', consentMode: 'gcm'};
  const payment = {tagType: 'payment', paymentGoalKey: 'order_paid', provider: 'paystack', paymentReference: 'T123456', consentMode: 'gcm'};
  const banners = {tagType: 'app_banners', siteKey: 'cg_site_live_abc123', consentMode: 'none'};
  let queued = [];
  mock('createQueue', (key) => (item) => { queued.push(item); });
  mock('injectScript', (url, onSuccess, onFailure, token) => { onSuccess(); });
  const granted = {analytics: 'granted', attribution: 'granted', ad_user_data: 'granted', ad_personalization: 'granted'};


___NOTES___

Clikgate for Google Tag Manager. Source: https://github.com/clikgate/clikgate-gtm-template
