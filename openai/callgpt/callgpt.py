#!/usr/bin/env python3
"""
  callgpt.py: A script to test the OpenAI API by making a call to it.
"""
# -------------------------------------------------------------------
#  callgpt.py: A script to test the OpenAI API by making a call to it
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
# -------------------------------------------------------------------

import os
from openai import OpenAI

client = OpenAI(api_key=os.environ.get('OPENAI_API_KEY'))

COMPLETION = client.chat.completions.create(
  model='gpt-3.5-turbo',
  messages=[
    {'role': 'system', 'content': "You are a large language model."},
    {'role': 'user', 'content': 'Write a Python function is_prime ' +
                                'that returns true if its input is ' +
                                'a prime number'}
  ]
)

response = COMPLETION.choices[0].message.content
print(response)
