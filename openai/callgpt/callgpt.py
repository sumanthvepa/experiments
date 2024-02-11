#!/usr/bin/env python3

import os
from openai import OpenAI

client = OpenAI(api_key=os.environ.get('OPENAI_API_KEY'))

completion = client.chat.completions.create(
  model='gpt-3.5-turbo',
  messages=[
    {'role': 'system', 'content': "You are a large language model."},
    {'role': 'user', 'content': 'Write a Python function is_prime that returns true if its input is a prime number'}
  ]
)

response = completion.choices[0].message.content
print(response)
