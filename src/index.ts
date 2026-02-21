import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { gitTools, handleGitTool } from "./tools/git.js";

const server = new Server(
  {
    name: "k-mcp-devkit",
    version: "0.1.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

const allTools = [...gitTools];

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: allTools,
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;
  const safeArgs = (args ?? {}) as Record<string, string>;

  try {
    const isGitTool = gitTools.some((t) => t.name === name);

    if (isGitTool) {
      const result = await handleGitTool(name, safeArgs);
      return { content: [{ type: "text", text: result }] };
    }

    return {
      content: [{ type: "text", text: `Unknown tool: ${name}` }],
      isError: true,
    };
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return {
      content: [{ type: "text", text: `Error: ${message}` }],
      isError: true,
    };
  }
});

const transport = new StdioServerTransport();
await server.connect(transport);
