#!/usr/bin/env python3
"""
  askgpt: Sends a question to GPT-3.5 and returns a response.
"""
#--------------------------------------------------------------------
# agent.py: A python script to ask OpenAI's GPT-3.5 a coding question
#
# Copyright (C) 2024 Sumanth Vepa.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#--------------------------------------------------------------------

import os
import sys
from datastore.sqlite3_prompt_database import Sqlite3PromptDatabase
from ai.openai_agent import OpenAIAgent
from ai.intelligent_agent import DeterministicAgent


def main(argv):
  """
    Process questions from the command line.
  """
  db = Sqlite3PromptDatabase('interactions.sqlite')
  agent = OpenAIAgent(os.environ.get('OPENAI_API_KEY'))
  deterministic_agent = DeterministicAgent(agent, db)
  for question in argv[1:]:
    print(deterministic_agent.ask(question))


if __name__ == '__main__':
  main(sys.argv)
