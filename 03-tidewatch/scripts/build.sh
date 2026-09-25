#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
DEVECO_ROOT="${DEVECO_ROOT:-/Applications/DevEco-Studio.app/Contents}"
export DEVECO_SDK_HOME="$DEVECO_ROOT/sdk"
export JAVA_HOME="$DEVECO_ROOT/jbr/Contents/Home"
export PATH="$DEVECO_ROOT/tools/node/bin:$DEVECO_ROOT/tools/ohpm/bin:$PATH"
node "$DEVECO_ROOT/tools/hvigor/bin/hvigorw.js" --mode module -p product=default -p module=entry@default assembleHap --no-daemon --no-incremental --stacktrace
