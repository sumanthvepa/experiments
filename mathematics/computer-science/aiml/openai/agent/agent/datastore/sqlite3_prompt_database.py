"""
  sqlite3_prompt_database.py: An interface to a SQLite3 database
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

from typing import Any, Optional
import sqlite3
from datastore.prompt_database import PromptDatabase


class Sqlite3PromptDatabase(PromptDatabase):
  """ A proxy to an SQLite3 database"""
  def __init__(self, db_name: str):
    """
    Create a new database proxy

    It establishes a connection to the database upon creation.

    :param db_name: Name of the SQLLite database file
    """
    self.connection = sqlite3.connect(db_name)
    # Open the db and create the qanda table if it
    # does not exist.
    cursor = self.connection.cursor()
    sql = 'CREATE TABLE IF NOT EXISTS qanda(' \
          + 'question_hash  CHAR(32) NOT NULL PRIMARY KEY,' \
          + 'answer TEXT NOT NULL);'
    cursor.execute(sql)

  def _execute_sql(
        self,
        sql,
        parameters: Optional[tuple] = None,
        fetchone: bool = False) -> Any:
    """

    :param sql: The SQL to be executed.
    :param parameters:  A tuple containing the parameters to be passed
      to the SQL statement
    :param fetchone:  True if only zero or one element is expected,
      False otherwise.
    :return:
    """
    cursor = self.connection.cursor()
    if parameters is not None:
      result = cursor.execute(sql, parameters)
    else:
      result = cursor.execute(sql)
    if fetchone:
      data = result.fetchone()
      return None if data is None else data[0]
    return result.fetchall()

  def load_answer(self, question: str) -> Optional[str]:
    """
    Retrieve an answer from an SQLite3 database.

    :param question: The question for which an answer is sought.
    :return: A string containing the answer to the question or None
            if there is no answer found.
    """
    question_hash = self._make_question_hash(question)
    sql = 'SELECT answer FROM qanda WHERE question_hash = ?'
    return self._execute_sql(sql, parameters=(question_hash,), fetchone=True)

  def store_answer(self, question: str, answer: str):
    """

    :param question:
    :param answer:
    :return:
    """
    question_hash = self._make_question_hash(question)
    sql = 'INSERT INTO qanda (question_hash, answer) VALUES (?, ?)'
    self._execute_sql(sql, parameters=(question_hash, answer))
    self.connection.commit()
