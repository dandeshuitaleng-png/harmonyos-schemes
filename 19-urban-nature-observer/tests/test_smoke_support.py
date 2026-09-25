import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('smoke_support', Path(__file__).resolve().parents[1] / 'scripts/smoke_support.py')
support = importlib.util.module_from_spec(spec)
spec.loader.exec_module(support)

class SmokeEvidenceTests(unittest.TestCase):
    def test_failure_cannot_inherit_previous_pass(self):
        with tempfile.TemporaryDirectory() as root:
            old = support.EvidenceRun(root, 'device')
            old.finish()
            new = support.EvidenceRun(root, 'device')
            self.assertNotEqual(old.directory, new.directory)
            new.check('only first step')
            new.finish(RuntimeError('window lost'))
            data = json.loads((new.directory / 'smoke-results.json').read_text())
            self.assertEqual(data['status'], 'FAIL')
            self.assertEqual(data['checks'], ['only first step'])
            self.assertEqual(data['error'], 'window lost')
            self.assertEqual(json.loads((old.directory / 'smoke-results.json').read_text())['status'], 'PASS')

    def test_incomplete_run_is_not_pass(self):
        with tempfile.TemporaryDirectory() as root:
            run = support.EvidenceRun(root, 'device')
            self.assertEqual(json.loads((run.directory / 'smoke-results.json').read_text())['status'], 'RUNNING')

    def test_hdc_errors_are_detected_even_with_zero_exit_code(self):
        for output in ['msg:error: install failed', 'failed to start ability', 'Illegal argument: foo', 'No such file']:
            with self.assertRaises(RuntimeError):
                support.validate_command(0, output, '')
        with self.assertRaises(RuntimeError):
            support.validate_command(1, '', 'unavailable')
        self.assertEqual(support.validate_command(0, 'start ability successfully.', ''), 'start ability successfully.')

if __name__ == '__main__':
    unittest.main()
