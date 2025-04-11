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
  if arg.startswith('-'):
    if len(arg) == 2 and arg[1].isalpha():
      return True
    elif len(arg) > 2:
      if arg[1].isalpha():
        for c in arg[2:]:
          if not c.isdigit():
            return False
        return True
  return False


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


def is_valid_environment(value: str) -> bool:
  """
    Check if the environment value is valid.
    :param value: The environment value to check.
    :return: True if the environment value is valid, False otherwise.
  """
  return value in ['local', 'dev', 'test', 'staging', 'alpha', 'beta', 'prod']

def is_option_value(option_name: str, value: str) -> bool:
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
      option_value = arg[2:]
      option = Option(option_name, option_value)
      increment = 1
    else:
      if next_arg is not None and is_option_value(option_name, next_arg):
        option_value = next_arg
        option = Option(option_name, option_value)
        increment = 2
      else:
        raise ValueError(f"Option {option_name} requires a value")
  elif permits_value(option_name):
    if len(arg) > 2:
      option_value = arg[2:]
      option = Option(option_name, option_value)
      increment = 1
    else:
      if next_arg is not None and is_option_value(option_name, next_arg):
        option_value = next_arg
        option = Option(option_name, option_value)
        increment = 2
      else:
        option = Option(option_name, True)
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
    if not permits_value(option_name):
      raise ValueError(f"Option {option_name} does not take a value")
    option = Option(option_name, option_value)
    increment = 1
  else:
    option_name = get_option_name(arg[2:])
    if requires_value(option_name):
      if next_arg is not None and is_option_value(option_name, next_arg):
        option_value = next_arg
        option = Option(option_name, option_value)
        increment = 2
      else:
        raise ValueError(f"Option {option_name} requires a value")
    elif permits_value(option_name):
      if next_arg is not None and is_option_value(option_name, next_arg):
        option_value = next_arg
        option = Option(option_name, option_value)
        increment = 2
      else:
        option = Option(option_name, True)
        increment = 1
    else:
      option = Option(option_name, True)
      increment = 1
  return option, increment


def get_multi_option_name_and_value(arg: str, next_arg: str) -> tuple[list[Option], int]:
  """
    Get the option name and its value from the multi-option argument.
    :param arg: The multi-option argument.
    :param next_arg: The next argument, in case the current one requires a value.
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
      if isinstance(option.value, str) and option.value.isdecimal():
        options['verbosity'] = options['verbosity'] + int(option.value)
      else:
        raise ValueError(f"Invalid value for verbosity: {option.value}")
    elif option.name == 'environment':
      if isinstance(option.value, str) and is_valid_environment(option.value):
        values = option.value.split(',')
        options['environment'] += values
      else:
        raise ValueError(f"Invalid value for environment: {option.value}")
    else:
      raise ValueError(f"Unknown option: {option.name}")

def parse_command_line(args: list[str]) -> tuple[dict[str, str | int | bool], list[str]]:
  """
    Parses command-line arguments into options and positional parameters.

    :param args: Command-line arguments (excluding the program name).
    :return: A tuple containing a dictionary of options and a list of positional parameters.
  """
  options: dict[str, str | int | bool] = {'v': 0, 'h': False}
  parameters: list[str] = []
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
  return options, parameters