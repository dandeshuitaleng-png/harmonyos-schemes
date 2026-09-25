"""Evidence bookkeeping for device smoke runs; never reuses a prior PASS."""
from datetime import datetime, timezone
import json
from pathlib import Path
import re
import uuid


def validate_command(returncode, stdout, stderr):
    if returncode or re.search(r'error:|failed to|illegal argument|not connected|no such file', stdout + stderr, re.I):
        raise RuntimeError((stdout + stderr).strip() or f'Command exited {returncode}')
    return stdout


class EvidenceRun:
    def __init__(self, root, device):
        stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')
        self.directory = Path(root).resolve() / f'{stamp}-{uuid.uuid4().hex[:8]}'
        self.directory.mkdir(parents=True, exist_ok=False)
        self.data = {'device': device, 'started_at': stamp, 'checks': [], 'status': 'RUNNING'}
        self.write()

    def write(self):
        temp = self.directory / 'result.tmp'
        temp.write_text(json.dumps(self.data, ensure_ascii=False, indent=2) + '\n')
        temp.replace(self.directory / 'smoke-results.json')

    def check(self, label):
        self.data['checks'].append(label)
        self.write()

    def finish(self, error=None):
        self.data['status'] = 'PASS' if error is None else 'FAIL'
        if error is not None:
            self.data['error'] = str(error)
        self.write()
