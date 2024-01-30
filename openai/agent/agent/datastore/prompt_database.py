"""
  prompt_database.py: Interface to a LLM prompt database
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
import hashlib
from typing import Optional


class PromptDatabase(metaclass=abc.ABCMeta):
  """
    Interface to an LLM prompt database
  """
  @staticmethod
  def _make_question_hash(question: str) -> str:
    # noinspection GrazieInspection
    """

        :param question: A text string containing the question to be asked.
        :return: A 32-character text string containing the hex digest of
                the question string.
        """
    return hashlib.md5(question.encode()).hexdigest()

  def has_answer(self, question: str) -> bool:
    # noinspection GrazieInspection
    """
      Return true if an answer to the question exists in the prompt database.

      :param question: The question for which an answer is sought.
      :return: True if the answer exists, False otherwise.
    """
    return self.load_answer(question) is not None

  @abc.abstractmethod
  def load_answer(self, question: str) -> Optional[str]:
    # noinspection GrazieInspection
    """
      Retrieve the answer to the given question from the database.

      :param question: The question for which an answer is sought.
      :return: A string containing the answer to the question or None
               if there is no answer found.
    """

  @abc.abstractmethod
  def store_answer(self, question: str, answer: str):
    # noinspection GrazieInspection
    """
      Store the answer to the given question in the database.

      :param question: The question being asked.
      :param answer: The answer to the question being asked
    """
