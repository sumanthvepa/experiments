package sv.experiments.palindrome;

public class App {
  static boolean isPalindrome(int n) {
    int reversed = 0;
    int original = n;
    while (n > 0) {
      reversed = reversed * 10 + n % 10;
      n /= 10;
    }
    return original == reversed;
  }

  public static void main(String[] args) {
    for (var arg: args) {
      try {
        int n = Integer.parseInt(arg);
        System.out.println(n + (isPalindrome(n) ? " is" : " is not") + " a palindrome");
      } catch (NumberFormatException e) {
        System.err.println(arg + " is not a number");
      }
    }
  }
}
