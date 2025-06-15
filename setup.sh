#!/usr/bin/env bash
# setup.sh – “tökéletes” Python környezet OpenAI-/Codex-projektekhez
#---------------------------------------------------------------
set -euo pipefail

#— Konfigurálható változók —#
PROJECT_NAME="${1:-codex_env}"   # első paraméter vagy alapértelmezés
PY_VERSION="${2:-3.11.3}"        # második paraméter vagy default

echo "🔧  Projekt: $PROJECT_NAME   •   Python: $PY_VERSION"

# 1) pyenv + pyenv-virtualenv biztosítása
if ! command -v pyenv >/dev/null 2>&1; then
  echo "📥  pyenv telepítése…"
  curl https://pyenv.run | bash
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

# 2) Python letöltése és virtuális környezet
pyenv install -s "$PY_VERSION"
pyenv virtualenv "$PY_VERSION" "$PROJECT_NAME"
pyenv local "$PROJECT_NAME"

# 3) pip & alapcsomagok frissítése
python -m pip install --upgrade pip wheel setuptools

# 4) Kötelező és ajánlott csomaglista írása
cat > requirements.txt <<'REQ'
# --- futásidő ---
openai>=1.21
tiktoken
requests
aiohttp
pandas
numpy
pydantic
fastapi[all]
uvicorn[standard]

# --- fejlesztés/teszt ---
black
isort
flake8
mypy
pytest
pytest-asyncio
pre-commit
REQ

pip install -r requirements.txt

# 5) pre-commit hookok beállítása
cat > .pre-commit-config.yaml <<'PC'
repos:
  - repo: https://github.com/psf/black
    rev: 24.4.2
    hooks: [{id: black}]
  - repo: https://github.com/pycqa/isort
    rev: 5.13.2
    hooks: [{id: isort}]
  - repo: https://github.com/PyCQA/flake8
    rev: 7.0.0
    hooks: [{id: flake8}]
PC

pre-commit install

echo -e "\n✅  A '$PROJECT_NAME' környezet elkészült!  Aktiváld így: \e[1msource \$(pyenv root)/versions/$PROJECT_NAME/bin/activate\e[0m"
