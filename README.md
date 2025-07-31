# Steps to generate the build

## Build with Expo

To generate a static web site, you need to add this to you `app.json`

```json
"experiments": {
  "baseUrl": "./"
}
```

```sh
npm run build:web
```

## Create LG Project

```sh
ares-generate -t basic lg-app
```

The structure of a new project is

```sh
.
├── appinfo.json
├── icon.png
├── index.html
├── largeIcon.png
└── webOSTVjs-1.2.10
    ├── LICENSE-2.0.txt
    ├── webOSTV-dev.js
    └── webOSTV.js
```

You just need to add the build to this folder in order to run it as an LG project.

## Transpile to ES5

>This step is only needed if you will test or want to have support on TVs manufactured <= 2021

Before running this, you need to ensure you have copied in your project the `babelrc.webos.json` file that exist in this repo.

```sh
npm run build:webos-es5
```

This will generate the `dist-es5/` folder

## Copy content into the lg-app folder

### Tv Manufactured > 2021

This will copy directly the `dist` folder into the `lg-app` folder

```sh
npm run copy:normal-build
```

### Tv Manufactured < 2021

This will copy the `dist-es5` folder into the `lg-app` folder

```sh
npm run copy:es5-build
```

## Modify the index.html (After having it in the lg-app folder)

Run this command

```sh
npm run modifyHtml
```

This script will modify automatically your index.html with the list of changes mentioned below.

**Inside the head**

```html
<base href="./" />
```

**inside the body**

The following helps with an error that says `Uncaught ReferenceError: globalThis is not defined`.

```html
<script>
if (typeof globalThis === 'undefined') {
  Object.defineProperty(Object.prototype, '__magic__', {
    get: function () {
      return this;
    },
    configurable: true
  });
  __magic__.globalThis = __magic__;
  delete Object.prototype.__magic__;
}
</script>
```

The following helps with an error that says `Uncaught ReferenceError: t.getRootNode is not defined at 167:7`.

```html
<script>
if (typeof Element !== "undefined" && !Element.prototype.getRootNode) {
  Element.prototype.getRootNode = function () {
    return document;
  };
}
</script>
```

The following helps with an error that says `ResizeObserver is not defined at 9:45209`.

```html
<script>
  if (typeof ResizeObserver === "undefined") {
    window.ResizeObserver = function () {
      this.observe = function () {};
      this.unobserve = function () {};
      this.disconnect = function () {};
    };
  }
</script>
```

The following helps with an error that says `queueMicrotask is not defined at 9:45209`.

```html
<script>
if (typeof queueMicrotask === "undefined") {
  window.queueMicrotask = function (cb) {
    Promise.resolve().then(cb);
  };
}
</script>
```

The following helps with an error that says `cannot read property 'hasBeenActive' of undefined at 9:47894`.

```html
<script>
if (typeof navigator.userActivation === "undefined") {
  navigator.userActivation = {
    hasBeenActive: true,
    isActive: true
  };
}
</script>
```

**Manual Logs**

```html
<div id="debug"></div> // Put this above the `root` div.

<script>
  function log(msg) {
    const el = document.getElementById("debug");
    el.innerHTML += `<div>${msg}</div>`;
  }

  log("Script loaded");

  window.onerror = function (msg, url, line, col, error) {
    log(`JS Error: ${msg} at ${line}:${col}`);
  };
</script>
```

I highly recommend to add a bg to the `debug` div.

```css
#debug {
  background-color: red;
}
```

> Important: Each time you run `npm run build:web` you'll need to put back all these sections in the html, since that file is regenerated.

## Install in your TV

Follow this guide to understand how to connect with your real TV

*Helpers*

- https://webostv.developer.lge.com/develop/getting-started/build-your-first-web-app
- https://webostv.developer.lge.com/develop/tools/webos-studio-dev-guide

**Running Again**

Let say you have connect in the past with you LG Tv, just do the following to re-enable the connection

1) Open the developer mode app and turn on again the `Key Server`.
2) `ares-setup-device --list` to check the connection is still there
3) `ares-novacom --device lg-tv --getkey` to refresh the connection. Ensure to put the `passphrase` that appears in tv. Normally it will be the same one

And that's it. Just build and install again with the commands mentioned below.

```sh
ares-package --no-minify lg-app
ares-install --device lg-tv co.jose.tv-test_1.0.0_all.ipk
ares-launch --device lg-tv co.jose.tv-test
```

## Troubleshoting

If you see an error in the app (using the manual logs). That says

**Uncaught SyntaxError: Unexpected token ? at 2:1556**

This means your TV was manufactured < 2021. Which means you did not follow the `Transpile to ES5` section copy the content of the `dist-es5/` folder into the lg project folder and run again the commands in the `Install in your TV` section.

## Modules instaled

Besides the list of modules pre-installed when the react expo project is created with

```sh
npx create-expo-app WebTVTest --template expo-template-blank-typescript
```

these dev dependencies where added

```sh
npm install --save-dev @babel/cli @babel/core @babel/preset-env @babel/preset-react @babel/preset-typescript @babel/plugin-transform-optional-chaining @babel/plugin-transform-nullish-coalescing-operator

```

```sh
"@babel/cli": "^7.28.0",
"@babel/core": "^7.28.0",
"@babel/preset-env": "^7.28.0",
"@babel/preset-react": "^7.27.1",
"@babel/preset-typescript": "^7.27.1",
"@babel/plugin-transform-optional-chaining": "^7.27.1",
"@babel/plugin-transform-nullish-coalescing-operator": "^7.27.1",
```

and these dependencies

```sh
npm install core-js regenerator-runtime
```

```sh
"core-js": "^3.44.0",
"regenerator-runtime": "^0.14.1"
```