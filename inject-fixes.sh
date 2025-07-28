#!/bin/bash

echo "🛠️  Injecting fixes into index.html..."

INDEX_FILE="lg-app/index.html"

# 1. Insert <base href="./" /> after <head>
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' '/<head>/a\
  <base href="./" />
  ' "$INDEX_FILE"
else
  sed -i '/<head>/a <base href="./" />' "$INDEX_FILE"
fi

# 2. Insert <div id="debug"></div> before <div id="root">
if grep -q '<div[^>]*id="root"' "$INDEX_FILE"; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' '/<div[^>]*id="root"/i\
    <div id="debug"></div>
    ' "$INDEX_FILE"
  else
    sed -i '/<div[^>]*id="root"/i <div id="debug"></div>' "$INDEX_FILE"
  fi
fi

# 3. Inject compatibility <script> blocks before </body>
echo "📜 Injecting compatibility and logging scripts..."

perl -i -pe 'BEGIN {
  $injection = q{
<script>
if (typeof globalThis === "undefined") {
  Object.defineProperty(Object.prototype, "__magic__", {
    get: function () {
      return this;
    },
    configurable: true
  });
  __magic__.globalThis = __magic__;
  delete Object.prototype.__magic__;
}
</script>

<script>
if (typeof Element !== "undefined" && !Element.prototype.getRootNode) {
  Element.prototype.getRootNode = function () {
    return document;
  };
}
</script>

<script>
  function log(msg) {
    const el = document.getElementById("debug");
    if (el) el.innerHTML += `<div>${msg}</div>`;
  }

  log("Script loaded");

  window.onerror = function (msg, url, line, col, error) {
    log(`JS Error: ${msg} at ${line}:${col}`);
  };
</script>
};
}
s{</body>}{$injection\n</body>}g' "$INDEX_FILE"

# 4. Inject debug CSS into <style id="expo-reset">
echo "🎨 Injecting #debug style into <style id=\"expo-reset\">..."

perl -0777 -i -pe 's{(<style[^>]*id=["'\'']expo-reset["'\''][^>]*>.*?)(</style>)}{$1\n#debug {\n  background-color: red;\n}\n$2}is' "$INDEX_FILE"

echo "✅ All fixes injected successfully."
