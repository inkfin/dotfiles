#!/usr/bin/env bash
set -euo pipefail

if [[ "${MSYSTEM:-}" != "UCRT64" ]]; then
  echo "ERROR: please run this script inside MSYS2 UCRT64 shell."
  echo "Current MSYSTEM=${MSYSTEM:-unknown}"
  exit 1
fi

PREFIX="${MINGW_PACKAGE_PREFIX:-mingw-w64-ucrt-x86_64}"

echo "[1/5] Updating pacman database/system..."
pacman -Syu --noconfirm

echo "[2/5] Installing base MSYS tools..."
pacman -S --needed --noconfirm \
  base-devel \
  git \
  openssh \
  zsh \
  tmux \
  vim \
  nano \
  less \
  tree \
  unzip \
  zip \
  p7zip \
  rsync \
  curl \
  wget \
  tar \
  patch \
  diffutils \
  grep \
  sed \
  gawk \
  make \
  pkgconf \
  ca-certificates

echo "[3/5] Installing UCRT64 C/C++ toolchain..."
pacman -S --needed --noconfirm \
  "${PREFIX}-toolchain" \
  "${PREFIX}-cmake" \
  "${PREFIX}-ninja" \
  "${PREFIX}-clang" \
  "${PREFIX}-clang-tools-extra" \
  "${PREFIX}-gdb" \
  "${PREFIX}-lld" \
  "${PREFIX}-llvm" \
  "${PREFIX}-pkgconf" \
  "${PREFIX}-python" \
  "${PREFIX}-python-pip"

echo "[4/5] Configuring zsh..."

# Symlink .zshrc → chezmoi source's zshrc_minimal
# MSYS2 $HOME is /home/finkzhang, but chezmoi source lives under Windows user dir.
# Use cygpath to reliably convert Windows paths to MSYS2 paths.
WIN_HOME="$(cygpath -u "$USERPROFILE")"
CHEZMOI_SOURCE="$WIN_HOME/.local/share/chezmoi"
ZSHRC_SRC="$CHEZMOI_SOURCE/dot_zshrc.d/zshrc_minimal"
ZSHRC="$HOME/.zshrc"

if [[ -f "$ZSHRC_SRC" ]]; then
  if [[ -L "$ZSHRC" ]]; then
    echo "  .zshrc symlink already exists, skipping."
  elif [[ -f "$ZSHRC" ]]; then
    echo "  .zshrc already exists, skipping."
  else
    ln -sfn "$ZSHRC_SRC" "$ZSHRC"
    echo "  Created symlink: .zshrc → zshrc_minimal"
  fi
fi

echo "[4.5/5] Writing platform-specific scripts to ~/.local/scripts/..."

SCRIPTS_DIR="$HOME/.local/scripts"
mkdir -p "$SCRIPTS_DIR"

_write_script() {
  local name="$1"
  local file="$SCRIPTS_DIR/$name"
  if [[ -f "$file" ]]; then
    echo "  $name already exists, skipping."
    return
  fi
  cat > "$file"
  chmod +x "$file"
  echo "  Created $name"
}

_write_script pacucrt <<'SCRIPT'
#!/usr/bin/env bash
prefix="${MINGW_PACKAGE_PREFIX:-mingw-w64-ucrt-x86_64}"
pkgs=()
for p in "$@"; do
  pkgs+=("${prefix}-${p}")
done
pacman -S --needed "${pkgs[@]}"
SCRIPT

_write_script pacucrtu <<'SCRIPT'
#!/usr/bin/env bash
prefix="${MINGW_PACKAGE_PREFIX:-mingw-w64-ucrt-x86_64}"
pkgs=()
for p in "$@"; do
  pkgs+=("${prefix}-${p}")
done
pacman -R --recursive "${pkgs[@]}"
SCRIPT

echo "[4.6/5] Creating symlinks in MSYS2 home → chezmoi-managed files..."

# chezmoi deploys to Windows user dir, but MSYS2 $HOME is /home/finkzhang.
# Symlink so MSYS2 sees the same files.

# .zshrc.d/ → chezmoi source
if [[ -d "$CHEZMOI_SOURCE/dot_zshrc.d" ]]; then
  if [[ -L "$HOME/.zshrc.d" ]]; then
    echo "  .zshrc.d symlink already exists, skipping."
  elif [[ -d "$HOME/.zshrc.d" ]]; then
    echo "  .zshrc.d is a real directory, skipping."
  else
    ln -sfn "$CHEZMOI_SOURCE/dot_zshrc.d" "$HOME/.zshrc.d"
    echo "  Created symlink: .zshrc.d → chezmoi source"
  fi
fi

# .tmux.conf → chezmoi-deployed file under Windows user dir
TMUX_CONF_WIN="$WIN_HOME/.tmux.conf"
if [[ -f "$TMUX_CONF_WIN" ]]; then
  if [[ -L "$HOME/.tmux.conf" ]]; then
    echo "  .tmux.conf symlink already exists, skipping."
  elif [[ -f "$HOME/.tmux.conf" ]]; then
    echo "  .tmux.conf already exists, skipping."
  else
    ln -sfn "$TMUX_CONF_WIN" "$HOME/.tmux.conf"
    echo "  Created symlink: .tmux.conf → chezmoi-deployed"
  fi
fi

# Clone TPM if not present
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
  echo "  Cloning tmux plugin manager..."
  mkdir -p "$HOME/.tmux/plugins"
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  echo "  TPM already installed, skipping."
fi

# Install tmux plugins
if [[ -f "$HOME/.tmux.conf" ]]; then
  echo "  Installing tmux plugins..."
  "$TPM_DIR/bin/install_plugins" || true
fi



# Also let bash jump into zsh automatically when launched by default MSYS2 scripts.
BASHRC="$HOME/.bashrc"
touch "$BASHRC"

if ! grep -q "### auto exec zsh from bash ###" "$BASHRC"; then
  cat >> "$BASHRC" <<'EOF'

### auto exec zsh from bash ###
if [[ -t 1 && -z "${ZSH_VERSION:-}" && -x /usr/bin/zsh ]]; then
  exec /usr/bin/zsh -l
fi
### auto exec zsh from bash ###
EOF
fi

echo "[5/5] Verifying..."
echo "MSYSTEM=$MSYSTEM"
echo "MINGW_PACKAGE_PREFIX=$PREFIX"
gcc --version | head -n 1 || true
g++ --version | head -n 1 || true
clang --version | head -n 1 || true
clangd --version | head -n 1 || true
cmake --version | head -n 1 || true
ninja --version || true
git --version || true
zsh --version || true
tmux -V || true

echo
echo "Done."
echo "Restart UCRT64 shell. It should enter zsh automatically."
