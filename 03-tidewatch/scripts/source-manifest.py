#!/usr/bin/env python3
"""Fingerprint current application, build scripts and tests, excluding generated output."""
from pathlib import Path
import hashlib
import sys
root = Path(__file__).resolve().parent.parent
files = [p for name in ['entry/src', 'AppScope', 'scripts', 'tests', 'hvigor']
         for p in (root / name).rglob('*') if p.is_file() and '__pycache__' not in p.parts]
files += [root / name for name in ['build-profile.json5', 'oh-package.json5', 'hvigorfile.ts',
                                  'entry/build-profile.json5', 'entry/oh-package.json5', 'entry/hvigorfile.ts']]
manifest = ''.join(f'{hashlib.sha256(p.read_bytes()).hexdigest()}  {p.relative_to(root)}\n' for p in sorted(files))
if len(sys.argv) > 1:
    Path(sys.argv[1]).write_text(manifest)
print(hashlib.sha256(manifest.encode()).hexdigest())
