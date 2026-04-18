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

from cbrws.http_endpoint import (
  HTTPMethods,
  ResponseMediaType,
  SupportedMediaTypes
)
from cbrws.documentation_endpoint import DocumentationEndpoint
from cbrws.documentation_endpoint import (
  HTMLFilename,
  JSONFilename,
  SchemaDir,
  make_html_filename,
  make_json_filename,
  make_schema_dir
)


class TestProfileEndpointBase(unittest.TestCase):
  """
    Unit tests for ProfileEndpointBase.
  """
  def setUp(self) -> None:
    """
      Clear template caches before each test.
      :return: None
    """
    DocumentationEndpoint.HTML_TEMPLATE_CACHE.clear()
    DocumentationEndpoint.JSON_TEMPLATE_CACHE.clear()

  def test_load_html_caches_template_not_content(self) -> None:
    """
      Test that HTML templates are cached while rendered content stays dynamic.
      :return: None
    """
    with tempfile.TemporaryDirectory() as temp_dir:
      filename = Path(temp_dir) / 'custom.jinja2'
      filename.write_text('<p>{{ name }}</p>', encoding='utf-8')

      template = DocumentationEndpoint.load_html_template(str(filename))
      self.assertIs(template, DocumentationEndpoint.load_html_template(str(filename)))

      first_content = asyncio.run(DocumentationEndpoint.load_html(
        str(filename),
        {'name': 'first'}))
      second_content = asyncio.run(DocumentationEndpoint.load_html(
        str(filename),
        {'name': 'second'}))

    self.assertEqual('<p>first</p>', first_content)
    self.assertEqual('<p>second</p>', second_content)

  def test_allowed_methods_can_be_extended(self) -> None:
    """
      Test that subclasses can extend the default allowed HTTP methods.
      :return: None
    """
    class PostProfileEndpoint(DocumentationEndpoint):
      """
        A profile endpoint that declares POST in addition to defaults.
      """

      @classmethod
      def response_media_type(cls) -> ResponseMediaType:
        """
          Return the primary response media type for the endpoint.
          :return: A concrete response media type
        """
        return 'text/html'

      @classmethod
      def _supported_media_types(cls) -> SupportedMediaTypes:
        """
          Return the response media types supported by the endpoint.
          :return: A non-empty tuple of concrete response media types
        """
        return ('text/html',)

      @classmethod
      def html_filename(cls) -> HTMLFilename:
        """
          Return the HTML template filename for the endpoint.
          :return: An HTML filename
        """
        return make_html_filename('custom.jinja2')

      @classmethod
      def json_filename(cls) -> JSONFilename:
        """
          Return the JSON filename for the endpoint.
          :return: A JSON filename
        """
        return make_json_filename('custom.json')

      @classmethod
      def allowed_methods(cls) -> HTTPMethods:
        """
          Return the HTTP methods supported by the endpoint.
          :return: A tuple of allowed HTTP methods
        """
        return (*super().allowed_methods(), 'POST')

    app = Starlette(routes=[
      Route('/post-profile', PostProfileEndpoint, name='post_profile_endpoint')
    ])
    client = TestClient(app, 'http://localhost:5101')

    response = client.put('/post-profile')

    self.assertEqual(status.HTTP_405_METHOD_NOT_ALLOWED, response.status_code)
    self.assertEqual('GET, HEAD, OPTIONS, POST', response.headers['allow'])
    self.assertEqual(
      ['GET', 'HEAD', 'OPTIONS', 'POST'],
      response.json()['allowedMethods'])

  def test_load_json_caches_template_not_content(self) -> None:
    """
      Test that JSON templates are cached while rendered content stays dynamic.
      :return: None
    """
    with tempfile.TemporaryDirectory() as temp_dir:
      filename = Path(temp_dir) / 'object.json'
      filename.write_text('{"name": "{{ name }}"}', encoding='utf-8')

      template = DocumentationEndpoint.load_json_template(str(filename))
      self.assertIs(template, DocumentationEndpoint.load_json_template(str(filename)))

      first_data = asyncio.run(DocumentationEndpoint.load_json(
        str(filename),
        {'name': 'first'}))
      second_data = asyncio.run(DocumentationEndpoint.load_json(
        str(filename),
        {'name': 'second'}))

    self.assertEqual({'name': 'first'}, first_data)
    self.assertEqual({'name': 'second'}, second_data)

  def test_load_json_returns_object_json(self) -> None:
    """
      Test that load_json returns object JSON documents.
      :return: None
    """
    with tempfile.TemporaryDirectory() as temp_dir:
      filename = Path(temp_dir) / 'object.json'
      filename.write_text('{"name": "{{ name }}"}', encoding='utf-8')
      data = asyncio.run(DocumentationEndpoint.load_json(
        str(filename),
        {'name': 'cbrws'}))
    self.assertEqual({'name': 'cbrws'}, data)

  def test_load_json_does_not_html_escape_context(self) -> None:
    """
      Test that JSON rendering does not use HTML escaping.
      :return: None
    """
    with tempfile.TemporaryDirectory() as temp_dir:
      filename = Path(temp_dir) / 'object.json'
      filename.write_text('{"name": "{{ name }}"}', encoding='utf-8')
      data = asyncio.run(DocumentationEndpoint.load_json(
        str(filename),
        {'name': '<cbrws>&'}))
    self.assertEqual({'name': '<cbrws>&'}, data)

  def test_load_html_escapes_context(self) -> None:
    """
      Test that HTML rendering escapes template context values.
      :return: None
    """
    with tempfile.TemporaryDirectory() as temp_dir:
      filename = Path(temp_dir) / 'custom.jinja2'
      filename.write_text('<p>{{ name }}</p>', encoding='utf-8')
      content = asyncio.run(DocumentationEndpoint.load_html(
        str(filename),
        {'name': '<cbrws>&'}))
    self.assertEqual('<p>&lt;cbrws&gt;&amp;</p>', content)

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
        asyncio.run(DocumentationEndpoint.load_json(str(filename), {}))

  def test_get_and_head_negotiate_with_supported_media_types(self) -> None:
    """
      Test that response negotiation uses declared media types.
      :return: None
    """
    with tempfile.TemporaryDirectory() as temp_dir:
      schema_dir = Path(temp_dir)
      (schema_dir / 'custom.jinja2').write_text('<h1>Custom</h1>', encoding='utf-8')
      (schema_dir / 'custom.json').write_text('{"name": "custom"}', encoding='utf-8')

      class CustomProfileEndpoint(DocumentationEndpoint):
        """
          A profile endpoint with a deliberately restricted media type list.
        """
        @classmethod
        def schema_dir(cls) -> SchemaDir:
          """
            Return the schema template directory for the endpoint.
            :return: A schema directory path
          """
          return make_schema_dir(schema_dir)

        @classmethod
        def response_media_type(cls) -> ResponseMediaType:
          """
            Return the primary response media type for the endpoint.
            :return: A concrete response media type
          """
          return 'text/html'

        @classmethod
        def _supported_media_types(cls) -> SupportedMediaTypes:
          """
            Return the response media types supported by the endpoint.
            :return: A non-empty tuple of concrete response media types
          """
          return ('text/html',)

        @classmethod
        def html_filename(cls) -> HTMLFilename:
          """
            Return the HTML template filename for the endpoint.
            :return: An HTML filename
          """
          return make_html_filename('custom.jinja2')

        @classmethod
        def json_filename(cls) -> JSONFilename:
          """
            Return the JSON filename for the endpoint.
            :return: A JSON filename
          """
          return make_json_filename('custom.json')

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

  def test_head_does_not_render_response_body(self) -> None:
    """
      Test that HEAD negotiates headers without rendering profile content.
      :return: None
    """
    class HeadOnlyProfileEndpoint(DocumentationEndpoint):
      """
        A profile endpoint whose render methods fail if called.
      """

      @classmethod
      def response_media_type(cls) -> ResponseMediaType:
        """
          Return the primary response media type for the endpoint.
          :return: A concrete response media type
        """
        return 'application/hal+json'

      @classmethod
      def _supported_media_types(cls) -> SupportedMediaTypes:
        """
          Return the response media types supported by the endpoint.
          :return: A non-empty tuple of concrete response media types
        """
        return ('application/hal+json', 'text/html')

      @classmethod
      def html_filename(cls) -> HTMLFilename:
        """
          Return the HTML template filename for the endpoint.
          :return: An HTML filename
        """
        return make_html_filename('custom.jinja2')

      @classmethod
      def json_filename(cls) -> JSONFilename:
        """
          Return the JSON filename for the endpoint.
          :return: A JSON filename
        """
        return make_json_filename('custom.json')

      @classmethod
      async def load_html(cls, filename: str, context: dict[str, str]) -> str:
        """
          Fail if HEAD tries to render HTML content.
          :param filename: The template filename
          :param context: The template context
          :return: Never returns
        """
        raise AssertionError('HEAD must not render HTML content')

      @classmethod
      async def load_file(cls, filename: str, context: dict[str, str]) -> str:
        """
          Fail if HEAD tries to render JSON content.
          :param filename: The template filename
          :param context: The template context
          :return: Never returns
        """
        raise AssertionError('HEAD must not render JSON content')

    app = Starlette(routes=[
      Route('/head-only', HeadOnlyProfileEndpoint, name='head_only_endpoint')
    ])
    client = TestClient(app, 'http://localhost:5101')

    for accept, content_type in (
          ('text/html', 'text/html; charset=utf-8'),
          ('application/hal+json', 'application/hal+json')):
      with self.subTest(accept=accept):
        response = client.head('/head-only', headers={'Accept': accept})

        self.assertEqual(status.HTTP_200_OK, response.status_code)
        self.assertEqual(content_type, response.headers['content-type'])
        self.assertEqual('', response.text)
