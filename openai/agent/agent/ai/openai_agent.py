"""
  openai_agent.py: An OpenAI intelligent agent that talks to a
    GPT3.5 LLM.
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

from openai import OpenAI
from ai.intelligent_agent import IntelligentAgent


class OpenAIAgent(IntelligentAgent):
  """
    An OpenAI intelligent agent that talks to a GPT 3.5 turbo LLM
  """
  # pylint: disable=too-few-public-methods
  client: OpenAI

  def __init__(self, api_key):
    """
    Create a new OpenAI agent.

    This creates a client object that is used to communicate
    with the OpenAI REST service.

    :param api_key: The OpenAI api key.
    """
    self.client = OpenAI(api_key=api_key)

  def ask(self, question: str) -> str:
    """
      Ask the agent a question.

      This results in a call to the OpenAI rest API with
      the question.

      The api call injects some system prompt text
      to dissuade the LLM from adding polite verbiage
      before and after requests to generate code.

      :param question: The question being asked.
      :return: A string containing an answer to the question.
    """
    completion = self.client.chat.completions.create(
      model='gpt-3.5-turbo',
      messages=[
        {'role': 'system',
         'content': 'When asked to generate code, '
                    + 'DO NOT preface your output with any '
                    + 'English text. Also do not add any '
                    + 'explanations after the code. You may '
                    + 'include comments in the code if you wish.'},
        {'role': 'user', 'content': question}])
    return completion.choices[0].message.content \
        if completion.choices[0].message.content is not None else ''
