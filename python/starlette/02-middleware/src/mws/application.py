from starlette.applications import Starlette
from starlette.endpoints import HTTPEndpoint
from starlette.responses import JSONResponse
from starlette.routing import Route


class Hello(HTTPEndpoint):
    async def get(self, request):
        return JSONResponse({"message": "hello"})


app = Starlette(routes=[Route("/", Hello)])