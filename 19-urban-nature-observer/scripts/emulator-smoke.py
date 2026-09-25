#!/usr/bin/env python3
"""Exercise only this app. Run on a dedicated API >=23 emulator with no concurrent UI automation."""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import time
from smoke_support import EvidenceRun, validate_command

parser = argparse.ArgumentParser()
parser.add_argument('--device', required=True)
parser.add_argument('--output', default='docs/development/evidence')
args = parser.parse_args()
hdc = os.environ.get('HDC', '/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/hdc')
bundle = 'com.hongmengoutputs.urbannature'
evidence = EvidenceRun(args.output, args.device)
out = evidence.directory
print(f'EVIDENCE {out}', flush=True)
work = Path(tempfile.mkdtemp(prefix='nature19-ui-'))
width, height = 1084, 2412

def run(*cmd):
    result = subprocess.run([hdc, '-t', args.device, *cmd], capture_output=True, text=True, timeout=45)
    return validate_command(result.returncode, result.stdout, result.stderr)

def dump():
    global width, height
    run('shell', 'uitest', 'dumpLayout', '-b', bundle, '-p', '/data/local/tmp/nature19-test.json')
    run('file', 'recv', '/data/local/tmp/nature19-test.json', str(work / 'layout.json'))
    data = json.loads((work / 'layout.json').read_text())
    bounds = list(map(int, re.findall(r'-?\d+', data.get('attributes', {}).get('bounds', ''))))
    if len(bounds) == 4:
        width, height = bounds[2] - bounds[0], bounds[3] - bounds[1]
    nodes = []
    def visit(node):
        a = node.get('attributes', {})
        if a.get('text'):
            nodes.append(a)
        for child in node.get('children', []):
            visit(child)
    visit(data)
    if not nodes:
        raise RuntimeError('App is not visible; stop rather than operate on another app')
    return nodes

def swipe(up):
    dump()  # Stop before injecting input if the target window disappeared.
    x, top, bottom = str(width // 2), str(int(height * .2)), str(int(height * .8))
    run('shell', 'uitest', 'uiInput', 'swipe', x, bottom if up else top, x, top if up else bottom, '2500')
    time.sleep(.12)

def find(text, direction=True):
    for _ in range(9):
        for n in dump():
            if n['text'] == text:
                coords = list(map(int, re.findall(r'-?\d+', n['bounds'])))
                x1, y1, x2, y2 = coords
                if y1 >= height * .05 and y2 <= height * .95 and y2-y1 >= 30:
                    return n, ((x1+x2)//2, (y1+y2)//2)
        swipe(direction)
    raise AssertionError(f'Cannot find {text}')

def click(text, direction=True):
    n, (x, y) = find(text, direction)
    assert n.get('enabled') != 'false', text
    run('shell', 'uitest', 'uiInput', 'click', str(x), str(y))
    time.sleep(.15)

def expect(text, direction=True):
    find(text, direction)
    evidence.check(text)
    print('PASS', text, flush=True)

def shot(name):
    dump()
    run('shell', 'uitest', 'screenCap', '-p', '/data/local/tmp/nature19-shot.png')
    run('file', 'recv', '/data/local/tmp/nature19-shot.png', str(out / (name+'.png')))

def restart():
    run('shell', 'aa', 'force-stop', bundle)
    run('shell', 'aa', 'start', '-a', 'EntryAbility', '-b', bundle)
    time.sleep(.6)

try:
    restart()
    # This script refuses to delete pre-existing observations.
    expect('本机观察 · 0/10')
    shot('01-empty')
    click('叶缘', False)
    click('公园')
    click('边缘看起来平滑')
    click('暂时看不清')
    expect('暂时看不清 · 已选择')
    expect('边缘看起来平滑', False)
    click('边缘看起来平滑')
    expect('暂时看不清')
    click('保存本次观察到本机')
    expect('本机观察 · 1/10')
    expect('公园 · 叶缘')
    shot('02-saved')
    restart()
    expect('本机观察 · 1/10')
    expect('公园 · 叶缘')
    expect('边缘看起来平滑')
    shot('03-restored')
    click('再次观察同类特征')
    expect('叶缘 · 已选择')
    expect('公园 · 已选择')
    expect('边缘看起来平滑')
    click('暂时看不清')
    click('保存本次观察到本机')
    expect('本机观察 · 2/10')
    click('删除这条观察')
    click('取消')
    expect('本机观察 · 2/10', False)
    click('删除这条观察')
    click('确认删除')
    expect('本机观察 · 1/10', False)
    restart()
    expect('本机观察 · 1/10')
    click('清空全部本机观察')
    shot('04-delete-confirm')
    click('确认删除')
    expect('本机观察 · 0/10', False)
    restart()
    expect('本机观察 · 0/10')
    shot('05-empty-after-restart')
    evidence.finish()
    print('PASS emulator smoke completed', flush=True)
except BaseException as error:
    evidence.finish(error)
    raise
