import re
from kittens.tui.handler import result_handler
from kitty.key_encoding import KeyEvent, parse_shortcut


def is_window_vim(window):
    fp = window.child.foreground_processes
    return any(
        re.search(r"n?vim?", p["cmdline"][0] if len(p["cmdline"]) else "", re.I)
        for p in fp
    )


def encode_key_mapping(window, key_mapping):
    mods, key = parse_shortcut(key_mapping)
    event = KeyEvent(
        mods=mods,
        key=key,
        shift=bool(mods & 1),
        alt=bool(mods & 2),
        ctrl=bool(mods & 4),
        super=bool(mods & 8),
        hyper=bool(mods & 16),
        meta=bool(mods & 32),
    ).as_window_system_event()
    return window.encoded_key(event)


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, result, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return

    direction = args[1]   # e.g. "left"
    key_mapping = args[2]  # e.g. "alt+h"

    if is_window_vim(window):
        encoded = encode_key_mapping(window, key_mapping)
        window.write_to_child(encoded)
    else:
        boss.active_tab.neighboring_window(direction)
