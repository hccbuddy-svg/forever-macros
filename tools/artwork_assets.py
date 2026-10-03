"""Exact artwork manifest and WoW texture format checks for packaging/installing."""
import struct

CLASSES = ("druid", "hunter", "mage", "paladin", "priest", "rogue", "shaman", "warlock", "warrior")


def validated_art_files(addon):
    paths = [f"Art/{name}.tga" for name in CLASSES]
    actual = {path.relative_to(addon).as_posix() for path in (addon / "Art").rglob("*") if path.is_file()}
    if actual != set(paths):
        raise RuntimeError(f"Artwork manifest mismatch: {sorted(actual.symmetric_difference(paths))}")
    for name in paths:
        path = addon / name
        if not path.resolve().is_relative_to(addon.resolve()):
            raise RuntimeError(f"Artwork escapes addon folder: {name}")
        data = path.read_bytes()
        if len(data) < 18:
            raise RuntimeError(f"Truncated texture: {name}")
        width, height = struct.unpack_from("<HH", data, 12)
        if data[1] != 0 or data[2] != 2 or data[16] != 24 or (width, height) != (1024, 1024):
            raise RuntimeError(f"Expected uncompressed 1024x1024 RGB TGA: {name}")
        if len(data) < 18 + data[0] + width * height * 3:
            raise RuntimeError(f"Incomplete pixel data: {name}")
    return paths
