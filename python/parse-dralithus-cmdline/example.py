from dralithus.options import Options

def parse(arg: list[str]):
  # Parse the command line 
  options = Options(args)
  parameters = args[options.end_index:]

  # Get the value of an option
  environments = options['environment']
