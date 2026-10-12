import json
import os
import re
import struct
from dataclasses import dataclass
from pathlib import Path

from PIL import Image


HEADER_STRUCT = struct.Struct("<64si256s")
BLOCK_STRUCT = struct.Struct("<64s256siii")
HEADER_MARK = "LC-GAMES Graphics Resource File"
BLOCK_MARK = "LC-GAMES Graphics Data Block"
TICKS_PER_SECOND = 50.0

PROJECT_DIR = Path(__file__).resolve().parents[1]
SOURCE_BIN_DIR = Path(os.environ.get("FURY_FIST_SOURCE_BIN", ""))
SOURCE_CODE_DIR = Path(os.environ.get("FURY_FIST_SOURCE_CODE", ""))
EXTRACTED_DIR = PROJECT_DIR / "assets" / "extracted"
DATA_DIR = PROJECT_DIR / "resources" / "data"
ACTION_DATA_DIR = DATA_DIR / "actions"
ROLE_FILE = DATA_DIR / "roles.json"

ROLE_SOURCES = {
    "kunio": {
        "data_file": "action-kuni.data",
        "action_file": "gameres_kunio.c",
        "resource_class": "graphics::action::kuni",
    },
    "riki": {
        "data_file": "action-riki.data",
        "action_file": "gameres_riki.c",
        "resource_class": "graphics::action::riki",
    },
    "mike": {
        "data_file": "action-mike.data",
        "action_file": "gameres_mike.c",
        "resource_class": "graphics::action::mike",
    },
    "ben": {
        "data_file": "action-ben.data",
        "action_file": "gameres_ben.c",
        "resource_class": "graphics::action::ben",
    },
    "toraji": {
        "data_file": "action-toraji.data",
        "action_file": "gameres_toraji.c",
        "resource_class": "graphics::action::toraji",
    },
}

STATIC_SOURCES = {
    "main.data": "main",
    "scenes.data": "scenes",
    "font.data": "font",
}


@dataclass
class GraphBlock:
    name: str
    width: int
    height: int
    color_type: int
    image: Image.Image


def _decode_c_string(raw: bytes) -> str:
    return raw.split(b"\0", 1)[0].decode("utf-8", errors="ignore")


def _parse_data_file(path: Path) -> tuple[dict, list[GraphBlock]]:
    with path.open("rb") as handle:
        header_raw = handle.read(HEADER_STRUCT.size)
        if len(header_raw) != HEADER_STRUCT.size:
            raise ValueError(f"incomplete resource header: {path}")
        mark_raw, total_number, class_name_raw = HEADER_STRUCT.unpack(header_raw)
        mark = _decode_c_string(mark_raw)
        class_name = _decode_c_string(class_name_raw)
        if mark != HEADER_MARK:
            raise ValueError(f"unexpected resource mark in {path}: {mark!r}")

        blocks: list[GraphBlock] = []
        for _ in range(total_number):
            block_raw = handle.read(BLOCK_STRUCT.size)
            if len(block_raw) != BLOCK_STRUCT.size:
                break
            mark_raw, name_raw, width, height, color_type = BLOCK_STRUCT.unpack(block_raw)
            mark = _decode_c_string(mark_raw)
            if mark != BLOCK_MARK:
                raise ValueError(f"unexpected block mark in {path}: {mark!r}")
            name = _decode_c_string(name_raw)
            pixel_count = width * height
            channels = 4 if color_type == 1 else 3
            planes = []
            for _ in range(channels):
                plane = handle.read(pixel_count)
                if len(plane) != pixel_count:
                    raise ValueError(f"incomplete pixel plane for {name} in {path}")
                planes.append(plane)
            interleaved = bytearray(pixel_count * channels)
            for index in range(pixel_count):
                base = index * channels
                for channel_index, plane in enumerate(planes):
                    interleaved[base + channel_index] = plane[index]
            mode = "RGBA" if channels == 4 else "RGB"
            image = Image.frombytes(mode, (width, height), bytes(interleaved))
            blocks.append(GraphBlock(name, width, height, color_type, image))

    return {"class_name": class_name, "total_number": total_number}, blocks


def _save_png(image: Image.Image, output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    image.save(output_path)


def extract_graphics() -> dict:
    EXTRACTED_DIR.mkdir(parents=True, exist_ok=True)
    manifest: dict[str, dict] = {"resources": {}}

    for file_name, folder_name in STATIC_SOURCES.items():
        source_path = SOURCE_BIN_DIR / file_name
        header, blocks = _parse_data_file(source_path)
        resource_manifest = {"class_name": header["class_name"], "items": []}
        for block in blocks:
            output_path = EXTRACTED_DIR / folder_name / f"{block.name}.png"
            _save_png(block.image, output_path)
            resource_manifest["items"].append(
                {
                    "name": block.name,
                    "size": [block.width, block.height],
                    "path": str(output_path.relative_to(PROJECT_DIR)).replace("\\", "/"),
                }
            )
        manifest["resources"][folder_name] = resource_manifest

    for role_name, source_info in ROLE_SOURCES.items():
        source_path = SOURCE_BIN_DIR / source_info["data_file"]
        header, blocks = _parse_data_file(source_path)
        resource_manifest = {"class_name": header["class_name"], "items": []}
        for block in blocks:
            output_path = EXTRACTED_DIR / "roles" / role_name / f"{block.name}.png"
            _save_png(block.image, output_path)
            resource_manifest["items"].append(
                {
                    "name": block.name,
                    "size": [block.width, block.height],
                    "path": str(output_path.relative_to(PROJECT_DIR)).replace("\\", "/"),
                }
            )
        manifest["resources"][role_name] = resource_manifest

    manifest_path = DATA_DIR / "asset_manifest.json"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    return manifest


ACTION_HEADER_RE = re.compile(
    r"\{\s*(ACTION_[A-Z0-9_]+)\s*,\s*(TRUE|FALSE)\s*,\s*\{",
    re.DOTALL,
)
FRAME_RE = re.compile(
    r"\{\s*(TRUE|FALSE)\s*,\s*(TRUE|FALSE)\s*,\s*(TRUE|FALSE)\s*,\s*\"([^\"]+)\"\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*\{([^}]*)\}\s*,\s*\{([^}]*)\}\s*,?\s*\}",
    re.DOTALL,
)
ROLE_RE = re.compile(
    r"\{\s*(ROLE_[A-Z_]+)\s*,\s*L\"([^\"]+)\"\s*,\s*(PLAYER_TYPE_[A-Z_]+)\s*,\s*\{\s*([0-9,\s]+)\}\s*,\s*\{(.*?)\}\s*,\s*(\d+)\s*\}",
    re.DOTALL,
)


def _parse_box(raw: str) -> list[int]:
    values = [_eval_box_value(piece.strip()) for piece in raw.split(",") if piece.strip()]
    while len(values) < 6:
        values.append(0)
    return values[:6]


def _eval_box_value(raw: str) -> int:
    expr = raw.replace("GLOBAL_Y_WIDTH", "12")
    if not re.fullmatch(r"[-+*/() 0-9]+", expr):
        raise ValueError(f"unsupported box expression: {raw}")
    return int(eval(expr, {"__builtins__": {}}, {}))


def _action_key(action_name: str) -> str:
    return action_name.removeprefix("ACTION_").lower()


def _iter_action_blocks(text: str):
    search_pos = 0
    while True:
        header_match = ACTION_HEADER_RE.search(text, search_pos)
        if header_match is None:
            return
        action_name, replay_flag = header_match.groups()
        block_start = header_match.end()
        brace_depth = 1
        cursor = block_start
        while cursor < len(text):
            current = text[cursor]
            if current == "{":
                brace_depth += 1
            elif current == "}":
                brace_depth -= 1
                if brace_depth == 0:
                    yield action_name, replay_flag, text[block_start:cursor]
                    search_pos = cursor + 1
                    break
            cursor += 1
        else:
            raise ValueError(f"unterminated action block for {action_name}")


def parse_action_metadata() -> None:
    ACTION_DATA_DIR.mkdir(parents=True, exist_ok=True)
    for role_name, source_info in ROLE_SOURCES.items():
        text = (SOURCE_CODE_DIR / source_info["action_file"]).read_text(encoding="utf-8")
        actions: dict[str, dict] = {}
        for action_name, replay_flag, body in _iter_action_blocks(text):
            frames = []
            for frame_match in FRAME_RE.findall(body):
                (
                    enable_flag,
                    new_attack_flag,
                    horiz_flip_flag,
                    graph_name,
                    remain_time,
                    offset_x,
                    offset_y,
                    hit_box_raw,
                    atk_box_raw,
                ) = frame_match
                if enable_flag != "TRUE":
                    continue
                ticks = int(remain_time)
                duration_sec = max(1, abs(ticks)) / TICKS_PER_SECOND
                frames.append(
                    {
                        "texture": f"assets/extracted/roles/{role_name}/{graph_name}.png",
                        "graph_name": graph_name,
                        "duration_ticks": ticks,
                        "duration_sec": duration_sec,
                        "offset": [int(offset_x), int(offset_y)],
                        "new_attack": new_attack_flag == "TRUE",
                        "horiz_flip": horiz_flip_flag == "TRUE",
                        "hit_box": _parse_box(hit_box_raw),
                        "attack_box": _parse_box(atk_box_raw),
                    }
                )
            actions[_action_key(action_name)] = {
                "source_action": action_name,
                "replay": replay_flag == "TRUE",
                "frames": frames,
            }

        output_path = ACTION_DATA_DIR / f"{role_name}.json"
        output_path.write_text(
            json.dumps({"role": role_name, "actions": actions}, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )


ROLE_ID_TO_KEY = {
    "ROLE_KUNIO": "kunio",
    "ROLE_RIKI": "riki",
    "ROLE_MIKE": "mike",
    "ROLE_BEN": "ben",
    "ROLE_TORAJI": "toraji",
}

FALLBACK_ROLE_NAMES = {
    "kunio": "Kunio",
    "riki": "Riki",
    "mike": "Mike",
    "ben": "Ben",
    "toraji": "Toraji",
}


def parse_role_metadata() -> None:
    text = (SOURCE_CODE_DIR / "game_control.c").read_text(encoding="utf-8")
    roles = []
    for role_id, display_name, player_type, stats_raw, skills_raw, total_skill in ROLE_RE.findall(text):
        stat_values = [int(piece.strip()) for piece in stats_raw.split(",") if piece.strip()]
        skills = re.findall(r"SKILLNAME_[A-Z_]+", skills_raw)
        role_key = ROLE_ID_TO_KEY[role_id]
        roles.append(
            {
                "id": role_key,
                "source_role": role_id,
                "name": FALLBACK_ROLE_NAMES.get(role_key, display_name),
                "player_type": player_type.removeprefix("PLAYER_TYPE_").lower(),
                "stats": {
                    "max_hp": stat_values[0],
                    "cur_hp": stat_values[1],
                    "punch": stat_values[2],
                    "kick": stat_values[3],
                    "speed": stat_values[4],
                    "throw": stat_values[5],
                    "defense": stat_values[6],
                },
                "skills": [skill.removeprefix("SKILLNAME_").lower() for skill in skills],
                "total_skill": int(total_skill),
                "action_data": f"resources/data/actions/{role_key}.json",
                "portrait": "assets/extracted/main/avatar-unknown.png",
                "default_action": "stance",
            }
        )

    ROLE_FILE.write_text(
        json.dumps({"roles": roles}, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


def write_stage_metadata() -> None:
    stage_image = Image.open(EXTRACTED_DIR / "scenes" / "default.png")
    stage_size = [stage_image.width, stage_image.height]
    stage_payload = {
        "stages": [
            {
                "id": "default",
                "name": "Default Stage",
                "background": "assets/extracted/scenes/default.png",
                "size": stage_size,
                "land_origin": [20, 268],
                "land_size": [stage_size[0] - 40, stage_size[1] - 268],
            }
        ]
    }
    (DATA_DIR / "stages.json").write_text(
        json.dumps(stage_payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


def _require_source_paths() -> None:
    if str(SOURCE_BIN_DIR) in {"", "."} or not SOURCE_BIN_DIR.exists():
        raise SystemExit(
            "Missing source bin directory. Set FURY_FIST_SOURCE_BIN to the folder containing original *.data files."
        )
    if str(SOURCE_CODE_DIR) in {"", "."} or not SOURCE_CODE_DIR.exists():
        raise SystemExit(
            "Missing source code directory. Set FURY_FIST_SOURCE_CODE to the original upstream src folder."
        )


def main() -> None:
    _require_source_paths()
    extract_graphics()
    parse_action_metadata()
    parse_role_metadata()
    write_stage_metadata()
    print("Port assets generated in", PROJECT_DIR)


if __name__ == "__main__":
    main()
