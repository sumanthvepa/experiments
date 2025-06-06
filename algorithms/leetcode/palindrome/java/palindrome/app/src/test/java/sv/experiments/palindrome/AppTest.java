/*
 * This source file was generated by the Gradle 'init' task
 */
package sv.experiments.palindrome;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class AppTest {
  @Test void testIsPalindrome() {
    int[] palindromes = {0, 1, 2, 3, 11, 22, 121, 1221, 12321, 99, 939, 8998};
    for (int n: palindromes) {
      assertTrue(App.isPalindrome(n), n + " is a palindrome");
    }

    int[] notPalindromes = {10, 12, 123, 1234, 12345, -1, -11, -222, -121};
    for (int n: notPalindromes) {
      assertFalse(App.isPalindrome(n), n + " is not a palindrome");
    }
  }
}
