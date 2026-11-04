"""Run addon logic in independent Lua 5.1 runtimes with mocked WoW APIs."""
from pathlib import Path
import json
import runpy
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]
CASES = json.loads((ROOT / "tests" / "cases.json").read_text(encoding="utf-8"))
CASES += runpy.run_path(str(ROOT / "tests" / "expansion_cases.py"))["CASES"]
CASES += runpy.run_path(str(ROOT / "tests" / "attack_cases.py"))["CASES"]
CASES += runpy.run_path(str(ROOT / "tests" / "theme_cases.py"))["CASES"]
CASES += runpy.run_path(str(ROOT / "tests" / "learning_cases.py"))["CASES"]
CASES += runpy.run_path(str(ROOT / "tests" / "workshop_cases.py"))["CASES"]
CASES += runpy.run_path(str(ROOT / "tests" / "advisor_cases.py"))["CASES"]
CASES += runpy.run_path(str(ROOT / "tests" / "bag_cases.py"))["CASES"]
CASES += runpy.run_path(str(ROOT / "tests" / "automatic_cases.py"))["CASES"]
CASES += runpy.run_path(str(ROOT / "tests" / "layout_cases.py"))["CASES"]
passed = 0
failed = []
for title, code in CASES:
    runtime = LuaRuntime(unpack_returned_tuples=True)
    runtime.execute((ROOT / "tests" / "harness.lua").read_text(encoding="utf-8"))
    runtime.execute((ROOT / "tests" / "macro_model.lua").read_text(encoding="utf-8"))
    runtime.execute("FM = {}")
    load = runtime.eval("function(source) local chunk = assert(loadstring(source)); chunk('ForeverMacros', FM) end")
    filenames = [line.strip() for line in (ROOT / "ForeverMacros" / "ForeverMacros.toc").read_text().splitlines() if line.strip().endswith(".lua")]
    for filename in filenames:
        load((ROOT / "ForeverMacros" / filename).read_text(encoding="utf-8"))
    try:
        runtime.execute(code)
        assert runtime.eval("TEST.denied") == 0, "Forbidden mutation or execution was called"
        passed += 1
        print("PASS " + title)
    except Exception as error:
        failed.append((title, str(error)))
        print("FAIL " + title + ": " + str(error))

print(f"\n{passed}/{len(CASES)} passed in Lua 5.1. In-game behavior remains unverified.")
if failed:
    raise SystemExit(1)
