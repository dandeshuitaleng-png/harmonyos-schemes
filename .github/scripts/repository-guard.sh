#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "::error::$1" >&2
  exit 1
}

test -f README.md || fail "缺少仓库总览 README.md"

projects=()
while IFS= read -r project; do
  projects+=("$project")
done < <(find . -mindepth 1 -maxdepth 1 -type d -name '[0-9]*-*' -exec basename {} \; | sort -t- -k1,1n)
(( ${#projects[@]} > 0 )) || fail "未发现编号方案目录"

expected=1
for project in "${projects[@]}"; do
  if [[ ! "$project" =~ ^([1-9][0-9]*)- ]]; then
    fail "目录编号格式不正确：$project"
  fi
  number="${BASH_REMATCH[1]}"
  [[ "$number" -eq "$expected" ]] || fail "目录编号必须连续；期望 $expected，实际 $number（$project）"

  test -f "$project/AGENTS.md" || fail "$project 缺少 AGENTS.md"
  test -f "$project/build-profile.json5" || fail "$project 缺少 build-profile.json5"
  grep -Fq "\`$project\`" README.md || fail "README.md 未登记 $project"
  expected=$((expected + 1))
done

if git ls-files | grep -Eiq '(^|/)([^/]+\.(p12|pfx|p7b|pem|key|cer|crt)|signing\.properties|local\.properties|build-profile\.local\.json5)$'; then
  fail "发现不应提交的签名或本地配置文件"
fi

if git ls-files | grep -Eiq '\.(hap|app|appx)$'; then
  fail "发现不应提交的构建产物"
fi

echo "已通过：${#projects[@]} 个方案目录、README 登记和敏感文件检查。"
