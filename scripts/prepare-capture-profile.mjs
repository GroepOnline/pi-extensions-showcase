import {mkdir, readFile, rm, writeFile} from "node:fs/promises";
import {join} from "node:path";

const home = process.env.HOME;
const source = join(home, ".pi", "agent");
const target = join(process.cwd(), "out", "capture-profile");

await rm(target, {recursive: true, force: true});
await mkdir(target, {recursive: true});

const catalog = JSON.parse(await readFile(join(source, "models.json"), "utf8"));
const kilo = catalog.providers.kilo;
const model = kilo.models.find(({id}) => id === "stealth/ox-alpha");
if (!model || model.name !== "MiMo-V2.5-Pro") {
  throw new Error("kilo/stealth/ox-alpha must resolve to MiMo-V2.5-Pro");
}

// Keep only one provider and one model. The non-secret placeholder activates
// catalog resolution; this offline showcase never performs inference.
await writeFile(
  join(target, "models.json"),
  `${JSON.stringify(
    {
      providers: {
        kilo: {
          baseUrl: kilo.baseUrl,
          api: kilo.api,
          authHeader: kilo.authHeader,
          apiKey: "offline-capture-disabled",
          compat: kilo.compat,
          models: [model],
        },
      },
    },
    null,
    2,
  )}\n`,
);

await writeFile(
  join(target, "settings.json"),
  `${JSON.stringify(
    {
      defaultProvider: "kilo",
      defaultModel: "stealth/ox-alpha",
      defaultThinkingLevel: "high",
      theme: "dark",
      quietStartup: true,
      collapseChangelog: true,
      lastChangelogVersion: "0.84.3",
      enableInstallTelemetry: false,
      enabledModels: ["kilo/stealth/ox-alpha"],
      tuiMode: "fullscreen",
      doubleEscapeAction: "none",
      powerline: {
        preset: "full",
        welcome: true,
        placement: "above",
      },
      wishcraft: {
        welcome: {animateLantern: true},
        repairsEnabled: false,
        hooksEnabled: false,
        inlineSkills: false,
      },
    },
    null,
    2,
  )}\n`,
);

console.log(target);
