"""
  test_sqlite3_prompt_database: Unit tests for SqlLite3PromptDatabase
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
from datastore.sqlite3_prompt_database import Sqlite3PromptDatabase


def clean_up(db_name):
  """ Delete the test database after tests have been completed."""
  try:
    os.unlink(db_name)
  except FileNotFoundError:
    pass


class TestSqlite3PromptDatabase(unittest.TestCase):
  """
    Unit tests for SqlLite3PromptDatabase
  """
  def test_store_and_load_answer(self):
    """
      Test that the store and load methods work correctly by
      storing an answer into the db and then retrieving it.
    """
    db_name = 'test-sqlite3-load_store.sqlite'
    try:
      question = 'test question'
      answer = 'test_answer'
      db = Sqlite3PromptDatabase(db_name)
      self.assertIsNone(db.load_answer(question))
      db.store_answer(question, answer)
      self.assertEqual(answer, db.load_answer(question))
    finally:
      clean_up(db_name)
