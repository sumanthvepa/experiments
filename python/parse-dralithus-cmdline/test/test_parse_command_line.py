import unittest
from parse_command_line import parse_command_line

class TestParseCommandLine(unittest.TestCase):
    def test_no_arguments(self):
        args = []
        expected_options = {'v': 0, 'h': False}
        expected_positional = []
        self.assertEqual(parse_command_line(args), (expected_options, expected_positional))

    def test_single_short_option(self):
        args = ['-v']
        expected_options = {'v': 1, 'h': False}
        expected_positional = []
        self.assertEqual(parse_command_line(args), (expected_options, expected_positional))

    def test_single_long_option(self):
        args = ['--verbose']
        expected_options = {'v': 1, 'h': False}
        expected_positional = []
        self.assertEqual(parse_command_line(args), (expected_options, expected_positional))

    def test_combined_short_options(self):
        args = ['-vv']
        expected_options = {'v': 2, 'h': False}
        expected_positional = []
        self.assertEqual(parse_command_line(args), (expected_options, expected_positional))

    def test_option_with_value(self):
        args = ['--env', 'test']
        expected_options = {'v': 0, 'h': False, 'env': 'test'}
        expected_positional = []
        self.assertEqual(parse_command_line(args), (expected_options, expected_positional))

    def test_positional_arguments(self):
        args = ['application1', 'application2']
        expected_options = {'v': 0, 'h': False}
        expected_positional = ['application1', 'application2']
        self.assertEqual(parse_command_line(args), (expected_options, expected_positional))

    def test_mixed_arguments(self):
        args = ['-v', '--env', 'test', 'application1']
        expected_options = {'v': 1, 'h': False, 'env': 'test'}
        expected_positional = ['application1']
        self.assertEqual(parse_command_line(args), (expected_options, expected_positional))

    def test_help_option(self):
        args = ['-h']
        expected_options = {'v': 0, 'h': True}
        expected_positional = []
        self.assertEqual(parse_command_line(args), (expected_options, expected_positional))

if __name__ == '__main__':
    unittest.main()