#!/usr/bin/env bash
# setup_full.sh  –  Python (pyenv), Node.js (nvm), PHP (asdf-php) egy helyen
# futtatás:  bash setup_full.sh myenv 3.11.3 20.19.2 8.3.28
#                                ^Python     ^Node   ^PHP
set -euo pipefail

PYENV_VER="${2:-3.11.3}"
NODE_VER="${3:-20.19.2}"
PHP_VER="${4:-8.3.28}"
ENV_NAME="${1:-codex_env}"

### ───────────────  PYTHON  ───────────────
if ! command -v pyenv >/dev/null; then
  curl https://pyenv.run | bash
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

pyenv install -s "$PYENV_VER"
if ! pyenv commands | grep -q '^virtualenv$'; then
  git clone https://github.com/pyenv/pyenv-virtualenv.git "$(pyenv root)"/plugins/pyenv-virtualenv
  eval "$(pyenv virtualenv-init -)"
fi
pyenv virtualenv "$PYENV_VER" "$ENV_NAME"
pyenv local "$ENV_NAME"
python -m pip install --upgrade pip wheel setuptools
pip install openai tiktoken pandas

### ───────────────  NODE.JS & JAVASCRIPT  ───────────────
if ! command -v nvm >/dev/null; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  export NVM_DIR="$HOME/.nvm";  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

nvm install "$NODE_VER"
nvm alias default "$NODE_VER"
corepack enable   # Yarn & pnpm automatikusan
npm i -g eslint typescript ts-node

### ───────────────  PHP  ───────────────
if ! command -v asdf >/dev/null; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
  . "$HOME/.asdf/asdf.sh"
fi

# PHP plugin + telepítés
asdf plugin-add php https://github.com/asdf-community/asdf-php.git || true
asdf install php "$PHP_VER"
asdf global  php "$PHP_VER"

### ───────────────  KÉSZ  ───────────────
echo -e "\n✅  Python $PYENV_VER (env: $ENV_NAME)  •  Node $NODE_VER  •  PHP $PHP_VER készen áll."
echo   "➜  Python env aktiválása:   source $(pyenv root)/versions/$ENV_NAME/bin/activate"
echo   "➜  Node használata:         nvm use $NODE_VER"
echo   "➜  PHP ellenőrzés:          php -v"
