"""
  fuzzymatch.py: Explore fuzzy matching techniques to identify similar
  filenames.
"""
from typing import NamedTuple
from rapidfuzz import process, fuzz


class Painter(NamedTuple):
  """
    A class representing a painter
  """
  s_no: int
  name: str


def group_filenames_by_painter(
  painters: list[Painter],
  filenames: list[str],
  threshold: float = 25.0) -> dict[Painter, list[str]]:
  """
    Group filenames by painter using fuzzy matching. All filenames that match
    a painter's name with a score above a certain threshold are grouped under
    that painter's name.
    :param painters: list of painters to group
    :param filenames: list of filenames to group
    :param threshold: minimum score to consider a match
    :return: dictionary mapping painter names to lists of filenames
  """
  # Initialize the dictionary with empty lists for each painter
  painter_files: dict[Painter, list[str]] = {p: [] for p in painters}
  painter_names = [p.name for p in painters]  # Get a list of painter names
  # Map painter names to Painter objects
  painters_dict: dict[str, Painter] = {p.name: p for p in painters}

  for filename in filenames:
    # Find the best match for the filename among painter names
    # noinspection PyTypeChecker
    result = process.extractOne(
      filename,
      painter_names,
      scorer=fuzz.token_set_ratio,
      processor=str.lower)
    if result is None:
      continue
    match, score, _ = result
    if score >= threshold:
      painter = painters_dict[match]
      painter_files[painter].append(filename)

  return painter_files


# noinspection SpellCheckingInspection
def main() -> None:
  """
    Main function to demonstrate fuzzy matching of filenames to painters.
  """
  painters = [
    Painter(1, 'pablo-picasso'),
    Painter(2, 'jackson-pollock'),
    Painter(3, 'henri-matisse'),
    Painter(4, 'salvador-dali'),
    Painter(5, 'piet-modrian'),
    Painter(6, 'wassily-kandinsky'),
    Painter(7, 'mark-rothko'),
    Painter(8, 'georgia-okeeffe'),
    Painter(9, 'edward-hopper'),
    Painter(10, 'frida-kahlo')
  ]
  filenames = [
    'jackson pollock 40A question 1 - Jackson Pollock.R',
    'Salvador36AQ1 - SALVADOR DALI IPM 2024.r',
    'GeorgiaOKeefe_38A-Q1 - GEORGIA OKEEFFE IPM 2024.r',
    'jackson pollock 40A question 2 - Jackson Pollock.R',
    'Salvador36AQ3 - SALVADOR DALI IPM 2024.r',
    'jackson pollock 40A question 3 - Jackson Pollock.R',
    'GeorgiaOKeefe_38A-Q2 - GEORGIA OKEEFFE IPM 2024.r',
    'GeorgiaOKeefe_38A-Q3 - GEORGIA OKEEFFE IPM 2024.r',
    'jackson pollock 40A question 4 - Jackson Pollock.R',
    'Salvador36AQ2 - Salvador DaliIPM 2024.r',
    'GeorgiaOKeefe_38A-Q4 - GEORGIA OKEEFFE IPM 2024.r',
    'Salvador36AQ1 - Salvador Dali IPM 2024.r'
  ]
  painter_files = group_filenames_by_painter(painters, filenames)
  for painter, files in painter_files.items():
    normalize
  print(painter_files)


if __name__ == '__main__':
  main()
