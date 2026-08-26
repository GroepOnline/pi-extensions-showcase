import {readFile} from "node:fs/promises";

const file = process.argv[2];
if (!file) throw new Error("usage: node scripts/verify-cast.mjs <cast>");

const raw = await readFile(file, "utf8");
const lines = raw.trimEnd().split("\n");
const events = lines.slice(1).map((line) => JSON.parse(line));
const duration = events.at(-1)?.[0] ?? 0;
const output = events
  .filter((event) => event[1] === "o")
  .map((event) => event[2])
  .join("");

const required = [
  "MiMo-V2.5-Pro",
  "/wishcraft",
  "fffind",
  "/agents",
  "/mission templates scaffold",
  "/mission dashboard",
];
const forbidden = [
  "Error: Model",
  "[Skill conflicts]",
  "pi-mcp-adapter not detected",
  "extended-keys is off",
  "extended-keys-format is xterm",
  "Unknown /mission subcommand",
  "No active mission",
  "checks failed",
  "[FAIL]",
];
const secretPatterns = [
  /sk-[A-Za-z0-9]{10,}/,
  /ghp_[A-Za-z0-9]+/,
  /eyJ[A-Za-z0-9_-]{20,}/,
  /api[_-]?key\s*[:=]/i,
];

const failures = [];
if (events.length < 40) failures.push(`only ${events.length} events`);
if (duration < 80) failures.push(`only ${duration.toFixed(1)} seconds`);
for (const text of required) {
  if (!output.includes(text)) failures.push(`missing ${text}`);
}
for (const text of forbidden) {
  if (output.includes(text)) failures.push(`contains ${text}`);
}
for (const pattern of secretPatterns) {
  if (pattern.test(raw)) failures.push(`secret pattern ${pattern}`);
}

if (failures.length > 0) {
  throw new Error(`cast rejected:\n- ${failures.join("\n- ")}`);
}

console.log(
  JSON.stringify({
    file,
    events: events.length,
    duration: Number(duration.toFixed(2)),
    required,
  }),
);
