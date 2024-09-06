# syntax=docker/dockerfile:1.9
FROM python:3.12-slim AS build
SHELL ["sh", "-exc"]

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PYTHON_DOWNLOADS=never \
    UV_PYTHON=python3.12 \
    UV_PROJECT_ENVIRONMENT=/app

COPY pyproject.toml /_lock/
COPY uv.lock /_lock/

RUN --mount=type=cache,target=/root/.cache <<EOT
cd /_lock
uv sync \
    --frozen \
    --no-dev \
    --no-install-project
EOT

COPY . /src
RUN --mount=type=cache,target=/root/.cache <<EOT
cd /src
uv sync --frozen --no-dev

# Works here! :)
/app/bin/python -Ic 'import tc'

# The following works:
# uv pip install \
#     --python=$UV_PROJECT_ENVIRONMENT \
#     --no-deps \
#     /src
EOT


##########################################################################

FROM python:3.12-slim
SHELL ["sh", "-exc"]

COPY --from=build /app /app

RUN <<EOT
/app/bin/python -V
/app/bin/python -Im site

ls -al /app/lib/python3.12/site-packages

# But not here! :(
/app/bin/python -Ic 'import tc'
EOT
