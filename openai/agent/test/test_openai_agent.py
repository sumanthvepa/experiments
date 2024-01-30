"""
  test_openai_agent.py: Unit tests for the OpenAI agent.
"""
#--------------------------------------------------------------------
# This file is part of agent, a program to call OpenAIs GPT3.5 LLM
# to ask coding questions
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
import unittest
from ai.openai_agent import OpenAIAgent


class TestOpenAIAgent(unittest.TestCase):
  """
    Unit tests for the OpenAIAgent class.
  """
  def test_ask(self):
    """
      Test that the ask function returns a non-zero length string.
      This just tests that the API returns something. Not whether
      what it returns is meaningful. It would need a more powerful AI
      to make sense of the answer.
    """
    agent = OpenAIAgent(os.environ.get('OPENAI_API_KEY'))
    answer = agent.ask(
      'Write a Python function that given a non-negative integer n '
      + 'returns true if it is prime, and false otherwise.')
    self.assertTrue(len(answer) > 1)
