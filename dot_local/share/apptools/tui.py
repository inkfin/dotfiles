"""Textual TUI: pick tools with checkboxes, install/update/uninstall from keys."""

from __future__ import annotations

from threading import Thread
from typing import List, Optional

from textual.app import App, ComposeResult
from textual.binding import Binding
from textual.containers import Horizontal, Vertical
from textual.widgets import DataTable, Footer, Header, Input, RichLog, Static

from . import AppError, Tool, engine, registry

CSS = """
#filter {
    dock: top;
    margin: 0 1;
}
#main {
    layout: horizontal;
    height: 1fr;
}
#list-col {
    width: 3fr;
}
#right-col {
    width: 2fr;
}
#detail {
    height: auto;
    max-height: 50%;
    border: round $primary;
    margin: 0 1 1 0;
    padding: 1 2;
    text-wrap: wrap;
}
#log {
    height: 1fr;
    border: round $secondary;
    margin: 0 1 1 0;
    padding: 0 1;
}
DataTable {
    height: 1fr;
}
#main.narrow {
    layout: vertical;
}
#main.narrow #list-col {
    width: 1fr;
    height: 1fr;
}
#main.narrow #right-col {
    width: 1fr;
    height: auto;
}
#main.narrow #detail {
    height: 6;
    max-height: 6;
}
#main.narrow #log {
    height: 6;
}
"""


class AppToolsApp(App):
    CSS = CSS
    TITLE = "apptools"
    BINDINGS = [
        Binding("space", "toggle", "toggle"),
        Binding("i", "install", "install"),
        Binding("u", "update", "update"),
        Binding("d", "uninstall", "uninstall"),
        Binding("m", "method", "method"),
        Binding("a", "apply", "apply all"),
        Binding("s", "sync", "sync all"),
        Binding("c", "clean", "clean"),
        Binding("r", "rescan", "rescan"),
        Binding("slash", "filter", "filter"),
        Binding("escape", "reset_filter", "clear filter"),
        Binding("q", "quit", "quit"),
    ]

    def __init__(self, tools: List[Tool], state: dict) -> None:
        super().__init__()
        self.tools = tools
        self.state = state
        self.visible_tools: List[Tool] = []
        self.busy = False

    def compose(self) -> ComposeResult:
        yield Header(show_clock=True)
        yield Input(placeholder="filter: name or group", id="filter")
        with Horizontal(id="main"):
            with Vertical(id="list-col"):
                yield DataTable(id="tools")
            with Vertical(id="right-col"):
                yield Static(id="detail")
                yield RichLog(id="log", highlight=True, markup=False, wrap=True)
        yield Footer()

    def on_mount(self) -> None:
        table = self.query_one(DataTable)
        table.cursor_type = "row"
        table.add_columns("", "tool", "method", "status")
        self.refresh_rows()
        self.query_one("#tools", DataTable).focus()

    def on_resize(self, event) -> None:
        main = self.query_one("#main")
        if event.size.width <= 120:
            main.add_class("narrow")
        else:
            main.remove_class("narrow")

    # ---- rendering ---------------------------------------------------------

    def _current_filter(self) -> str:
        return self.query_one("#filter", Input).value.strip().lower()

    def refresh_rows(self) -> None:
        table = self.query_one(DataTable)
        table.clear()
        f = self._current_filter()
        self.visible_tools = []
        for tool in self.tools:
            if f and f not in tool.name.lower() and f not in tool.group.lower():
                continue
            entry = self.state["tools"].get(tool.name, {})
            installed, method, _ = engine.probe(tool, entry)
            enabled = entry.get("enabled", tool.enabled)
            mark = "✓" if enabled else "✗"
            if not enabled:
                status = "off"
            elif installed:
                status = "installed"
            else:
                status = "missing"
            table.add_row(mark, tool.name, method or "-", status, key=tool.name)
            self.visible_tools.append(tool)
        self.update_detail()

    def _selected(self) -> Optional[Tool]:
        table = self.query_one(DataTable)
        try:
            row = table.cursor_coordinate.row
        except Exception:
            return None
        if 0 <= row < len(self.visible_tools):
            return self.visible_tools[row]
        return None

    def _chosen_method(self, tool: Tool, entry: dict) -> Optional[str]:
        try:
            name, _, _ = engine.resolve(tool, entry.get("method"))
            return name
        except AppError:
            return None

    def update_detail(self) -> None:
        pane = self.query_one("#detail", Static)
        tool = self._selected()
        if tool is None:
            pane.update("")
            return
        plat = engine.platform()
        entry = self.state["tools"].get(tool.name, {})
        installed, method, version = engine.probe(tool, entry)
        chosen = self._chosen_method(tool, entry) or "-"
        lines = [
            f"[b]{tool.name}[/b]",
            tool.desc,
            f"group: {tool.group}",
            "",
        ]
        avail = engine.available_methods(tool, plat)
        if avail:
            lines.append("[b]methods:[/b]")
            for mname, method_obj in avail:
                recipe = method_obj.sources[plat]
                marker = "●" if mname == chosen else "○"
                lines.append(f"  {marker} {mname}  {_recipe_summary(recipe)}")
        else:
            lines.append("no recipe for this platform")
        lines += [
            "",
            f"state: [b]{'installed' if installed else 'not installed'}[/b] ({method or '-'})",
            f"enabled: {entry.get('enabled', tool.enabled)}",
        ]
        if version:
            lines.append(f"version: {version}")
        if entry.get("url"):
            lines.append(f"url: {entry['url']}")
        pane.update("\n".join(lines))

    # ---- actions -----------------------------------------------------------

    def action_toggle(self) -> None:
        tool = self._selected()
        if tool is None or self.busy:
            return
        entry = self.state["tools"].setdefault(tool.name, {"enabled": True, "installed": False})
        entry["enabled"] = not entry.get("enabled", True)
        registry.save_state(self.state)
        self.refresh_rows()

    def action_method(self) -> None:
        tool = self._selected()
        if tool is None or self.busy:
            return
        choices = [n for n, _ in engine.available_methods(tool, engine.platform())]
        if len(choices) < 2:
            return
        entry = self.state["tools"].get(tool.name, {})
        current = entry.get("method") or tool.default_method
        idx = choices.index(current) if current in choices else -1
        entry["method"] = choices[(idx + 1) % len(choices)]
        registry.save_state(self.state)
        self.refresh_rows()

    def action_install(self) -> None:
        tool = self._selected()
        if tool is not None:
            self._run_ops([("install", tool)])

    def action_update(self) -> None:
        tool = self._selected()
        if tool is not None:
            self._run_ops([("update", tool)])

    def action_uninstall(self) -> None:
        tool = self._selected()
        if tool is not None:
            self._run_ops([("uninstall", tool)])

    def action_apply(self) -> None:
        ops = []
        for t in self.tools:
            entry = self.state["tools"].get(t.name, {})
            if entry.get("enabled", t.enabled) and not entry.get("installed"):
                ops.append(("install", t))
        self._run_ops(ops)

    def action_sync(self) -> None:
        ops = []
        for t in self.tools:
            entry = self.state["tools"].get(t.name, {})
            if not entry.get("enabled", t.enabled):
                continue
            ops.append(("update" if entry.get("installed") else "install", t))
        self._run_ops(ops)

    def action_clean(self) -> None:
        ops = []
        for t in self.tools:
            entry = self.state["tools"].get(t.name, {})
            if entry.get("installed") and not entry.get("enabled", t.enabled):
                ops.append(("uninstall", t))
        self._run_ops(ops)

    def action_filter(self) -> None:
        self.query_one("#filter", Input).focus()

    def action_reset_filter(self) -> None:
        self.query_one("#filter", Input).value = ""
        self.query_one("#tools", DataTable).focus()
        self.refresh_rows()

    def action_rescan(self) -> None:
        self.refresh_rows()

    def on_input_changed(self, event: Input.Changed) -> None:
        self.refresh_rows()

    def on_data_table_cursor_moved(self, event) -> None:
        self.update_detail()

    # ---- async operations --------------------------------------------------

    def _run_ops(self, ops) -> None:
        if self.busy or not ops:
            return
        self.busy = True
        self.sub_title = "working..."
        self.query_one("#log", RichLog).clear()
        self._log(f"apptools: {len(ops)} operation(s)")

        def worker() -> None:
            try:
                for kind, tool in ops:
                    if kind == "install":
                        engine.install(tool, self.state, log=self._post)
                    elif kind == "update":
                        engine.update(tool, self.state, log=self._post)
                    else:
                        engine.uninstall(tool.name, self.state, self.tools, log=self._post)
            except AppError as e:
                self._post(f"error: {e}")
            except Exception as e:
                self._post(f"error: {e!r}")
            finally:
                self.call_from_thread(self._ops_done)

        Thread(target=worker, daemon=True).start()

    def _post(self, line: str) -> None:
        self.call_from_thread(self._log, line)

    def _log(self, line: str) -> None:
        self.query_one("#log", RichLog).write(line)

    def _ops_done(self) -> None:
        self.busy = False
        self.sub_title = ""
        self.refresh_rows()

    def on_unmount(self) -> None:
        registry.save_state(self.state)


def _recipe_summary(recipe) -> str:
    from . import Archive, File, Git, Shell

    if isinstance(recipe, Shell):
        return recipe.install
    if isinstance(recipe, Git):
        return f"git {recipe.url}"
    if isinstance(recipe, File):
        return recipe.url
    if isinstance(recipe, Archive):
        tail = f" pick={recipe.pick}" if recipe.pick else ""
        return f"archive {recipe.url}{tail}"
    return type(recipe).__name__


def run(tools: List[Tool], state: dict) -> None:
    AppToolsApp(tools, state).run()
