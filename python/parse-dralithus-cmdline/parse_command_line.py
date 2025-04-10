def is_option(arg: str) -> bool:
  """
    Check if the argument is an option.

    :param arg: The argument to check.
    :return True if the argument is an option, False otherwise.
  """
  return arg.startswith('-') and len(arg) > 1 and not arg[1].isdigit()


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