// Another example of nested classes/structs that
// work in isolation but will crash the compiler within a larger
// project.

protocol MyCollection {
  associatedtype Element
  var elements: [Element] {get set} 

  mutating func append(element: Element)
}

func createRepeatingElements(element: Int, times: Int) -> some MyCollection {
  struct MyList: MyCollection {
    typealias Element = Int
    var elements: [Element] = []

    mutating func append(element: Element) {
      self.elements.append(element)
    }
  }

  var mylist = MyList()
  for _ in 0..<times {
    mylist.append(element: element)
  }
  return mylist
}

let mylist = createRepeatingElements(element: 5, times: 3)
print(mylist.elements.count)

