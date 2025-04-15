import unittest
from parse_command_line import parse_command_line


class TestParseCommandLine(unittest.TestCase):
  def test_no_arguments(self) -> None:
    """
      Test the case when no arguments are provided.

      :return: None
    """
    args: list[str] = []
    expected_options: dict[str, bool | int | str | list[str]] = {'verbosity': 0, 'help': True, 'environment': []}
    expected_parameters: list[str] = []
    expected = (expected_options, expected_parameters)
    actual = parse_command_line(args)
    self.assertEqual(expected, actual)

  def test_single_short_option_verbosity(self) -> None:
    """
      Test the case when a single short option for verbosity is
      provided.

      :return: None
    """
    args: list[str] = ['-v']
    expected_options: dict[str, bool | int | str | list[str]] = {'verbosity': 1, 'help': True, 'environment': []}
    expected_parameters: list[str] = []
    expected = (expected_options, expected_parameters)
    actual = parse_command_line(args)
    self.assertEqual(expected, actual)

  def test_single_short_option_verbosity_with_value(self) -> None:
    """
      Test the case when a single short option with a value is provided.

      :return: None
    """
    args: list[str] = ['-v2']
    expected_options: dict[str, bool | int | str | list[str]] = {'verbosity': 2, 'help': True, 'environment': []}
    expected_parameters: list[str] = []
    expected = (expected_options, expected_parameters)
    actual = parse_command_line(args)
    self.assertEqual(expected, actual)

  def test_single_short_option_verbosity_with_value_equal(self) -> None:
    """
      Test the case when a single short option with a value is provided using an equal sign.

      :return: None
    """
    args: list[str] = ['-v=2']
    expected_options: dict[str, bool | int | str | list[str]] = {'verbosity': 2, 'help': True, 'environment': []}
    expected_parameters: list[str] = []
    expected = (expected_options, expected_parameters)
    actual = parse_command_line(args)
    self.assertEqual(expected, actual)

  def test_sing_le_short_option_verbosity_with_value_space(self) -> None:
    """
      Test the case when a single short option for verbosity is
      provided with a value using a space.

      :return: None
    """
    args: list[str] = ['-v', '2']
    expected_options = {'verbosity': 2, 'help': True, 'environment': []}
    expected_parameters = []
    expected = (expected_options, expected_parameters)
    actual = parse_command_line(args)
    self.assertEqual(expected, actual)

  def test_single_short_option_verbosity_with_wrong_value(self) -> None:
    """
      Test the case when a single short option for verbosity is provided
      with a wrong value.

      :return: None
    """
    args = ['-v=wrong']
    expected_options = {'verbosity': 0, 'help': True, 'environment': []}
    expected_parameters = []
    expected = (expected_options, expected_parameters)
    actual = parse_command_line(args)
    self.assertEqual(expected, actual)

  def test_single_short_option_help(self) -> None:
    """
      Test the case when a single short option for help is provided.

      :return: None
    """
    args = ['-h']
    expected_options = {'verbosity': 0, 'help': True, 'environment': []}
    expected_parameters = []
    expected = (expected_options, expected_parameters)
    actual = parse_command_line(args)
    self.assertEqual(expected, actual)

  def test_single_short_option_help_with_wrong_value(self) -> None:
    """
      Test the case when a single short option for help is provided with
      an unnecessary value.

      :return: None
    """
    args = ['-h=true']
    expected_options = {'verbosity': 0, 'help': True, 'environment': []}
    expected_parameters = []
    expected = (expected_options, expected_parameters)
    actual = parse_command_line(args)
    self.assertEqual(expected, actual)


  def test_single_short_option_environment(self) -> None:
    """
      Test the case when a single short option for environment is provided.

      :return: None
    """
    args = ['-e']
    expected_options = {'verbosity': 0, 'help': True, 'environment': []}
    expected_parameters = []
    expected = (expected_options, expected_parameters)
    actual = parse_command_line(args)
    self.assertEqual(expected, actual)

  def test_single_short_option_environment_with_value(self) -> None:
    """
      Test the case when a single short option for environment is provided
      with a value.

      :return: None
    """
    args = ['-e=test']
    expected_options = {'verbosity': 0, 'help': True, 'environment': ['test']}
    expected_parameters = []
    expected = (expected_options, expected_parameters)
    actual = parse_command_line(args)
    self.assertEqual(expected, actual)

  def test_single_short_option_environment_with_multi_value(self) -> None:
    """
      Test the case when a single short option for environment is provided
      with multiple values.

      :return: None
    """
    args = ['-e=test,local']
    expected_options = {'verbosity': 0, 'help': True, 'environment': ['test', 'local']}
    expected_parameters = []
    expected = (expected_options, expected_parameters)
    actual = parse_command_line(args)
    self.assertEqual(expected, actual)

  def test_single_short_option_environment_with_wrong_value(self) -> None:
    """
      Test the case when a single short option for environment is provided with an
      incorrect value.

      :return: None
    """
    args = ['-e=wrong']
    expected_options = {'verbosity': 0, 'help': True, 'environment': []}
    expected_parameters = []
    expected = (expected_options, expected_parameters)
    actual = parse_command_line(args)
    self.assertEqual(expected, actual)

  def test_single_long_option_verbose(self) -> None:
    """
      Test the case when a single long option for verbosity is provided.

      :return: None
    """
    args: list[str] = ['--verbose']
    expected_options = {'verbosity': 1, 'help': True, 'environment': []}
    expected_parameters = []
    actual = parse_command_line(args)
    expected = (expected_options, expected_parameters)
    self.assertEqual(expected, actual)

  def test_single_long_option_verbose_with_value(self) -> None:
    """
      Test the case when a single long option for verbosity is provided
      with a value.

      :return: None
    """
    args: list[str] = ['--verbose=2']
    expected_options = {'verbosity': 2, 'help': True, 'environment': []}
    expected_parameters = []
    actual = parse_command_line(args)
    expected = (expected_options, expected_parameters)
    self.assertEqual(expected, actual)

  def test_single_long_option_verbosity_with_value(self) -> None:
    """
      Test the case when a single long option for verbosity is provided
      with a value.

      :return: None
    """
    args: list[str] = ['--verbosity=2']
    expected_options = {'verbosity': 2, 'help': True, 'environment': []}
    expected_parameters = []
    actual = parse_command_line(args)
    expected = (expected_options, expected_parameters)
    self.assertEqual(expected, actual)

  def test_single_long_option_help(self) -> None:
    """
      Test the case when a single long option for help is provided.

      :return: None
    """
    args: list[str] = ['--help']
    expected_options = {'verbosity': 0, 'help': True, 'environment': []}
    expected_parameters = []
    actual = parse_command_line(args)
    expected = (expected_options, expected_parameters)
    self.assertEqual(expected, actual)

  def test_single_long_option_environment(self) -> None:
    """
      Test the case when a single long option for environment is provided.

      :return: None
    """
    args: list[str] = ['--environment']
    expected_options = {'verbosity': 0, 'help': True, 'environment': []}
    expected_parameters = []
    actual = parse_command_line(args)
    expected = (expected_options, expected_parameters)
    self.assertEqual(expected, actual)

  def test_single_long_option_env(self) -> None:
    """
    Test the case when a single long option --env is used for environment

    :return: None
    """
    args: list[str] = ['--env']
    expected_options = {'verbosity': 0, 'help': True, 'environment': []}
    expected_parameters = []
    actual = parse_command_line(args)
    expected = (expected_options, expected_parameters)
    self.assertEqual(expected, actual)


  def test_single_long_option_environment_with_value(self) -> None:
    """
    Test the case when a single long option for environment is provided
    with a value.

    :return: None
    """
    args: list[str] = ['--environment=local']
    expected_options = {'verbosity': 0, 'help': True, 'environment': ['local']}
    expected_parameters = []
    actual = parse_command_line(args)
    expected = (expected_options, expected_parameters)
    self.assertEqual(expected, actual)

  def test_single_long_option_env_with_value(self) -> None:
    """
    Test the case when a single long option for environment is provided
    with a value.

    :return: None
    """
    args: list[str] = ['--env=local']
    expected_options = {'verbosity': 0, 'help': True, 'environment': ['local']}
    expected_parameters = []
    actual = parse_command_line(args)
    expected = (expected_options, expected_parameters)
    self.assertEqual(expected, actual)

  def test_single_long_option_environment_with_multi_value(self) -> None:
    """
    Test the case when a single long option for environment is provided with multiple values.

    :return: None
    """
    args: list[str] = ['--environment=local,test']
    expected_options = {'verbosity': 0, 'help': True, 'environment': ['local',  'test']}
    expected_parameters = []
    actual = parse_command_line(args)
    expected = (expected_options, expected_parameters)
    self.assertEqual(expected, actual)

  def test_multi_option_verbose(self) -> None:
    """
      Test the case when multiple short options for verbosity are provided in one
      multi-option argument.

      :return: None
    """
    args: list[str] = ['-vvv']
    expected_options = {'verbosity': 3, 'help': True, 'environment': []}
    expected_parameters = []
    actual = parse_command_line(args)
    expected = (expected_options, expected_parameters)
    self.assertEqual(expected, actual)

  def test_multi_option_verbose_help(self) -> None:
    """
      Test the case when short options for verbosity and help are
      provided in one multi-option argument.

      :return: None
    """
    args: list[str] = ['-vvvh']
    expected_options = {'verbosity': 3, 'help': True, 'environment': []}
    expected_parameters = []
    actual = parse_command_line(args)
    expected = (expected_options, expected_parameters)
    self.assertEqual(expected, actual)

  def test_multi_option_help_help(self) -> None:
    """
      Test the case when short the short option for help is duplicated
      in a multi-option argument.

      :return: None
    """
    args: list[str] = ['-hh']
    expected_options = {'verbosity': 0, 'help': True, 'environment': []}
    expected_parameters = []
    actual = parse_command_line(args)
    expected = (expected_options, expected_parameters)
    self.assertEqual(expected, actual)

  def test_multi_option_verbose_help_help(self) -> None:
    """
      Test the case when short the short option for help is duplicated
      in a multi-option argument.

      :return: None
    """
    args: list[str] = ['-hvh']
    expected_options = {'verbosity': 1, 'help': True, 'environment': []}
    expected_parameters = []
    actual = parse_command_line(args)
    expected = (expected_options, expected_parameters)
    self.assertEqual(expected, actual)


  def test_multi_option_environment_wrong(self) -> None:
    """
      Test the case when multiple short options for verbosity and
      environment are provided in one multi-option argument.

      :return: None
    """
    args: list[str] = ['-vve=local']
    expected_options = {'verbosity': 0, 'help': True, 'environment': []}
    expected_parameters = []
    actual = parse_command_line(args)
    expected = (expected_options, expected_parameters)
    self.assertEqual(expected, actual)

  #
  # def test_option_with_value(self) -> None:
  #     args: list[str] = ['--env', 'test']
  #     expected_options: dict[str, int | bool | str] = {'v': 0, 'h': False, 'env': 'test'}
  #     expected_positional: list[str] = []
  #     self.assertEqual(parse_command_line(args), (expected_options, expected_positional))
  #
  # def test_positional_arguments(self) -> None:
  #     args: list[str] = ['application1', 'application2']
  #     expected_options: dict[str, int | bool] = {'v': 0, 'h': False}
  #     expected_positional: list[str] = ['application1', 'application2']
  #     self.assertEqual(parse_command_line(args), (expected_options, expected_positional))
  #
  # def test_mixed_arguments(self) -> None:
  #     args: list[str] = ['-v', '--env', 'test', 'application1']
  #     expected_options: dict[str, int | bool | str] = {'v': 1, 'h': False, 'env': 'test'}
  #     expected_positional: list[str] = ['application1']
  #     self.assertEqual(parse_command_line(args), (expected_options, expected_positional))
  #
  # def test_help_option(self) -> None:
  #     args: list[str] = ['-h']
  #     expected_options: dict[str, int | bool] = {'v': 0, 'h': True}
  #     expected_positional: list[str] = []
  #     self.assertEqual(parse_command_line(args), (expected_options, expected_positional))


if __name__ == '__main__':
  unittest.main()
