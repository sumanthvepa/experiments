"""
  parse_command_line_new.py: Define an alternate parse_command_line function
"""

from dralithus.options import Options

def parse_command_line(args: list[str]) \
    -> tuple[dict[str, None | bool | int | str | set[str]], set[str]]:
  """
    Parse command line arguments and return a dictionary of options and
    remaining arguments.

    :param args: The command line arguments
    :return: A tuple containing a dictionary of options and a list of
      remaining arguments
  """
  options = Options(args)
  parameters = args[options.end_index:]
  environments = options.get('environments')
  if not environments:
    raise ValueError('No environments specified')
  if not parameters:
    raise ValueError('No parameters specified')
  return dict(options), set(parameters)
