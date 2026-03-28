"""
  Take a data set and scale it to a range specified by the user
"""

def slurp(filename: str) -> str:
  """
    Read the contents of a file
    :param filename: File to read
    :return: File contents
  """
  with open(filename, 'r', encoding='utf-8') as file:
    return file.read()

def scale(
    data: list[tuple[float, float]],
    min_x: float,
    max_x: float,
    min_y: float,
    max_y: float) -> list[tuple[float, float]]:
  """
    Scale data to a new range
    :param data: The data to scale
    :param min_x:
    :param max_x:
    :param min_y:
    :param max_y:
    :return:
  """
  scaled: list[tuple[float, float]] = []
  for x, y in data:
    x_scaled = (x - min_x) / (max_x - min_x)
    y_scaled = (y - min_y) / (max_y - min_y)
    scaled.append((x_scaled, y_scaled))
  return scaled
