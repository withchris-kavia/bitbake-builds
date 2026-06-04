#!/bin/zsh
# Workspace-local helper for running Yocto/OpenEmbedded tools on macOS zsh.
# Fixes:
# 1) oe-init-build-env assumes GNU `readlink -f`, but macOS/BSD readlink is incompatible.
# 2) This machine's default Homebrew python3 (3.14.5) has a broken pyexpat module.
#
# Usage:
#   source ../.kavia/bin/yocto-macos-env.zsh   # from layers/openembedded-core
#   . ./oe-init-build-env build
#   bitbake core-image-minimal

setopt no_nomatch 2>/dev/null || true

_THIS_DIR="${0:A:h}"
if [[ -z "$_THIS_DIR" || "$_THIS_DIR" == "." ]]; then
  _THIS_DIR="$(cd "$(dirname "${(%):-%N}")" && pwd)"
fi

mkdir -p "$_THIS_DIR"

if command -v /opt/homebrew/bin/greadlink >/dev/null 2>&1; then
  ln -sf /opt/homebrew/bin/greadlink "$_THIS_DIR/readlink"
fi

cat > "$_THIS_DIR/python3" <<'EOF'
#!/bin/zsh
if command -v /opt/homebrew/bin/python3.13 >/dev/null 2>&1; then
  exec /opt/homebrew/bin/python3.13 "$@"
elif command -v /opt/homebrew/bin/python3.12 >/dev/null 2>&1; then
  exec /opt/homebrew/bin/python3.12 "$@"
elif command -v /opt/homebrew/bin/python3.11 >/dev/null 2>&1; then
  exec /opt/homebrew/bin/python3.11 "$@"
else
  exec /usr/bin/python3 "$@"
fi
EOF
chmod +x "$_THIS_DIR/python3"

export PATH="$_THIS_DIR:$PATH"
