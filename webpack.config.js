var path = require("path");

module.exports = {
  mode: "development",
  entry: "./app/javascript/packs/application.js",
  output: {
    path: path.resolve(__dirname, "dist"),
    filename: "bundle.js"
  }
};
