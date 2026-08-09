"""apptools catalog.

Add/remove tools here. Each Tool maps platforms to recipes; tools with
several install strategies (e.g. neovim) expose them as methods, picked per
machine either in the TUI (m) or via state.json.
"""

from apptools import Archive, File, Git, Method, Shell, Tool


def _shell(name, desc, group, pkg, check, windows=True, unix=True):
    methods = {}
    if unix:
        methods["brew"] = Method(sources={
            "darwin": Shell(
                f"brew install {pkg}",
                uninstall=f"brew uninstall {pkg}",
                update=f"brew upgrade {pkg}",
                check=check,
            ),
            "linux": Shell(
                f"brew install {pkg}",
                uninstall=f"brew uninstall {pkg}",
                update=f"brew upgrade {pkg}",
                check=check,
            ),
        })
    if windows:
        methods["scoop"] = Method(sources={
            "windows": Shell(
                f"scoop install {pkg}",
                uninstall=f"scoop uninstall {pkg}",
                update=f"scoop update {pkg}",
                check=check,
            ),
        })
    return Tool(name=name, desc=desc, group=group, methods=methods)


TOOLS = [
    Tool(
        name="glsl_analyzer",
        desc="GLSL language server for shader editing",
        group="lsp",
        sources={
            "windows": Archive(
                "https://github.com/nolanderc/glsl_analyzer/releases/latest/download/x86_64-windows.zip",
                strip=1,
                pick="bin/glsl_analyzer.exe",
            ),
            "darwin": Archive(
                "https://github.com/nolanderc/glsl_analyzer/releases/latest/download/aarch64-macos.zip",
                strip=1,
                pick="bin/glsl_analyzer",
            ),
            "linux": Archive(
                "https://github.com/nolanderc/glsl_analyzer/releases/latest/download/x86_64-linux-musl.zip",
                strip=1,
                pick="bin/glsl_analyzer",
            ),
        },
    ),
    Tool(
        name="neovim-nightly",
        desc="Neovim nightly editor (download to ~/.local or via brew)",
        group="editor",
        default_method="download",
        methods={
            "download": Method(sources={
                "windows": Archive(
                    "https://github.com/neovim/neovim/releases/download/nightly/nvim-win64.zip",
                    strip=1,
                    into="~/.local/neovim",
                    bin="~/.local/neovim/bin/nvim",
                ),
                "darwin": Archive(
                    "https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz",
                    strip=1,
                    into="~/.local/neovim",
                    bin="~/.local/neovim/bin/nvim",
                ),
                "linux": Archive(
                    "https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz",
                    strip=1,
                    into="~/.local/neovim",
                    bin="~/.local/neovim/bin/nvim",
                ),
            }),
            "brew": Method(sources={
                "darwin": Shell("brew install neovim", uninstall="brew uninstall neovim", update="brew upgrade neovim", check=["nvim", "--version"]),
                "linux": Shell("brew install neovim", uninstall="brew uninstall neovim", update="brew upgrade neovim", check=["nvim", "--version"]),
            }),
        },
    ),
    Tool(
        name="pdf2text",
        desc="PDF text extraction CLI (PDFTron)",
        group="doc",
        sources={
            "windows": Archive("https://www.pdftron.com/downloads/pdf2text.zip", strip=1, pick="pdf2text/*.exe"),
            "darwin": Archive("https://www.pdftron.com/downloads/pdf2text_mac.zip", strip=1, pick="pdf2text_mac/pdf2text"),
            "linux": Archive("https://www.pdftron.com/downloads/pdf2text.tar.gz", strip=1, pick="pdf2text/pdf2text"),
        },
    ),
    Tool(
        name="im-select",
        desc="Command-line input method switcher",
        group="windows",
        sources={
            "windows": File("https://github.com/daipeihust/im-select/raw/master/win/out/x86/im-select.exe"),
        },
    ),
    Tool(
        name="quickswitch",
        desc="Fast window switcher",
        group="windows",
        sources={
            "windows": Archive("https://github.com/gepruts/QuickSwitch/releases/download/v0.5/QuickSwitch_v0.5_x64.zip", pick="QuickSwitch.exe"),
        },
    ),
    Tool(
        name="rime-ls",
        desc="Rime LSP server for Chinese input",
        group="lsp",
        sources={
            "darwin": Archive(
                "https://github.com/wlh320/rime-ls/releases/latest/download/rime-ls-v0.4.3-universal2-apple-darwin.tar.bz2",
                into="~/.local/rime",
                bin="~/.local/rime/rime_ls",
                shim_env={"DYLD_FALLBACK_LIBRARY_PATH": "/opt/homebrew/lib"},
            ),
            "linux": Archive("https://github.com/wlh320/rime-ls/releases/latest/download/rime-ls-v0.4.3-x86_64-unknown-linux-gnu.tar.gz", into="~/.local/bin"),
        },
    ),
    _shell("tmux", "Terminal multiplexer", "shell", "tmux", ["tmux", "-V"], windows=False),
    _shell("ranger", "File manager in the terminal", "shell", "ranger", ["ranger", "--version"], windows=False),
    _shell("fzf", "Fuzzy finder", "shell", "fzf", ["fzf", "--version"]),
    _shell("unzip", "Unzip archives", "shell", "unzip", ["unzip", "-v"], windows=False),
    _shell("rg", "ripgrep: fast text search", "shell", "ripgrep", ["rg", "--version"]),
    _shell("fd", "Simple, fast find alternative", "shell", "fd", ["fd", "--version"]),
    _shell("bat", "cat with syntax highlighting", "shell", "bat", ["bat", "--version"]),
    _shell("zoxide", "Smart cd with fuzzy matching", "shell", "zoxide", ["zoxide", "--version"]),
    _shell("starship", "Cross-shell prompt", "shell", "starship", ["starship", "--version"]),
    _shell("lsd", "ls with icons", "shell", "lsd", ["lsd", "--version"]),
    _shell("bottom", "TUI system monitor", "shell", "bottom", ["btm", "--version"]),
    _shell("glow", "Markdown rendered in the terminal", "shell", "glow", ["glow", "--version"]),
    _shell("chafa", "Image-to-terminal converter", "shell", "chafa", ["chafa", "--version"]),
    _shell("git", "Distributed version control", "shell", "git", ["git", "--version"]),
    _shell("7zip", "7-Zip archiver", "shell", "7zip", ["7z", "i"]),
    _shell("aria2", "Multi-protocol download utility", "shell", "aria2", ["aria2c", "--version"]),
]
