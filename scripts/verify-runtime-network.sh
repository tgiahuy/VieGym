#!/usr/bin/env bash

set -euo pipefail

env_file="${1:-.env.example}"
compose=(docker compose --env-file "${env_file}")

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

container_id() {
  "${compose[@]}" ps --all --quiet "$1"
}

assert_health() {
  local service="$1"
  local id
  local health

  id="$(container_id "${service}")"
  [[ -n "${id}" ]] || fail "${service} container is not running"
  health="$(docker inspect --format '{{.State.Health.Status}}' "${id}")"
  [[ "${health}" == "healthy" ]] || fail "${service} is ${health}, expected healthy"
}

assert_network() {
  local service="$1"
  local network="$2"
  local id
  local networks

  id="$(container_id "${service}")"
  [[ -n "${id}" ]] || fail "${service} container does not exist"
  networks="$(docker inspect --format '{{json .NetworkSettings.Networks}}' "${id}")"
  grep -q "\"viegym_${network}\"" <<<"${networks}" || fail "${service} is not attached to ${network}"
}

assert_no_network() {
  local service="$1"
  local network="$2"
  local id
  local networks

  id="$(container_id "${service}")"
  [[ -n "${id}" ]] || fail "${service} container does not exist"
  networks="$(docker inspect --format '{{json .NetworkSettings.Networks}}' "${id}")"
  if grep -q "\"viegym_${network}\"" <<<"${networks}"; then
    fail "${service} must not be attached to ${network}"
  fi
}

"${compose[@]}" config --quiet

for service in backend ai-service postgres minio; do
  assert_health "${service}"
done

minio_init_id="$(container_id minio-init)"
[[ -n "${minio_init_id}" ]] || fail "minio-init container does not exist"
minio_init_status="$(docker inspect --format '{{.State.Status}}:{{.State.ExitCode}}' "${minio_init_id}")"
[[ "${minio_init_status}" == "exited:0" ]] || fail "minio-init is ${minio_init_status}, expected exited:0"

for network in edge-net db-net ai-net storage-net; do
  assert_network backend "${network}"
done

assert_network ai-service ai-net
assert_network ai-service ai-egress-net
assert_no_network ai-service db-net
assert_no_network ai-service storage-net

assert_network postgres db-net
assert_no_network postgres ai-net
assert_no_network postgres storage-net

assert_network minio edge-net
assert_network minio storage-net
assert_no_network minio ai-net
assert_no_network minio db-net

"${compose[@]}" exec -T backend curl --fail --silent --show-error http://ai-service:8000/health >/dev/null
"${compose[@]}" exec -T backend curl --fail --silent --show-error http://minio:9000/minio/health/live >/dev/null
"${compose[@]}" exec -T backend getent hosts postgres >/dev/null

if "${compose[@]}" exec -T ai-service python -c 'import socket; socket.gethostbyname("postgres")' >/dev/null 2>&1; then
  fail "ai-service can resolve postgres"
fi

if "${compose[@]}" exec -T ai-service python -c 'import socket; socket.gethostbyname("minio")' >/dev/null 2>&1; then
  fail "ai-service can resolve minio"
fi

printf 'PASS: healthchecks and runtime network boundaries are valid.\n'
