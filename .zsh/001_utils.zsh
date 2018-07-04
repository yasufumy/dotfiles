# setup pyenv
if [[ -x "${HOME}/.pyenv/bin/pyenv" ]]; then
    # For git-cloned pyenv.
    path=(${HOME}/.pyenv/bin(N-/^W) ${path})
    export PYENV_ROOT=$(pyenv root)
    eval "$(pyenv init - --no-rehash)"
elif (( $+commands[pyenv] )); then
    # For Homebrew installed pyenv.
    export PYENV_ROOT=$(pyenv root)
    eval "$(pyenv init - --no-rehash)"
fi

# gitignore command
function gi() {
    curl -L -s https://www.gitignore.io/api/$@;
}
