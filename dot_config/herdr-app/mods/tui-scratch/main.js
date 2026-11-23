import { View, div } from "gpui-kit";
import {
  checking, closeOverlay, focused, hc, notify, openOverlay, props, spaces, theme,
} from "herdr";

export default class ScratchTerminal extends View {
  init(_props, cx) {
    if (checking() || props().terminal) return;
    const launchOverlay = props().overlay;
    const current = focused();
    const machine = spaces().find((space) => space.id === current?.space)?.machine;
    const args = ["run", "--bg", "--json", "--no-parent", "--no-notify"];
    if (machine) args.push("--on", machine);
    if (current?.cwd) args.push("--cwd", current.cwd);
    args.push("--", "sh", "-c", 'exec "${SHELL:-sh}"');

    cx.spawn(async () => {
      try {
        const result = await hc(args);
        if (result.code !== 0) throw new Error(result.stderr.trim() || "Shell launch failed");
        const { address } = JSON.parse(result.stdout);
        try {
          openOverlay({
            kind: "dialog",
            modal: true,
            width: 0.8,
            height: 0.8,
            layout: {
              type: "column",
              children: [
                { type: "block", size: { px: 32 }, content: { mod: "tui-scratch", props: { terminal: address } } },
                { type: "block", content: { terminal: address } },
              ],
            },
          });
        } catch (error) {
          await hc(["kill", address]);
          throw error;
        }
      } catch (error) {
        notify({ title: "Scratch terminal", body: String(error), level: "error" });
      } finally {
        closeOverlay(launchOverlay);
      }
    });
  }

  render() {
    const { terminal } = props() ?? {};
    const colors = theme();
    const row = div().size_full().flex().items_center().px(12).text_color(colors.foreground);
    if (!terminal) return row.child("Opening scratch terminal…");
    return row.child(div().flex_1().child("Scratch terminal")).child(
      div().id("close-scratch").cursor_pointer().child("Close").on_click(() => {
        void hc(["kill", terminal]);
      }),
    );
  }
}
