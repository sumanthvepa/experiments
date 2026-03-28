from pynput import keyboard

def on_press(key):
    try:
        # normal key
        print(f"KEY: {key.char}")
    except AttributeError:
        # special key (shift, ctrl, etc)
        print(f"SPECIAL: {key}")

def on_release(key):
    print(f"RELEASE: {key}")
    if key == keyboard.Key.esc:
        return False

print("Press keys (ESC to quit)")
with keyboard.Listener(on_press=on_press, on_release=on_release) as listener:
    listener.join()

