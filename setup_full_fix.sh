#!/usr/bin/env bash
#   usage:  bash setup_full_fix.sh myenv 3.12.0 22.2.0 8.3.latest
set -euo pipefail

ENV_NAME="${1:-codex_env}"
PY_VER="${2:-3.12.0}"
NODE_VER="${3:-22.2.0}"
PHP_VER_REQ="${4:-8.3.latest}"        # 8.3.latest = mindig a legfrissebb 8.3.x

# ───── PYTHON (pyenv + virtualenv) ─────
if ! command -v pyenv &>/dev/null; then
  curl https://pyenv.run | bash
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi
pyenv install -s "$PY_VER"
if ! pyenv commands | grep -q '^virtualenv$'; then
  git clone https://github.com/pyenv/pyenv-virtualenv.git \
            "$(pyenv root)"/plugins/pyenv-virtualenv
  eval "$(pyenv virtualenv-init -)"
fi
pyenv virtualenv "$PY_VER" "$ENV_NAME"
pyenv local "$ENV_NAME"
python -m pip install --upgrade pip wheel setuptools
pip install openai tiktoken pandas

# ───── NODE (nvm) ─────
if ! command -v nvm &>/dev/null; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh"
fi
nvm install "$NODE_VER"
nvm alias default "$NODE_VER"
corepack enable

# ───── PHP (asdf-php) ─────
if ! command -v asdf &>/dev/null; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
  . "$HOME/.asdf/asdf.sh"
fi
asdf plugin-add php https://github.com/asdf-community/asdf-php.git || true

# — ha “x.latest” formátumot kaptunk, válaszd ki a legnagyobb patchet —
if [[ "$PHP_VER_REQ" == *".latest" ]]; then
  BASE="${PHP_VER_REQ%%.latest}"                       # pl. 8.3
  PHP_VER=$(asdf list-all php | grep "^$BASE\." | tail -1)
else
  PHP_VER="$PHP_VER_REQ"
fi

echo "➡  PHP verzió, amit telepítek: $PHP_VER"
asdf install php "$PHP_VER"
asdf global  php "$PHP_VER"

echo -e "\n✅  Python $PY_VER (env: $ENV_NAME)  •  Node $NODE_VER  •  PHP $PHP_VER készen!"
echo "➜  Python env:  source $(pyenv root)/versions/$ENV_NAME/bin/activate"
echo "➜  Node:        nvm use $NODE_VER"
echo "➜  PHP:         php -v"
