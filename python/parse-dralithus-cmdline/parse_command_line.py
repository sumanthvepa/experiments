from typing import NamedTuple

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


class Option(NamedTuple):
  """
    A class representing an option with its name and value.
    :param name: The name of the option.
    :param value: The value of the option.
  """
  name: str
  value: bool | int | str | list[str]


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
    options, increment = get_multi_option_name_and_value(arg, next_arg)
  else:
    raise ValueError(f"Invalid option: {arg}")
  return options, increment


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