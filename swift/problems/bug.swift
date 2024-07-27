protocol ValueWrapper {
  associatedtype Item 
  var value: Item {get set}
}

func foo<T>(element: T) -> some ValueWrapper {
  class Inner<U>: ValueWrapper {
    typealias Item = U
    var value: U
    init (value: U) {
      self.value = value
    }
  }

  return Inner<T>(value: element)
}

let wrapped = foo(element: 5)
print(wrapped.value)

