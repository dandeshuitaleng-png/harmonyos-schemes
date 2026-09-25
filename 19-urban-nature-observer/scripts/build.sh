#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
DEVECO_APP="${DEVECO_APP:-/Applications/DevEco-Studio.app}"
export DEVECO_SDK_HOME="$DEVECO_APP/Contents/sdk"
export JAVA_HOME="$DEVECO_APP/Contents/jbr/Contents/Home"
export PATH="$DEVECO_APP/Contents/tools/node/bin:$DEVECO_APP/Contents/tools/ohpm/bin:$PATH"
node "$DEVECO_APP/Contents/tools/hvigor/bin/hvigorw.js" --mode module -p product=default -p module=entry@default assembleHap --no-daemon --no-incremental "$@"
