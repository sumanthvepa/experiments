""" Explore covariance and contravariance """
from typing import Callable, override

# pylint: disable=too-few-public-methods
class A:
  """ class A """
  def method1(self) -> None:
    """ A::method1 """
    print('A::method1()')

class D:
  """ class D """
  def method1(self) -> None:
    """ D::method1 """
    print('D::method1()')

class B(D):
  """ class B """
  @override
  def method1(self) -> None:
    """ B::method1 """
    print('B::method1()')

class C(A):
  """ class C """
  @override
  def method1(self) -> None:
    """ C::method1 """
    print('C::method1()')


def func1(v: A) -> B:
  """ func1 """
  v.method1()
  return B()


def main() -> None:
  """ The main function """
  func2: Callable[[C], D] = func1
  c = C()
  d = func2(c)
  d.method1()


if __name__ == '__main__':
  main()
