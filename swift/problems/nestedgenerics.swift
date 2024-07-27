protocol ValueWrapper {
  associatedtype Item 
  var value: Item {get set}
}

// You can nest a class that implements the
// protocol that is return by a non-generic
// function. This hides the exact type of
// the returned value from the caller.
// This works, but seems to cause compiler
// crashes when used in larger code bases
func foo(element: Int) -> some ValueWrapper {
  class Inner: ValueWrapper {
    typealias Item = Int
    var value: Int
    init (value: Int) {
      self.value = value
    }
  }

  return Inner(value: element)
}

// This won't work because Swift does not
// support nesting types inside generic functions
/*
func bar<T>(element: T) -> some ValueWrapper {
  class Inner: ValueWrapper {
    var value: T
    init (value: T) {
      self.value = value
    }
  }

  return Inner<T>(value: element)
}
*/

let wrapped = foo(element: 5)
print(wrapped.value)
print("type(of: wrapped) = \(type(of: wrapped))")

