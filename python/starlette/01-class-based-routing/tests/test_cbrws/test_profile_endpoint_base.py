"""
  test_profile_endpoint_base.py: Unit tests for profile endpoint helpers.
"""
import asyncio
import tempfile
import unittest
from pathlib import Path

from starlette import status
from starlette.applications import Starlette
from starlette.routing import Route
from starlette.testclient import TestClient

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

  def test_get_and_head_negotiate_with_supported_media_types(self) -> None:
    """
      Test that response negotiation uses SUPPORTED_MEDIA_TYPES.
      :return: None
    """
    with tempfile.TemporaryDirectory() as temp_dir:
      schema_dir = Path(temp_dir)
      (schema_dir / 'custom.jinja2').write_text('<h1>Custom</h1>', encoding='utf-8')
      (schema_dir / 'custom.json').write_text('{"name": "custom"}', encoding='utf-8')

      class CustomProfileEndpoint(ProfileEndpointBase):
        """
          A profile endpoint with a deliberately restricted media type list.
        """
        SCHEMA_DIR = schema_dir
        HTML_FILENAME = 'custom.jinja2'
        JSON_FILENAME = 'custom.json'
        RESPONSE_MEDIA_TYPE = 'application/hal+json'
        SUPPORTED_MEDIA_TYPES = ['text/html']

      app = Starlette(routes=[
        Route('/custom', CustomProfileEndpoint, name='custom_endpoint')
      ])
      client = TestClient(app, 'http://localhost:5101')

      for method in ('GET', 'HEAD'):
        with self.subTest(method=method):
          response = client.request(
            method,
            '/custom',
            headers={'Accept': 'application/hal+json'})

          self.assertEqual(status.HTTP_406_NOT_ACCEPTABLE, response.status_code)
          self.assertEqual(
            'application/problem+json',
            response.headers['content-type'])
