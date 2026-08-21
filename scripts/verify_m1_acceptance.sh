#!/usr/bin/env bash
set -eo pipefail

echo "======================================================"
echo "      VieGym Milestone 1 Acceptance Test Suite        "
echo "======================================================"

FAILED=0

pass() {
  echo -e "\033[32m[PASS]\033[0m $1"
}

fail() {
  echo -e "\033[31m[FAIL]\033[0m $1"
  FAILED=$((FAILED + 1))
}

echo ""
echo "--- 1. Testing Backend (Spring Boot & Flyway) ---"
cd backend
if ./mvnw test -q; then
  pass "Backend tests (Flyway migration, Actuator health, API envelopes, Redactor) PASSED"
else
  fail "Backend tests FAILED"
fi
cd ..

echo ""
echo "--- 2. Testing AI Service (FastAPI & Token Guard) ---"
cd ai-service
if uv run ruff check . -q && uv run ruff format --check . -q && uv run pytest -q; then
  pass "AI Service tests (Health, Internal Token Guard, Pydantic contracts) PASSED"
else
  fail "AI Service tests FAILED"
fi
cd ..

echo ""
echo "--- 3. Testing Mobile (Flutter Client & Shared Widgets) ---"
cd mobile
if flutter analyze --no-fatal-infos > /dev/null && flutter test; then
  pass "Mobile tests (Theme, Router, AuthInterceptor, ErrorHandler, Shared UI) PASSED"
else
  fail "Mobile tests FAILED"
fi
cd ..

echo ""
echo "--- 4. Testing Docker Compose Stack Configuration ---"
if docker compose config > /dev/null; then
  pass "Docker Compose stack definition and environment interpolation PASSED"
else
  fail "Docker Compose config validation FAILED"
fi

echo ""
echo "======================================================"
if [ $FAILED -eq 0 ]; then
  echo -e "\033[32m✓ ALL 5 M1 ACCEPTANCE CRITERIA PASSED SUCCESSFULLY!\033[0m"
  exit 0
else
  echo -e "\033[31m✗ $FAILED ACCEPTANCE CHECK(S) FAILED!\033[0m"
  exit 1
fi
