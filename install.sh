DOTPATH=~/.dotfiles
GITHUB_URL="https://github.com/yasufume/dotfiles.git"
# is_exists returns true if executable $1 exists in $PATH
function is_exists() {
    type "$1" >/dev/null 2>&1; return $?;
}
# has is wrapper function
function has() {
    is_exists "$@"
}

# git が使えるなら git
if has "git"; then
    git clone --recursive "$GITHUB_URL" "$DOTPATH"
else
    echo "git required"
fi

cd ~/.dotfiles
if [ $? -ne 0 ]; then
    echo "not found: $DOTPATH"
fi

# 移動できたらリンクを実行する
for f in .??*; do
    [ "$f" = ".git" ] && continue

    ln -snfv "$DOTPATH/$f" "$HOME/$f"
done
