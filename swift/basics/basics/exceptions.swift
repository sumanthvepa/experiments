//-*- coding: utf-8 -*-
/**
  exceptions.swift: Explore exceptions
*/
/* -------------------------------------------------------------------
 * exceptions.swift: Explore exceptions
 *
 * Copyright (C) 2024 Sumanth Vepa.
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License a
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see
 * <https://www.gnu.org/licenses/>.
 *-----------------------------------------------------------------*/

/**
  Explore exceptions
*/
func exploreExceptions() {
  // Exceptions are any type that implements the Error protocol
  // protocols are discussed in protocls.swift. The Error protocol
  // itself has no members, making it a marker protocol.
  
  // You can define a cutom exception as a struct follows.
  // For more on classes and inheritance see struct_and_class_basics.swift
  // and inheritances.swft
  
  // This is a custom error struct that has an error code
  struct CustomError: Error {
    let code: Int
    init(code: Int) {
      self.code = code
    }
  }

  // For a function to throw an exception it must
  // have a throws clause after it.
  func thisThrowsAnException(raiseError: Bool) throws {
    if (raiseError) {
      throw CustomError(code: 10)
    }
  }

  // To handle a throwing function you need an exhaustive
  // do/catch block and and mark the throwing function with
  // a try.
  do {
    try thisThrowsAnException(raiseError: true)
  } catch let customError as CustomError {
    // Note the let clause. This creates a local variable
    // customError of type CustomError, when the
    // exception is of type CustomError.
    // Now you can access the member of the class CustomError
    print("Caught a CustomError \(customError.code)")
  } catch {
    // This is the default catch all clause.
    // If none of the other clauses catch the exception
    // then this clause will catch it.
    print("Caught some other error")
  }

  // If you try to throw from a function that does not declare a
  // throws clause, you will get a compiler error.
  // func cannotThrowAnException() {
  //   throw CustomError(code: 25) // Error is not handled because
  //                               // enclosing function is not
  //                               // declared throws
  //}
  
  // It doesn't help either if you call a function that throws an
  // exception, unless you handle the exception with a do/try/catch
  // block.
  // func cannotThrowAnException2() {
  //  thisThrowsAnException(raiseError: true) // Call can throw, but
  //                                          // is not marked with 
  //                                          // 'try' and the error
  //                                          // is not handled
  // }
  
  // Nor will this work. It has a catch clause but it is not
  // exhaustive and there is no try before the call to the throwing
  // function.
  // func cannotThrowAnException3() {
  //  do {
  //     thisThrowsAnException(raiseError: true)
  //  } catch let customError as CustomError {
  //    print("Caught a custom error inside a function")
  //  }
  // }
  
  // Nope. Catch is exhaustive with the default catch, but call is not
  // marked with a try clause.
  // func cannotThrowAnException3() {
  //   do {
  //      thisThrowsAnException(raiseError: true)
  //   } catch let customError as CustomError {
  //     print("Caught a custom error inside a function")
  //   } catch {
  //     print("Caught something else")
  //   }
  // }
  
  // This is okay. It catches everything and marks the throwing
  // function with a try.
  func cannotThrowAnException3() {
    do {
      try thisThrowsAnException(raiseError: true)
    } catch let customError as CustomError {
      print("Caught CustomError: \(customError.code)")
    } catch {
      print("Caught something else")
    }
  }
  
  // A more common idiom in swift when a function needs throw a
  // variety of errors is to use Swift enums. Enums are described in
  // more detail in enums.swift
  
  // This is an example of an Enum used as a throwable Error.
  // There are three types of errors, which are reflected in the 3
  // cases for the enum.
  
  // To make things easier, we define 2 computed properties:
  // code and status which return the HTTP error code for
  // a given case and the status message for that case.
  
  /**
    An enum that represents HTTP errors. The enum has three cases:
    FileNotFound, InternalServerError and ImATeapot. Each case
    has a code and a status message associated with it.
  */
  enum HttpError: Error {
    case FileNotFound
    case InternalServerError
    case ImATeapot

    /**
      The HTTP error code for the error
    */  
    var code: Int {
      get {
        switch self {
        case .FileNotFound:
          return 404
        case .InternalServerError:
          return 500
        case .ImATeapot:
          return 418
        }
      }
    }

    /**
      The HTTP status message for the error
    */
    var status: String {
      get {
        switch self {
        case .FileNotFound:
          return "File Not Found"
        case .InternalServerError:
          return "Internal Server Error"
        case .ImATeapot:
          return "I'm a teapot"
        }
      }
    }
  }
  
  /**
    A dummy function that 'loads' a page. Used
    to demonstrate the use of the HttpError enum
    as a throwable error.

    If the page is index.html it returns
    the string "Hello World". If the page is
    buggy.html it throws an InternalServerError
    exception. If the page is teapot.html it throws
    an ImATeapot exception. For all other pages it
    throws a FileNotFound exception.

    - parameter page: The page to load    
    - returns: The content of the page
    - throws: HttpError.FileNotFound if the filename is not
              index.html, buggy.html or teapot.html,
              HttpError.InternalServerError, if the file is buggy.html
              HttpError.ImATeapot if the file is teapot.html
  */
  func load(page: String) throws -> String {
    if page == "index.html" {
      return "Hello World"
    }
    if page == "buggy.html" {
      throw HttpError.InternalServerError
    }
    if page == "teapot.html" {
      throw HttpError.ImATeapot
    }
    throw HttpError.FileNotFound
  }
  
  // You can catch any instance of the enum and print a message.
  do {
    let content = try load(page: "doesnotexist.html")
    print(content)
  } catch let error as HttpError {
    // This catches any instance of the enum 
    print("\(error.code) \(error.status)")
  } catch {
    // Unknown error. Should not occur
    print("Unknown Error")
  }
  
  // You can catch a specific instance of the enum and print a
  // different message for it. Then you can let more generic catch
  // clauses handle the other errors.
  do {
    let content = try load(page: "doesnotexist.html")
    print(content)
  } catch HttpError.ImATeapot {
    // This catches the specific instance of the enum.
    print("Why would you talk to a teapot?")
  } catch let error as HttpError {
    // This catches any instance of the enum
    // Now the remaining two cases FileNotFound and InternalServerError
    print("\(error.code) \(error.status)")
  } catch {
    // This is the catch all.
    // Unknown error. Should not occur
    print("Unknown Error")
  }

  // Enums can also have associated values. And these can be used to
  // provide more detail about the error.
  // For example in the case of FileNotFound, you can provide the
  // filename that was not found.
  // In the case of InternalServerError, you can provide a string
  // that describes the error in more detail.
  enum HttpErrorExtended: Error {
    case FileNotFound(filename: String)
    case InternalServerError(details: String)
    case ImATeapot

    /**
      The HTTP error code for the error
    */  
    var code: Int {
      get {
        switch self {
        case .FileNotFound:
          return 404
        case .InternalServerError:
          return 500
        case .ImATeapot:
          return 418
        }
      }
    }

    /**
      The HTTP status message for the error
    */
    var status: String {
      get {
        switch self {
        case .FileNotFound:
          return "File Not Found"
        case .InternalServerError:
          return "Internal Server Error"
        case .ImATeapot:
          return "I'm a teapot"
        }
      }
    }
  }

  /**
          
  */
  func load2(page: String) throws -> String {
    if page == "index.html" {
      return "Hello World"
    }
    if page == "buggy.html" {
      throw HttpErrorExtended.InternalServerError(
        details: "The buggy.html page is buggy")
    }
    if page == "teapot.html" {
      throw HttpErrorExtended.ImATeapot
    }
    throw HttpErrorExtended.FileNotFound(filename: page)
  }
  
  do {
    let content = try load2(page: "doesnotexist.html")
    print(content)
  } catch HttpErrorExtended.FileNotFound(let filename) {
    // You can catch the specific case of the enum directly
    // in the catch clause. This can be convenient, but note
    // that you will not have access to the error enum instance
    // This means you cannot access the error enum instance's
    // code and status properties.
    // In situations where the enum does not have any computed
    // properties or method that you want to access than this
    // method works fine.
    print("\(filename) not found.")
  } catch let error as HttpErrorExtended {
    // For the more general situation, when you want access to
    // error object itself, along with any associated instance
    // data, use this, more general method.
    // Here we catch the error object and handle the specific
    // enum cases we care about with an if case let statement.
    
    // Handle .InternalServerError and .ImATeapot errors only.
    // in this catch clause, since FileNotFound has already
    // been handled.
    if case let .InternalServerError(details) = error {
      print("\(error.code) \(error.status): \(details)")
    }
    
    // For the .ImATeaPot case, there is no need for a let
    // because there is no associate data.
    if case .ImATeapot = error {
      print("\(error.code) \(error.status)")
    }
  } catch {
    print("Unknown error")
  }
  
  
  // The obkeve do catch clause is somewhat cumbersome to
  // read for this particular use case, because, the handling
  // of the enums cases is done inconsistently. FileNotFound
  // is handled directly at catch clause level, while the other
  // enums are handled within a if case statements within
  // another catch clause.
  
  // You could instead just handle all cases uniformly with
  // a switch statement within a general catch clause.
  do {
    let content = try load2(page: "doesnotexist.html")
    print(content)
  } catch let error as HttpErrorExtended {
    // There is no catch syntax to get access to an error inance
    // and its associated instance data (filename) in the catch clause.
   
    // We therefore catch all instances of the enum, and
    // then we use the switch statement to diambiguate
    // the various enum instances and deal with each of
    // those cases appropriately.
    
    switch error {
    case .FileNotFound(let filename):
      print("\(error.code) [\(filename)] \(error.status)")
    case .InternalServerError(let details):
      print("\(error.code) \(error.status): \(details)")
    case .ImATeapot:
      print("\(error.code) \(error.status): I'm a teapot man!")
    }
  } catch {
    // This is the catch all.
    // Unknown error. Should not occur
    print("Unknown Error")
  }
  
  // You can catch multiple cases in a single catch statement
  do {
    let content = try load(page: "buggy.html")
    print("content = \(content)")
  } catch HttpError.FileNotFound, HttpError.InternalServerError {
    print("Caught a real error")
  } catch {
    print("Caught some other error")
  }
  
  // You can convert a thrown exceptions to optionals as follows:
  let content: String?
  do {
    content = try load(page: "buggy.html")
  } catch {
    content = nil
  }
  // Now you can treat content as an optional.
  print("content = \(String(describing: content))")
  
  // The code above is a little cumbersome so Swift
  // provides some syntactic sugar to make this idom
  // easier to use the try? operator.
  
  let content2 = try? load(page: "doesnotexist.html") // Content2 is of type String?
  print("type(of: content2) = \(type(of: content2))") //Optiona<String>
  print("content2 = \(String(describing: content2))")
  
  // Sometimes you know that the function won't throw an error with
  // parameters it is passed. In those instances use try! to implictly
  // force the functions return value to be a the actual return type
  // and not an optional. This avoids the cumbersome do/catch blocks
  // when they are not needed.
  let content3 = try! load(page: "index.html")
  print("type(of: content3) = \(type(of: content3))")
  print("content3 = \(String(describing: content3))")
  
  
  // dummy_open, dummy_write, and dummy_close are
  // functions used for the example that follows.
  func dummy_open(filename: String) -> Int {
    print("Opening \(filename)")
    return 1
  }
  
  func dummy_write(filename: String, content: String) {
    print("Writing '\(content)' to \(filename)")
  }
  
  func dummy_close(filehandle: Int) {
    print("Closing \(filehandle)")
  }
  
  // Sometimes you want to do some clean up actions before
  // exiting a function, regardless of whether or not an
  // exception occurs in the code. Here we want to close
  // file. For that purpose we use a defer block. The defer
  // block is always executed upon function exit.
  func savePage(page: String, filename: String) throws {
    let file = dummy_open(filename: filename)
    defer { dummy_close(filehandle: file) }
    
    let content = try load(page: page)
    dummy_write(filename: filename, content: content)
  }
  
  do {
    // This will not throw an exception, but the close function will
    // be called up normal exit.
    try savePage(page: "index.html", filename: "content2.txt")

    // This will throw an exception, but the close function will
    // still be called from within the defer block.
    try savePage(page: "buggy.html", filename: "content.txt")
    
  } catch {
    print("savePage failed")
  }
}
