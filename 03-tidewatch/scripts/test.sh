#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
DEVECO_ROOT="${DEVECO_ROOT:-/Applications/DevEco-Studio.app/Contents}"
TEST_NODE="${TEST_NODE:-$DEVECO_ROOT/tools/node/bin/node}"
TEST_TSC="${TEST_TSC:-$DEVECO_ROOT/tools/hvigor/hvigor/node_modules/typescript/bin/tsc}"
TIDEWATCH_TEST_BUILD="$(mktemp -d)"
export TIDEWATCH_TEST_BUILD
trap 'rm -rf "$TIDEWATCH_TEST_BUILD"' EXIT
"$TEST_NODE" "$TEST_TSC" --strict --target ES2020 --module commonjs --outDir "$TIDEWATCH_TEST_BUILD" entry/src/main/ets/data/Observation.ts entry/src/main/ets/data/ObservationRepository.ts entry/src/main/ets/data/ObservationSchema.ts
"$TEST_NODE" --test tests/*.test.cjs
