# syntax=docker/dockerfile:1.7

FROM python:3.12.13-slim-bookworm@sha256:4766d8b510c428e595d74b9cc5bbb2fae8e26316fffb4adc89908d79aacd58a2 AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_NO_CACHE=1 \
    UV_PYTHON_DOWNLOADS=never \
    UV_LINK_MODE=copy \
    PATH="/app/.venv/bin:${PATH}"

RUN groupadd --system --gid 10001 appuser \
    && useradd \
        --system \
        --uid 10001 \
        --gid appuser \
        --no-create-home \
        --shell /usr/sbin/nologin \
        appuser

WORKDIR /app

COPY pyproject.toml uv.lock ./

RUN pip install --no-cache-dir uv==0.12.5 \
    && uv sync --frozen --no-dev

COPY --chown=10001:10001 app app

USER 10001:10001

EXPOSE 8000

CMD ["/app/.venv/bin/uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--no-access-log"]
