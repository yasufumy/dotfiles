# setup pyenv
if [[ -x "${HOME}/.pyenv/bin/pyenv" ]]; then
    # For git-cloned pyenv.
    export PYENV_ROOT="${HOME}/.pyenv"
    path=(${PYENV_ROOT}/bin(N-/^W) ${path})
    eval "$(pyenv init - --no-rehash)"
    if [[ -x "${HOME}/.pyenv/plugins/pyenv-virtualenv/bin/pyenv-virtualenv" ]]; then
        eval "$(pyenv virtualenv-init - --no-rehash)"
    fi
elif (( $+commands[pyenv] )); then
    # For Homebrew installed pyenv.
    eval "$(pyenv init - --no-rehash)"
    eval "$(pyenv virtualenv-init - --no-rehash)"
fi
