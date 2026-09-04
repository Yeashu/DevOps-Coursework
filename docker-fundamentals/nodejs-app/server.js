const express = require("express");

const app = express();
app.get("/", (_request, response) => {
  response.send("<h1>Hello World from Node.js!</h1>");
});
app.listen(3000, "0.0.0.0", () => {
  console.log("Node.js application listening on port 3000");
});
