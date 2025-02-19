const serverless = require("serverless-http");
const { createServer } = require("http");
const next = require("next");

const app = next({ dev: false });
const handle = app.getRequestHandler();

exports.handler = async (event, context) => {
  try {
    await app.prepare();
    const server = createServer((req, res) => handle(req, res));
    return serverless(server)(event, context);
  } catch (error) {
    console.error("Lambda handler error:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Internal Server Error" }),
    };
  }
};
