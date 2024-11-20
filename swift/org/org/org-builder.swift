
@resultBuilder
struct OrgBuilder {
  static func buildBlock(_ components: Employee...) -> [Employee] {
    return components
  }
}

func makeOrg(@OrgBuilder content: () -> [Employee]) -> [Employee] {
  return content()
}
