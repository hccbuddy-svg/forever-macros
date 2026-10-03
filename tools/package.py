"""Build a local addon ZIP and catalog without modifying the game installation."""
from pathlib import Path
from datetime import datetime, timezone
import csv
import io
import json
import shutil
import zipfile
from lupa.lua51 import LuaRuntime
from artwork_assets import validated_art_files

ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "ForeverMacros"
toc_text = (ADDON / "ForeverMacros.toc").read_text(encoding="utf-8")
VERSION = next(line.split(":", 1)[1].strip() for line in toc_text.splitlines() if line.startswith("## Version:"))
if not VERSION or any(char not in "0123456789." for char in VERSION):
    raise RuntimeError("Unexpected addon version")
STAMP = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
def preserve(path):
    if path.exists():
        backup = ROOT / "development-backups" / STAMP / path.relative_to(ROOT)
        backup.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, backup)

def write(path, text):
    preserve(path)
    path.write_text(text, encoding="utf-8", newline="\n")

lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute("FM = {}")
loader = lua.eval("function(source) assert(loadstring(source))('ForeverMacros', FM) end")
for name in ("Catalog.lua", "PvP.lua", "Attacks.lua", "Library.lua", "Core.lua"):
    loader((ADDON / name).read_text(encoding="utf-8"))
lua.execute("FM.ResolveForm = function(ids) return ids[1] == 768 and 3 or 1 end")

definitions = []
catalog = lua.globals().FM.Catalog
render = lua.globals().FM.Core.Render
resolve = lua.eval("function(requirement) return requirement.english end")
for index in range(1, len(catalog) + 1):
    item = catalog[index]
    body = render(item, resolve)
    if isinstance(body, tuple):
        raise RuntimeError(str(body))
    definitions.append({
        "class": item["class"], "id": item["id"], "name": item["name"],
        "description": item["description"], "body": body,
        "install": "Choose in /fm" if item["optional"] else "Automatic starter",
        "teammate_assignment": bool(item["unitBody"]),
        "attack_behavior": item["attackPolicy"],
    })
classes = sorted({item["class"] for item in definitions} - {"ALL"})
lines = [
    "# Macro catalog", "",
    f"{len(definitions)} templates across nine Classic classes and general utility, including {sum(item['install'] == 'Choose in /fm' for item in definitions)} optional additions.",
    "Starter and attack templates install automatically for the current class and learned abilities while character slots remain. Choose other templates in /fm. English examples are shown here; names are checked against the learned spellbook.",
    "These patterns have not yet been validated in-game on Forever.", "",
    "Form and stance numbers below are examples. The addon resolves each character's actual slots when generating a macro.", "",
]
for class_name in ["ALL"] + classes:
    subset = [item for item in definitions if item["class"] == class_name]
    lines += [f"## {class_name}", ""]
    for item in subset:
        lines += [f"### {item['name']}", "", f"Template ID: {item['id']}. {item['description']}", "",
                  f"Installation: {item['install']}. Teammate assignment: {'yes' if item['teammate_assignment'] else 'no'}.", "",
                  f"Attack behavior: {item['attack_behavior']}.", "",
                  "```text", item["body"], "```", ""]
write(ROOT / "CATALOG.md", "\n".join(lines))
output = io.StringIO(newline="")
writer = csv.DictWriter(output, fieldnames=list(definitions[0]))
writer.writeheader()
writer.writerows(definitions)
write(ROOT / "catalog.csv", output.getvalue())

archive = ROOT / f"ForeverMacros-{VERSION}.zip"
lua_files = [line.strip() for line in toc_text.splitlines() if line.strip().endswith(".lua")]
art_files = validated_art_files(ADDON)
source_files = ["ForeverMacros.toc"] + lua_files + art_files
documentation_files = ["README.md", "CATALOG.md", "VALIDATION.md", "ATTACK-AUDIT.md", "RESEARCH.md", "SECURITY.md", "LICENSE"]
preserve(archive)
with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED) as bundle:
    for name in source_files:
        bundle.write(ADDON / name, "ForeverMacros/" + name)
    for name in documentation_files:
        bundle.write(ROOT / name, "ForeverMacros/" + name)
with zipfile.ZipFile(archive) as bundle:
    assert bundle.testzip() is None
    expected = {"ForeverMacros/" + name for name in source_files + documentation_files}
    assert set(bundle.namelist()) == expected
    for name in source_files:
        assert bundle.read("ForeverMacros/" + name) == (ADDON / name).read_bytes()
    for name in documentation_files:
        assert bundle.read("ForeverMacros/" + name) == (ROOT / name).read_bytes()
print(json.dumps({
    "archive": str(archive), "templates": len(definitions),
    "automatic_starter_templates": sum(item["install"] == "Automatic starter" for item in definitions),
    "optional_templates": sum(item["install"] == "Choose in /fm" for item in definitions),
    "class_profile_sizes_including_utility": {
        class_name: sum(item["class"] in ("ALL", class_name) for item in definitions)
        for class_name in classes
    },
    "class_backgrounds": len(art_files), "zip_entries": len(expected), "zip_integrity": "PASS",
}, indent=2))
