""" Parse syslog messages from a file """
import re
from datetime import datetime


def parse(line: str) -> dict[str, str | datetime | None]:
  """
  Parses a single syslog line (without <PRI> prefix).

  :param line: syslog line to parse
  :return: A dictionary with parsed components of the syslog message.
  """
  # Regex to match BSD syslog format
  syslog_pattern = re.compile(
    r'^(?P<timestamp>\w{3}\s+\d{1,2}\s+\d{2}:\d{2}:\d{2})\s+'
    r'(?P<hostname>\S+)\s+'
    r'(?P<tag>\w+)(?:\[(?P<pid>\d+)\])?:\s+'
    r'(?P<message>.+)$'
  )

  match = syslog_pattern.match(line)
  if not match:
    raise ValueError("Line does not match expected syslog format")

  parts = match.groupdict()

  # Parse timestamp (year is not included in syslog; assume current year)
  try:
    current_year = datetime.now().year
    parts['timestamp'] = datetime.strptime(
      f"{current_year} {parts['timestamp']}",
      "%Y %b %d %H:%M:%S"
    )
  except ValueError:
    # Leave timestamp as string if parsing fails
    pass

  return parts


def parse_syslog_file(filepath: str) -> None:
  """
  Reads syslog messages from a file and parses them using syslog-rfc5424-parser.
  Prints each parsed SyslogMessage object to stdout.

  Lines that fail to parse will be skipped with an error message.
  """
  with open(filepath, encoding='utf-8') as f:
    for lineno, line in enumerate(f, start=1):
      line = line.strip()
      if not line:
        continue  # Skip blank lines

      try:
        msg = parse(line)
        print(msg)
      except ValueError as ex:
        print(f"[Line {lineno}] Failed to parse: {ex}")


if __name__ == "__main__":
  parse_syslog_file('messages.log')
