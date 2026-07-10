const { Client } = require("@modelcontextprotocol/sdk/client/index.js");
const { StdioClientTransport } = require("@modelcontextprotocol/sdk/client/stdio.js");

async function main() {
  const transport = new StdioClientTransport({
    command: process.execPath,
    args: [require("path").join(__dirname, "index.js")],
  });
  const client = new Client({ name: "test-client", version: "1.0.0" });
  await client.connect(transport);

  const tools = await client.listTools();
  console.log("TOOLS:", tools.tools.map((t) => t.name));

  const resources = await client.listResources();
  console.log("RESOURCES:", resources.resources.map((r) => r.uri));

  const checklist = await client.callTool({ name: "get_pitfall_checklist", arguments: {} });
  console.log("\nCHECKLIST (first 300 chars):", checklist.content[0].text.slice(0, 300));

  const fn = await client.callTool({ name: "get_function_source", arguments: { name: "fxn_code_lesions" } });
  console.log("\nFUNCTION SOURCE (first 200 chars):", fn.content[0].text.slice(0, 200));

  const gen = await client.callTool({
    name: "generate_treatment_group_r_code",
    arguments: {
      trigger_event_name: "NEDLAME3",
      group_code_field: "MNFRS3",
      arm_labels: { "1": "TX Trim", "2": "Sham", "3": "Control" },
    },
  });
  console.log("\nGENERATED CODE:\n", gen.content[0].text);

  const resource = await client.readResource({ uri: "nedlame-rct://lessons-learned" });
  console.log("\nRESOURCE READ (first 150 chars):", resource.contents[0].text.slice(0, 150));

  await client.close();
  console.log("\nALL OK");
}

main().catch((err) => {
  console.error("TEST FAILED:", err);
  process.exit(1);
});
