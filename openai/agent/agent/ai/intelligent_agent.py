"""
  intelligent_agent.py: An interface to an intelligent agent.
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

import abc
from datastore.prompt_database import PromptDatabase


class IntelligentAgent(metaclass=abc.ABCMeta):
  """
    An interface to an intelligent agent.
  """
  # pylint: disable=too-few-public-methods
  @abc.abstractmethod
  def ask(self, question: str) -> str:
    """
      Ask the agent a question.

      In general the output of such an agent is not
      deterministic.

      :param question: The question being asked.
      :return: A string containing an answer to the question.
    """


class DeterministicAgent(IntelligentAgent):
  """
    A deterministic agent that always returns the same answer to
    the same question.
  """
  # pylint: disable=too-few-public-methods
  agent: IntelligentAgent
  db: PromptDatabase

  def __init__(self, agent: IntelligentAgent, db: PromptDatabase):
    """
      Initialize a deterministic agent.

      :param agent: A handle to an intelligent agent object. This
        is the agent that will be queried to get an answer if one
        cannot be found in the database
      :param db: A handle to a prompt database. This database is
        checked for the existence of an answer before a query is
        made to the underlying agent.
    """
    self.agent = agent
    self.db = db

  def ask(self, question: str) -> str:
    """
      Ask the agent a question.
      This implementation of the method will always return the
      same answer to the same question.

      :param question: The question being asked.
      :return: A string containing an answer to the question.
    """
    answer = self.db.load_answer(question)
    if answer is None:
      answer = self.agent.ask(question)
      self.db.store_answer(question, answer)
    return answer
