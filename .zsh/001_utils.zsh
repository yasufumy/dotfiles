# setup pyenv
if [[ -x "${HOME}/.pyenv/bin/pyenv" ]]; then
    # For git-cloned pyenv.
    export PYENV_ROOT="${HOME}/.pyenv"
    path=(${PYENV_ROOT}/bin(N-/^W) ${path})
    eval "$(pyenv init - --no-rehash)"
elif (( $+commands[pyenv] )); then
    # For Homebrew installed pyenv.
    eval "$(pyenv init - --no-rehash)"
fi
