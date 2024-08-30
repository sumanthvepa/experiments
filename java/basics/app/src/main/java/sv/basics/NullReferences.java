package sv.basics;

import org.jetbrains.annotations.NotNull;

import javax.annotation.Nullable;

public class NullReferences {
  /**
   * The explore method is called to demonstrate the use of null
   * references in Java.
   */
  @SuppressWarnings("ImplicitArrayToString")
  public static void explore() {
    // See Baeldung's beautiful explanation of null references
    // in Java: https://www.baeldung.com/java-null

    // Null is a type in Java that has only one value: null.
    // Null is a reference type. It has exactly one instance
    // that isn't an instance of any class.
    // It can be assigned to any reference type.
    String doesNotExist = null;
    int[] arrayDoesNotExist = null;
    //noinspection ConstantValue
    System.out.println(doesNotExist); // null
    //noinspection ConstantValue
    System.out.println(arrayDoesNotExist); // null
    // Null is not the same as an empty string.
    String emptyString = "";
    System.out.println(emptyString); // ""
    // Null is not the same as a zero-length array.
    int[] zeroLengthArray = new int[0];
    System.out.println(zeroLengthArray.length); // 0

    // Null is a reference type, so it cannot be assigned to
    // a primitive type.
    // int i = null; // This will not compile.

    // Null can be passed as a parameter to a method.
    // In the example below, the Inner.method method is called
    // with a null parameter and a non-null parameter.
    // The code in method checks for null and prints a message
    // accordingly.
    // But Inner.canFail does not check for null and will throw
    // a NullPointerException if passed a null reference.

    /*
      The Inner class is a nested class that demonstrates the use
      of null references in Java.
      Note that this documentation does not use Javadoc because
      Javadoc does not support documentation of classes defined
      within methods.
     */
    class Inner {
      /**
       * This method prints its parameter if it is not null and
       * the message "parameter = null" if the parameter is null.
       *
       * @param parameter the parameter to the method. Can be null.
       */
      void method(String parameter) {
        if (parameter != null)
          System.out.println("Inner.method(parameter = " + parameter + ")");
        else System.out.println("Inner.method(parameter = null)");
      }

      /**
       * This method attempts to dereference its parameter without
       * checking if it is null.
       * @param parameter the parameter to the method. Can be null.
       */
      void canFail(String parameter) {
        // This will throw a NullPointerException if parameter is null,
        // because the length method is called on a null reference.
        System.out.println("Inner.canFail() parameter length is: " + parameter.length());
      }

      // The compile time annotation @NotNull and @Nullable can be used to
      // indicate to the compiler and IDE and other static analysis
      // tools, and of course the human programmer, whether it is safe
      // to pass a null reference to a method or not.

      // @Nullable is a compile time annotation that indicates that a
      // parameter can be null. This is a hint to the programmer that
      // the method can handle a null reference. It is also a hint to
      // the compiler and IDE that the parameter can be null and that
      // it should not issue a warning if a null reference is passed
      // to the method.
      // @Nullable is imported from the javax.annotation package.
      /**
       * This method prints its parameter if it is not null and the message
       * "parameter = null" if the parameter is null.
       * @param parameter the parameter to the method. Can be null.
       */
      void methodWithNullableAnnotation(@Nullable String parameter) {
        if (parameter != null)
          System.out.println(
            "Inner.methodWithNullableAnnotation(parameter = "
            + parameter + ")");
        else
          System.out.println(
            "Inner.methodWithNullableAnnotation(parameter = null)");
      }

      // @NotNull is a compile time annotation that indicates that a
      // parameter cannot be null. This is a hint to the programmer
      // that the method cannot handle a null reference. It is also
      // a hint to the compiler and IDE that the parameter cannot be
      // null and that it should issue a warning if a null reference
      // is passed to the method.
      // @NotNull is imported from the org.jetbrains.annotations
      // package. Note that this is a third-party library and not
      // part of the Java standard library. It should be added as a
      // dependency to the project's build.gradle.kts file.
      // add the line:
      // implementation("org.jetbrains:annotations:24.1.0")
      // Use the latest version of the library.
      // Note the IDE warning in JetBrains IDEs that the parameter
      // should not receive a null argument. Which it does later in
      // the code to demonstrate the violation of the @NotNull precondition annotation.
      void methodWithNotNullAnnotation(@NotNull String parameter) {
        System.out.println(
          "Inner.methodWithNotNullAnnotation(parameter = "
          + parameter.length() + ")");
      }
    }
    var inner = new Inner();
    // Prints Inner.method(parameter = null)
    inner.method(null);
     // Prints Inner.method(parameter = Hello, World!)
    inner.method("Hello, World!");

    // Attempting to deference a null reference will throw
    // a NullPointerException.
    try {
      // Note the warning from the IDE that the parameter should not
      // be null. This occurs because the method is not annotated with
      // @Nullable.
      inner.canFail(null); // This will throw a NullPointerException
    } catch (NullPointerException e) {
      System.out.println(
        "Caught a NullPointerException from inner.canFail()");
    }
    // But passing a proper reference will not throw an exception.
    inner.canFail("Hello, World!"); // Prints Hello, World!

    // The compile time annotations @NotNull and @Nullable can be used
    // to indicate to the compiler whether it is safe to pass a null
    // reference to a method  or not.

    // Ok. Prints Inner.methodWithNullableAnnotation(parameter = Hello, World!)
    inner.methodWithNullableAnnotation("Hello, World!");

    // Ok. Prints Inner.methodWithNullableAnnotation(parameter = null)
    inner.methodWithNullableAnnotation(null);

    // Ok. Prints Inner.methodWithNotNullAnnotation(parameter = 13)
    inner.methodWithNotNullAnnotation("Hello, World!");

    try {
      // Calling a method with a @NotNull annotation with a null
      // reference will result in a warning, and running the code will
      // result in a NullPointerException.
      // Note the IDE warning (in JetBrains IDEs) that the parameter
      // should not be null.

      // Warning The compiler will issue a warning. Will throw a
      //  NullPointerException
      inner.methodWithNotNullAnnotation(null);
    } catch(NullPointerException e) {
      System.out.println(
        "Caught a NullPointerException from "
        + "inner.methodWithNotNullAnnotation()");
    }
  }
}
