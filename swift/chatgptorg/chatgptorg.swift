import Foundation

// Define a struct for each person in the org chart
struct Employee {
    let name: String
    var reports: [Employee]
}

// Recursive function to print the org chart with indentation and lines
func printOrgChart(employee: Employee, prefix: String = "", isLast: Bool = true) {
    // Print the current employee with box formatting
    print("\(prefix)\(isLast ? "└" : "├")──+")
    print("\(prefix)\(isLast ? "  " : "| ") +\(String(repeating: "-", count: employee.name.count + 2))+" )
    print("\(prefix)\(isLast ? "  " : "| ") | \(employee.name) |")
    print("\(prefix)\(isLast ? "  " : "| ") +\(String(repeating: "-", count: employee.name.count + 2))+" )
    
    // Iterate over each report and call recursively
    for (index, report) in employee.reports.enumerated() {
        let isLastReport = index == employee.reports.count - 1
        printOrgChart(employee: report, prefix: prefix + (isLast ? "  " : "| "), isLast: isLastReport)
    }
}

// Example data to test
let orgChart = Employee(name: "Joko Jokic", reports: [
    Employee(name: "Faisal Fabbiani", reports: []),
    Employee(name: "Girish Gadjinsky", reports: [
        Employee(name: "Arjun Acemoglu", reports: []),
        Employee(name: "Betty Bian", reports: [
            Employee(name: "Konrad Kraikupt", reports: []),
            Employee(name: "Lars Littlebear", reports: [
                Employee(name: "Mandy Maalouf", reports: [])
            ])
        ]),
        Employee(name: "Niara Naber", reports: [
            Employee(name: "Olga Omarosa", reports: []),
            Employee(name: "Petter Palanisamy", reports: []),
            Employee(name: "Qian Quasimodo", reports: [])
        ])
    ]),
    Employee(name: "Harald Heß", reports: [
        Employee(name: "Ciara Chukwu", reports: []),
        Employee(name: "Dian Dagar", reports: []),
        Employee(name: "Emmet Ergasi", reports: [])
    ])
])

// Print the org chart
printOrgChart(employee: orgChart)

