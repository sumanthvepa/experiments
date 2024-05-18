import Foundation

func program_name(arguments: [String]) -> String {
  if arguments.count < 1
}

func process_command_lin(arguments: [String]) -> (dividend: Int, divisor: Int) {
  let program = program_name(arguments)
  return (25, 3)
}

func gcd(_ m: Int, _ n: Int) -> Int {
  var m: Int = m
  var n: Int = n
  while n != 0 {
    let r = m % n;
    m = n;
    n = r;
  }
  return m;
}

func main() {
  let (m, n) = process_command_line(program_name: CommandLine.arguments[0], args: CommandLine.arguments[1...])
  print(gcd(m, n))
}

main()
