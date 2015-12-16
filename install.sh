DOTPATH=~/.dotfiles
GITHUB_URL="https://github.com/yasfmy/dotfiles.git"

# git が使えるなら git
if type "git" >/dev/null 2>&1; then
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
