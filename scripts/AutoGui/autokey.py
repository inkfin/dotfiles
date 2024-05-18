import pyautogui
import time
import sys


def auto_page_down(interval, cycles=None):
    try:
        if cycles is None:
            print("Press CTRL+C to stop the program.")
        i = 0 if cycles is None else int(cycles)
        while True:
            pyautogui.press("right")
            time.sleep(interval)
            if cycles is not None:
                i -= 1
                if i <= 0:
                    pyautogui.press("home")
                    i = int(cycles)
    except KeyboardInterrupt:
        print("Program interrupted by user.")
    except Exception as e:
        print(f"An error occurred: {e}")


if __name__ == "__main__":
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print("Usage: python script.py <interval in seconds> [number of cycles]")
        sys.exit(1)

    interval = float(sys.argv[1])
    cycles = int(sys.argv[2]) if len(sys.argv) == 3 else None

    auto_page_down(interval, cycles)
