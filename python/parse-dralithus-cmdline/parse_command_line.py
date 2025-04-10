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

def option_name_and_value(arg: str, next_arg: str) -> tuple[str, bool | int | str | list[str], int]:
  """
    Get the option name and its value from the argument and the next argument

    :param arg: The argument to check.
    :param next_arg: The next argument, in case the current one requires a value.
    :return: A tuple containing the option name and its value and how much to
    increment the index by. The increment is 1 if the next argument is not the value
    for the current argument, and 2 if it is.
  """
  # TODO: Implement this
  return 'not-implemented', 'not-implemented', 1

def add_to_options_dict(options: dict[str, str | int | bool ], option: str, value: str | int | bool) -> None:
  """
    Add an option and its value to the 'options' dictionary.

    Do the right thing for the option being added:
    - If the option is 'help', set it to True in the dictionary.
    - If the option is 'verbosity', either increment the verbosity level or set it to the maximum of
      the current verbosity level and the new value.
    - If the option is 'env', set it to the value provided.
    :param options: The options dictionary to update.
    :param option:
    :param value:
    :return:
  """

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
      option, value, increment = option_name_and_value(arg, next_arg)
      add_to_options_dict(options, option, value)
    elif is_parameter(arg):
      parameters.append(arg)
    else:
      raise ValueError(f"Unknown argument: {arg}")
    i += increment
  return options, parameters