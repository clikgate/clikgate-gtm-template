# Clikgate for Google Tag Manager

The official Clikgate tag template for Google Tag Manager (GTM). A marketing team can switch Clikgate on for a website
and send goals from GTM triggers without a developer. It sends the same goals the Clikgate web script sends: they
appear in Goals and funnels and in every report, exactly like goals sent by the script.

It is one template with a **Tag type** selector:

| Tag type | What it does | Fire it on |
| --- | --- | --- |
| **Clikgate: base script** | Loads the Clikgate web script with your web key. The script keeps the click ID from Clikgate links in a first-party cookie (`_cg_cgid` by default) and sends goals. | All pages |
| **Clikgate: goal** | Sends a Standard goal (a sign-up, a lead, a booking) by its goal key, with an optional reference, value and currency. | Thank-you pages, form submissions |
| **Clikgate: payment reported (needs confirmation)** | Reports a payment on a Payment goal with the payment provider and the payment reference. | Order confirmation pages |
| **Clikgate: App banners** | Loads Clikgate App banners with your App banner site key, and can pass the page type and product. | All pages |

## Set up

1. In GTM, open **Templates → Search Gallery**, find **Clikgate** and add it to your workspace.
2. In Clikgate, copy your web key (**Developers → SDKs → Website**). Your website must be verified in Clikgate: the
   key only works on your verified websites.
3. Add a tag **Clikgate: base script**, paste the web key, and fire it on **All Pages** (Initialization or
   Page View).
4. For each goal, add a tag **Clikgate: goal** with the goal key from **Goals** in Clikgate, and fire it where the
   goal happens (for example a thank-you page).
5. For payments, add a tag **Clikgate: payment reported** on your order confirmation page with your **Payment goal**
   key, the payment provider and the payment reference (usually from a data layer variable).
6. For App banners, add a tag **Clikgate: App banners** with the site key from **App banners → Sites**, on all pages.
7. Use GTM's **Preview** mode: the Clikgate template writes a clear message to the browser console when a key, goal
   key or reference is missing. Then use **Check my set-up** in Clikgate (**Settings → Developers → Google Tag
   Manager**) to see the script loads, goals and payment reports Clikgate received.

Goal and payment tags may fire before the base script has finished loading: they are queued and sent as soon as the
script is ready.

## Payments are reported, not counted

Payments sent from Google Tag Manager are reported only. They count as sales when Paystack, Flutterwave, Stripe,
Shopify or your server confirms them.

- A reported payment waits for a trusted confirmation for up to 24 hours. Then it is **Not confirmed**, and it never
  counts in revenue, new customers, partner earnings, ad platform conversions, dashboards or exports.
- The amount always comes from the confirmed payment. The payment tag has no amount field, on purpose.
- Use the gateway's own transaction reference (for Paystack, the transaction reference). For WooCommerce, use the
  order key the Clikgate WordPress plugin confirms. Shopify and WooCommerce aren't payment gateways.
- If you take payments with Paystack and have no WordPress plugin, Shopify app or developer to confirm them,
  there is no secure confirmation route for you yet, so your reported payments will stay unconfirmed until you add
  one. Clikgate shows the options under **Integrations → Payments**.

Values on Standard goals can be faked by anyone who visits the page. Don't use a Standard goal's value for sales:
use a Payment goal. Clikgate refuses values on goals it suggests should be Payment goals.

## Consent

With **Consent: Use Google consent mode** (the default), the template reads Google consent mode and passes it to
Clikgate with every goal:

| Google consent mode | Clikgate |
| --- | --- |
| `analytics_storage` | measurement: keeping the click ID and crediting goals to links |
| `ad_storage` and `ad_user_data` (both) | sending goals to ad platforms |
| `ad_personalization` | passed to ad platforms |

While `analytics_storage` is denied, nothing is stored in the browser and goals are sent **without** the click ID:
they are counted, but not credited to a link. When consent changes, the template passes the change on. A consent type
that your site hasn't set counts as granted (this is how Google consent mode works).

Choose **Consent isn't required on this website** only if your website doesn't need consent for measurement.

The template doesn't read or write cookies itself and sends no pixels: the Clikgate web script keeps the click ID.

## Permissions

| Permission | Why |
| --- | --- |
| Injects scripts: `https://sdk.clikgate.com/v1/static/clikgate.js`, `https://api.clikgate.com/v1/static/app-banners.js` | The web script and the App banners loader |
| Accesses global variables: `ClikgateConfig`, `ClikgateAppBannersConfig`, `ClikgatePage` (read, write), `clikgateQueue` (read, write), `Clikgate.goal` (execute) | Settings for the scripts, the command queue, and sending goals |
| Accesses consent state: `analytics_storage`, `ad_storage`, `ad_user_data`, `ad_personalization` (read) | Passing consent to Clikgate |
| Accesses template storage | Remembering that the script has loaded on this page |
| Logs to console (debug only) | Messages in Preview mode |

## Troubleshooting

- **Nothing arrives in Clikgate:** check in Preview that the base script tag fired and that the web key starts with
  `cgw_live_` (or `cgw_test_` for Test mode). The page's website must be verified in Clikgate.
- **"the goal key is missing or invalid":** copy the key exactly from Goals (lowercase letters, digits and `_`).
- **A payment says "waiting" and never counts:** connect your payment provider in Clikgate (**Integrations →
  Payments**) and check that the tag sends the same reference your provider's confirmations use.
- **Goals arrive but aren't credited to a link:** the visitor didn't arrive from a Clikgate link, or
  `analytics_storage` was denied.
- **App banners don't show:** banners never show on checkout, cart, order and payment pages, or while a payment popup
  is open. Check the banner's targeting in Clikgate.

## Tests

The template's own tests are in the `___TESTS___` section of `template.tpl` (run them in GTM's template editor with
**Run Tests**). The same tests run in node, with every API call checked against the template's permissions:

```bash
npm test        # or: node test/harness.mjs && node test/behaviour.test.mjs
```

`test/behaviour.test.mjs` also runs the tags in a simulated page with the real Clikgate scripts when they are
available next to the template; elsewhere it is skipped.

To try the template against your own development API, import `template.tpl` into a test container and add your
development script address to the **Injects scripts** permission in that copy only.

## Licence

Apache License 2.0. See `LICENSE`.
