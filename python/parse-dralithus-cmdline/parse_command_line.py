import re

from typing import NamedTuple


class Option(NamedTuple):
  """
    A class representing an option with its name and value.
    :param name: The name of the option.
    :param value: The value of the option.
  """
  name: str
  value: bool | int | str | list[str]


def get_option_name(value: str) -> str:
  """
    Get the option name from the given value.
    The value could be a single character or a string. For example
    'e' or 'env' or 'environment'. All three are valid option names
    and represent the 'environment' option.

    :param value: The value to get the option name from.
    :return: The canonical option name.
  """
  if value == 'h' or value == 'help':
    return 'help'
  if value == 'v' or value == 'verbose' or value == 'verbosity':
    return 'verbosity'
  if value == 'e' or value == 'env' or value == 'environment':
    return 'environment'
  raise ValueError(f'Invalid option name: {value}')

def is_option(arg: str) -> bool:
  """
    Check if the argument is an option.

    :param arg: The argument to check.
    :return True if the argument is an option, False otherwise.
  """
  return arg.startswith('-') and len(arg) > 1 and not arg[1].isdigit()


def is_parameter(arg: str) -> bool:
  """
    Check if the argument is a parameter.
    :param arg: The argument to check.
    :return:  True if the argument is a parameter, False otherwise.
  """
  return len(arg) > 0 \
    and not is_option(arg) \
    and arg != '--' \
    and not arg[0].isdigit() \
    and arg[0] != '-'


def is_short_option(arg: str) -> bool:
  """
    Check if the argument is a short option.

    :param arg: The argument to check.
    :return: True if the argument is a short option, False otherwise.
  """
  # -v -v2 -v=2 -e=test -e=local,test are all valid short options
  if arg.startswith('-') and len(arg) > 1:
    if len(arg) == 2 and arg[1].isalpha():
      return True
    elif len(arg) > 2 and arg[1].isalpha():
      if arg[2] == '=' and re.match(is_short_option.PATTERN, arg[3:]):
        return True
      else:
        for c in arg[2:]:
          if not c.isdigit():
            return False
        return True
  return False

is_short_option.PATTERN = re.compile(r'^[a-zA-Z0-9,]+$')

def is_long_option(arg: str) -> bool:
  """
    Check if the argument is a long option.

    :param arg: The argument to check.
    :return: True if the argument is a long option, False otherwise.
  """
  return arg.startswith('--') and len(arg) > 2


def is_multi_option(arg: str) -> bool:
  """
    Check if the argument is a multi-option.
    :param arg: The argument to check.
    :return: True if the argument is a multi-option, False otherwise.
  """
  if arg.startswith('-') and len(arg) > 2:
      for c in arg[1:]:
        if not c.isalpha():
          return False
      return True
  return False

def requires_value(option_name: str) -> bool:
  """
    Check if the option requires a value.
    :param option_name: The name of the option.
    :return: True if the option requires a value, False otherwise.
  """
  return option_name in ['environment']


def permits_value(option_name: str) -> bool:
  """
    Check if the option permits a value.
    :param option_name: The name of the option.
    :return: True if the option permits a value, False otherwise.
  """
  return requires_value(option_name) or option_name in ['verbosity']


def is_valid_environment(values: list[str]) -> bool:
  """
    Check if the environment value is valid.
    :param values: The environment values to check
    :return: True if the environment value is valid, False otherwise.
  """
  valid_environments = ['local', 'dev', 'test', 'staging', 'alpha', 'beta', 'prod']
  for value in values:
    if value not in valid_environments:
      return False
  return True


def is_option_value(option_name: str, value: bool | int | str | list[str]) -> bool:
  """
    Check if the argument is a valid option value.
    :param option_name: The name of the option.
    :param value: The value to check.
    :return: True if the argument is a valid option value, False otherwise.
  """
  if option_name == 'environment':
    return is_valid_environment(value)
  if option_name == 'verbosity':
    return value.isdecimal()and int(value) >= 0
  return False


def option_value_type(option_name: str) -> type:
  """
    Get the type of the option value.
    :param option_name: The name of the option.
    :return: The type of the option value.
  """
  if option_name == 'verbosity':
    return int
  if option_name == 'environment':
    return list[str]
  raise ValueError(f'{option_name} has no permitted value type')

def convert_to_type(required_type: type, value: str) -> bool | int | str | list[str]:
  """
    Convert the value to the specified type.
    :param required_type: The type to convert to.
    :param value: The value to convert
    :return: The converted value.
  """
  if required_type == bool:
    if value.lower() == 'true' or value == '1':
      return True
    elif value.lower() == 'false' or value == '0':
      return False
    else:
      raise ValueError(f'Invalid boolean value: {value}')
  if required_type == int:
    return int(value)
  if required_type == str:
    return str(value)
  if required_type == list[str]:
    return value.split(',')
  raise ValueError(f'Invalid type: {required_type}')


def default_option_value(option_name: str) -> int:
  """
    Get the default value for the options that have permitted values.

    For options with permitted_values but not required values, this
    function specifies what the default value should be when no
    value is provided.

    Right now only verbosity is supported.

    :param option_name: The name of the option.
    :return: The default value for the option.
  """
  if option_name == 'verbosity':
    return 1
  raise ValueError(f'{option_name} has no permitted default value')

def get_short_option_name_and_value(arg: str, next_arg: str) -> tuple[Option, int]:
  """
    Get the option name and its value from the short option argument.
    :param arg: The short option argument.
    :param next_arg: The next argument, in case the current one requires a value.
    :return: A tuple containing an Option object and an increment value.
  """
  # This precondition should be met before this function is called.
  assert is_short_option(arg)
  option_name = get_option_name(arg[1])
  if requires_value(option_name):
    if len(arg) > 2:
      if arg[2] == '=':
        option_value = arg[3:]
      else:
        option_value = arg[2:]
      # Cast the value to the appropriate type
      option_value = convert_to_type(option_value_type(option_name), option_value)
      option = Option(option_name, option_value)
      increment = 1
    else:
      if next_arg is not None and is_option_value(option_name, next_arg):
        # Cast the value to the appropriate type
        option_value = convert_to_type(option_value_type(option_name), next_arg)
        option = Option(option_name, option_value)
        increment = 2
      else:
        raise ValueError(f"Option {option_name} requires a value")
  elif permits_value(option_name):
    if len(arg) > 2:
      if arg[2] == '=':
        option_value = arg[3:]
      else:
        option_value = arg[2:]
      # Cast the value to the appropriate type
      option_value = convert_to_type(option_value_type(option_name), option_value)
      option = Option(option_name, option_value)
      increment = 1
    else:
      if next_arg is not None and is_option_value(option_name, next_arg):
        # Cast the value to the appropriate type
        option_value = convert_to_type(option_value_type(option_name), next_arg)
        option = Option(option_name, option_value)
        increment = 2
      else:
        option = Option(option_name, default_option_value(option_name))
        increment = 1
  else:
    option = Option(option_name, True)
    increment = 1
  return option, increment


def get_long_option_name_and_value(arg: str, next_arg: str) -> tuple[Option, int]:
  """
    Get the option name and its value from the long option argument.
    :param arg: The long option argument.
    :param next_arg: The next argument, in case the current one requires a value.
    :return: A tuple containing an Option object and an increment value.
  """
  # This precondition should be met before this function is called.
  assert is_long_option(arg)
  if '=' in arg:
    option_name, option_value = arg[2:].split('=', 1)
    option_name = get_option_name(option_name)
    option_value = convert_to_type(option_value_type(option_name), option_value)
    if not permits_value(option_name):
      raise ValueError(f"Option {option_name} does not take a value")
    option = Option(option_name, option_value)
    increment = 1
  else:
    option_name = get_option_name(arg[2:])
    if requires_value(option_name):
      if next_arg is not None:
        option_value = convert_to_type(option_value_type(option_name), next_arg)
        if is_option_value(option_name, option_value):
          option = Option(option_name, option_value)
          increment = 2
        else:
          raise ValueError(f"{next_arg} is not a valid value for {option_name}")
      else:
        raise ValueError(f"Option {option_name} requires a value")
    elif permits_value(option_name):
      if next_arg is not None and is_option_value(option_name, next_arg):
        option_value = convert_to_type(option_value_type(option_name), next_arg)
        option = Option(option_name, option_value)
        increment = 2
      else:
        option = Option(option_name, True)
        increment = 1
    else:
      option = Option(option_name, True)
      increment = 1
  return option, increment


def get_multi_option_name_and_value(arg: str) -> tuple[list[Option], int]:
  """
    Get the option name and its value from the multi-option argument.
    :param arg: The multi-option argument.
    :return: A list of Option objects and an increment value.
  """
  # This precondition should be met before this function is called.
  assert is_multi_option(arg)
  options: list[Option] = []
  increment = 1
  for c in arg[1:]:
    assert c.isalpha()
    option_name = get_option_name(c)
    options.append(Option(option_name, True))
  return options, increment


def get_options(arg: str, next_arg: str) -> tuple[list[Option], int]:
  """
    Get the option name and its value from the argument and the next argument

    :param arg: The argument to check.
    :param next_arg: The next argument, in case the current one requires a value.
    :return: Returns a tuple consisting of a list of Option objects and an increment value.
    The increment value indicates how many arguments to skip in the next iteration.
    A value of 1 means to skip the next argument, while a value of 2 means to
    skip the next two arguments.
  """
  options: list[Option] = []
  if not is_option(arg):
    raise ValueError(f"Invalid option: {arg}")
  if is_short_option(arg):
    option, increment  = get_short_option_name_and_value(arg, next_arg)
    options.append(option)
  elif is_long_option(arg):
    option, increment = get_long_option_name_and_value(arg, next_arg)
    options.append(option)
  elif is_multi_option(arg):
    options, increment = get_multi_option_name_and_value(arg)
  else:
    raise ValueError(f"Invalid option: {arg}")
  return options, increment


def add_to_options_dict(options: dict[str, bool | int | str | list[str]], option_list: list[Option]) -> None:
  """
    Add an option and its value to the 'options' dictionary.

    Do the right thing for the option being added:
    - If the option is 'help', set it to True in the dictionary.
    - If the option is 'verbosity', either increment the verbosity level or set it to the sum of
      the current verbosity level and the new value.
    - If the option is 'environment', set it to the value provided.

    :param options: The options dictionary to update.
    :param option_list: The list of Option objects to add.
  """
  for option in option_list:
    if option.name == 'help':
      options['help'] = True
    elif option.name == 'verbosity':
      if not isinstance(option.value, int):
        raise ValueError(f"Invalid value for verbosity: {option.value}")
      options['verbosity'] = options['verbosity'] + option.value
    elif option.name == 'environment':
      if isinstance(option.value, list) \
          and all(isinstance(element, str) for element in option.value) \
          and is_valid_environment(option.value):
        options['environment'] += option.value
      else:
        raise ValueError(f"Invalid value for environment: {option.value}")
    else:
      raise ValueError(f"Unknown option: {option.name}")


def validate_command_line(options: dict[str, bool | int | str | list[str]], parameters: list[str]) -> None:
  """
    Raise an exception if the command line arguments are invalid.

    :param options: The options dictionary to validate.
    :param parameters: The list of positional parameters to validate.
    :return: None.
  """
  if options['help'] is False and len(options['environment']) == 0:
    raise ValueError("No environment provided")
  if options['help'] is False and len(parameters) == 0:
    raise ValueError("No positional parameters provided")


def parse_command_line(args: list[str]) -> tuple[dict[str, str | int | bool], list[str]]:
  """
    Parses command-line arguments into options and positional parameters.

    :param args: Command-line arguments (excluding the program name).
    :return: A tuple containing a dictionary of options and a list of positional parameters.
  """
  options: dict[str, bool | int | str | list[str]] = {
    'help': False,
    'verbosity': 0,
    'environment': []
  }
  parameters: list[str] = []
  try:
    i: int = 0
    while i < len(args):
      # Value 1: means do not skip the next argument, 2 means skip it
      increment = 1
      arg: str = args[i]
      next_arg: str = args[i + 1] if i + 1 < len(args) else None
      if is_option(arg):
        # increment is 1 if the next argument is not the value for the
        # current argument, and 2 if it is.
        option_list, increment = get_options(arg, next_arg)
        add_to_options_dict(options, option_list)
      elif is_parameter(arg):
        parameters.append(arg)
      else:
        raise ValueError(f"Unknown argument: {arg}")
      i += increment
    validate_command_line(options, parameters)
  except ValueError as ex:
    print(f'{ex}\n')
    options['help'] = True
  return options, parameters
