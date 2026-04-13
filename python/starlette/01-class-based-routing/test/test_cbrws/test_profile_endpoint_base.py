"""
  test_profile_endpoint_base.py: Unit tests for profile endpoint helpers.
"""
import asyncio
import tempfile
import unittest
from pathlib import Path

from cbrws.profile_endpoint_base import ProfileEndpointBase


class TestProfileEndpointBase(unittest.TestCase):
  """
    Unit tests for ProfileEndpointBase.
  """
  def test_load_json_returns_object_json(self) -> None:
    """
      Test that load_json returns object JSON documents.
      :return: None
    """
    with tempfile.TemporaryDirectory() as temp_dir:
      filename = Path(temp_dir) / 'object.json'
      filename.write_text('{"name": "{{ name }}"}', encoding='utf-8')
      data = asyncio.run(ProfileEndpointBase.load_json(
        str(filename),
        {'name': 'cbrws'}))
    self.assertEqual({'name': 'cbrws'}, data)

  def test_load_json_rejects_non_object_json(self) -> None:
    """
      Test that load_json rejects non-object JSON documents.
      :return: None
    """
    with tempfile.TemporaryDirectory() as temp_dir:
      filename = Path(temp_dir) / 'array.json'
      filename.write_text('[]', encoding='utf-8')
      with self.assertRaisesRegex(
            ValueError,
            'JSON document must be an object'):
        asyncio.run(ProfileEndpointBase.load_json(str(filename), {}))
