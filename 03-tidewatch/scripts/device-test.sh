#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [ "$#" -ne 1 ]; then echo 'Usage: ./scripts/device-test.sh <dedicated-emulator-hdc-target>' >&2; exit 2; fi
DEVECO_ROOT="${DEVECO_ROOT:-/Applications/DevEco-Studio.app/Contents}"
HDC="$DEVECO_ROOT/sdk/default/openharmony/toolchains/hdc"
TEST_PROJECT="$(mktemp -d /tmp/tidewatch-native.XXXXXX)"
export TEST_PROJECT
trap 'rm -rf "$TEST_PROJECT"' EXIT
python3 - <<'PY'
import os,json,shutil
from pathlib import Path
src=Path.cwd();dst=Path(os.environ['TEST_PROJECT'])
for name in ['AppScope','entry','hvigor','scripts']:
 shutil.copytree(src/name,dst/name,ignore=shutil.ignore_patterns('build','.hvigor','oh_modules','.preview'))
for name in ['build-profile.json5','hvigorfile.ts','oh-package.json5']:shutil.copy(src/name,dst/name)
app=json.loads((dst/'AppScope/app.json5').read_text());app['app']['bundleName']='com.harmonyradar.tidewatch.rdbtest'
(dst/'AppScope/app.json5').write_text(json.dumps(app))
shutil.copy(src/'tests/device/RdbIntegration.ets',dst/'entry/src/main/ets/pages/Index.ets')
PY
mkdir -p docs/evolution/evidence
"$TEST_PROJECT/scripts/build.sh" > docs/evolution/evidence/T002-native-build.txt 2>&1
"$HDC" -t "$1" install -r "$TEST_PROJECT/entry/build/default/outputs/default/entry-default-unsigned.hap"
"$HDC" -t "$1" shell aa force-stop com.harmonyradar.tidewatch.rdbtest
"$HDC" -t "$1" shell rm -f /data/app/el2/100/base/com.harmonyradar.tidewatch.rdbtest/haps/entry/files/rdb-report.json
"$HDC" -t "$1" shell aa start -a EntryAbility -b com.harmonyradar.tidewatch.rdbtest
for attempt in $(seq 1 30); do
 if "$HDC" -t "$1" file recv /data/app/el2/100/base/com.harmonyradar.tidewatch.rdbtest/haps/entry/files/rdb-report.json docs/evolution/evidence/T002-native-report.json 2>&1 | grep -q 'FileTransfer finish'; then
  python3 - <<'PY'
import json
from pathlib import Path
r=json.loads(Path('docs/evolution/evidence/T002-native-report.json').read_text())
print(json.dumps(r,ensure_ascii=False,indent=2))
assert r['failed']==0 and r['passed']>=11, 'Native integration failed'
PY
  exit 0
 fi
 sleep 1
done
echo 'No native test report returned; inspect the dedicated emulator.' >&2
exit 1
