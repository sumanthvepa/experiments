from typing import List, Tuple, Dict, Union

def parse_command_line(args: List[str]) -> Tuple[Dict[str, Union[str, int, bool]], List[str]]:
  """
  Parses command-line arguments into options and positional parameters.

  Args:
      args (List[str]): Command-line arguments (excluding the program name).

  Returns:
      Tuple[Dict[str, Union[str, int, bool]], List[str]]: A tuple containing a dictionary of options and a list of positional parameters.
  """
  options = {'v': 0, 'h': False}
  positional_params = []
  i = 0

  while i < len(args):
    arg = args[i]
    if arg.startswith('--'):
      if '=' in arg:
        key, value = arg[2:].split('=', 1)
        if key in ['verbose', 'verbosity']:
          options['v'] += 1
        elif key in ['env', 'environment']:
          options['env'] = value
        elif key == 'help':
          options['h'] = True
      else:
        key = arg[2:]
        if key in ['verbose', 'verbosity']:
          options['v'] += 1
        elif key in ['env', 'environment']:
          i += 1
          options['env'] = args[i]
        elif key == 'help':
          options['h'] = True
    elif arg.startswith('-'):
      if len(arg) > 2:
        for char in arg[1:]:
          if char == 'v':
            options['v'] += 1
          elif char == 'h':
            options['h'] = True
      else:
        key = arg[1]
        if key == 'v':
          if i + 1 < len(args) and not args[i + 1].startswith('-'):
            i += 1
            options['v'] = int(args[i])
          else:
            options['v'] += 1
        elif key == 'h':
          options['h'] = True
        elif key == 'e':
          i += 1
          options['env'] = args[i]
    else:
      positional_params.append(arg)
    i += 1

  return options, positional_params