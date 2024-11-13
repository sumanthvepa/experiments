//-*- coding: utf-8 -*-
/**
  org-chart.swift: A simple console based org chart generator in Swift
  The code in this file can be used to generate org charts like this:
 ````
 +------------+
 | Joko Jokic |
 +------------+
   |  +-----------------+
   +--| Faisal Fabbiani |
   |  +-----------------+
   |  +------------------+
   +--| Girish Gadjinsky |
   |  +------------------+
   |    |  +----------------+
   |    +--| Arjun Acemoglu |
   |    |  +----------------+
   |    |  +------------+
   |    +--| Betty Bian |
   |       +------------+
   |         |  +-----------------+
   |         +--| Konrad Kraikupt |
   |         |  +-----------------+
   |         |  +-----------------+
   |         +--| Lars Littlebear |
   |            +-----------------+
   |              |  +---------------+
   |              +--| Mandy Maalouf |
   |                 +---------------+
   |  +------------+
   +--| Harald Heß |
      +------------+
        |  +--------------+
        +--| Ciara Chukwu |
        |  +--------------+
        |  +------------+
        +--| Dian Dagar |
        |  +------------+
        |  +--------------+
        +--| Emmet Ergasi |
           +--------------+
 ````
*/
/* -------------------------------------------------------------------
 * org-chart.swift: A simple console based org chart generator in Swift
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
 Represents an Employee of an organization
*/
protocol Employee {
  /**
   The name of the employee
  */
  var name: String { get }
}

/**
 Represents an employee who has nobody reporting to them.
*/
struct IndividualContributor: Employee {
  let name: String
}

/**
 Represents an employee who has people reporting to them
*/
struct Manager: Employee {
  let name: String
  /**
   A list of employees that report to this person
  */
  let subordinates: [Employee]
}

/**
 A utility class that represents the strings that need to be prefixed to the rendering of an employee's box in
 console based org chart to indent the box the right amount and connect it to the rest of the chart.
 
 Each box in this org chart consists of three lines: the top border, the interior text and the bottom border,
 as shown below:
 ```
 +------------+
 | Joko Jokic |
 +------------+
 ```
 Each box is connected to the rest of the org chart by a stem. Depending on where in the org chart
 a given element is located the stem will look slightly different. There are essentially two possibilities.
 First, when the box has no sibling following it. the stem looks like this:
 ```
 |  +--------------+
 +--| Emmet Ergasi |
    +--------------+
 ```
 If the box has siblings that follow it, then the stem looks like this:
 ```
 |  +------------+
 +--| Dian Dagar |
 |  +------------+
 ```
 The part of the prefix that  preceeds this stem, should essentially be the same as the bottom line of
 the parent. For example:
 ```
 |    |  +------------+
 |    +--| Betty Bian |
 |       +------------+
 |         |  +-----------------+
 |         +--| Konrad Kraikupt |
 |         |  +-----------------+
 |         |  +-----------------+
 |         +--| Lars Littlebear |
 |            +-----------------+
 ```
 In the example above, notice that the prefix string for the bottom border for Betty Bian's
 box is the same as the prefix strings for both of her subordinates boxes.
 Betty Bian's bottom border string has the prefix:
 ```
 '|     ' # Vertical bar followed by 5 spaces.
 ```
 This string is also part of the prifix strings for boxes of Konrad Kraiput and Lars Littlebear.
 For Konrad the prefix look like this:
```
 '|         |  '
 '|         +--'
 '|         |  '
 ```
 While for lars the prefix looks like this:
 ```
 '|         |  '
 '|         +--'
 '|            '
```
 In both cases, the first 6 characters are identical to the prefix string of the parent's bottom border.
 This is true recursively as well.  Betty Bian's prefix strings are identical the bottom border prefix
 of her boss's box.
 
 This logic allows us to construct the prefix for strings for an org-chart box, given its parents
 prefix strings and whether it has a sibling that follows it in the hierarchy.
 
 
 The Box prefix struct's non-default initializer implements this logic
*/
struct BoxPrefix {
  let top: String
  let interior: String
  let bottom: String
  
  /**
   Initialize a BoxPrefix struct with empty string.
   
   This is the prefix of the root element in an org-chart.
  */
  init() {
    self.top = ""
    self.interior = ""
    self.bottom = ""
  }
  
  /**
   Initializes an
  */
  init(top: String, interior: String, bottom: String) {
    self.top = top
    self.interior = interior
    self.bottom = bottom
  }
  
  /**
   Creates a OrgChartBoxPrefix for an element that has a parent, and possibly siblings that come after it.
   
   This is the code that does the real work in  this structure. It creates the prefix strings as described in the documentation
   for this structure.
   
   If the elment has elements at the same level that follow it, then the prefix looks like this. Assuming that the parent prefix
   look as shown below:
   ```
        top: ' |    |  '
   interior: ' |    +--'
     bottom: ' |       '
   ```
   Then this instance will look as follows:
   
   ```
        top: '  |         |  '
   interior: '  |         +--'
     bottom: '  |         |  '
   ```
   If there are no elements that follow this element at the same level, then the element will look as follows:
   ```
        top: '  |         |  '
   interior: '  |         +--'
     bottom: '  |            '
   ```
   
   - parameters:
    - parent: The prefix of the parent of this element
    - childHasSiblings: True if this element has other elements at the same level that follow it.
   */
  init(parent: BoxPrefix, childHasSiblings: Bool) {
    if childHasSiblings {
      top =      parent.bottom + "  |  "
      interior = parent.bottom + "  +--"
      bottom =   parent.bottom + "  |  "
    } else {
      top =      parent.bottom + "  |  "
      interior = parent.bottom + "  +--"
      bottom =   parent.bottom + "     "
    }
  }
  
  static var empty: BoxPrefix = .init()
}

/**
 Represents a box in an org chart.
 
 It provides a display method that must be implemented by classes
 implementing this protocol.
 */
protocol OrgChartElement {
  /**
   Render this element and all its children as ASCII art org chart
   
   This method must be implemented by classes/structs that
   implement this protocol.
   
   - parameters:
    - prefix: The prefix to use when rendering the element.
   - returns: An ASCII art org chart.
   */
  func display(prefix: BoxPrefix) -> String
}

/**
 Render an individual elements box (with the appropriate indentation and branch connections)
 
 The returned text looks something like this:
 ```
 |              |  +---------------+
 |              +--| Mandy Maalouf |
 |                 +---------------+
 ```
 
 - parameters:
  - employee: The employee instance to be displayed
  - prefix: The indentation prefixes to use
 
 - returns: An ASCII art representation of a box representing an employee, properly indented with branching included.
 */
private func displayEmployee(employee: Employee, prefix: BoxPrefix) -> String {
  let boxBorder = "+" + String(repeating: "-", count: employee.name.count + 2) + "+"
  let boxTopBorder = prefix.top + boxBorder
  let boxInterior = prefix.interior + "| " + employee.name + " |"
  let boxBottomBorder = prefix.bottom + boxBorder
  let box = boxTopBorder + "\n" + boxInterior + "\n" + boxBottomBorder + "\n"
  return box
}


/**
 An extension that implements the OrgChartElement protocol for an individual contributor
 */
extension IndividualContributor: OrgChartElement {
  /**
   Renders an individual contributor's box in an org chart, including connections
   
   This function simply calls, displayEmployee.
   
   - parameters:
      - prefix: The prefix strings that should be used to render this element. Defaults to .empty
   
   - returns: An ASCII box representation of a box representing an employee, properly indented with branching included.
   */
  func display(prefix: BoxPrefix = .empty) -> String {
    return displayEmployee(employee: self, prefix: prefix)
  }
}

/**
 An extension that implements the OrgChartElement protocol for a manager.
 
 This class manages all the core logic of recursing through a org tree and
 calling the appropriate display methods.
 
 */
extension Manager: OrgChartElement {
  /**
   Returns true if the index of a given element indicates that there are more elements following it.
   
    This information is used to render the prefix correctly. If an element has siblings below it, then a vertical bar
    indicating a continuing branch to subsequent siblings must be included as part of the prefix.
   */
  private func childHasSiblings(childIndex: Int, siblingsCount: Int) -> Bool {
    return childIndex < siblingsCount - 1
  }
  
  /**
   Renders the entire org chart below a given manager, aloing with appropriate
   prefixes.
   The rendered output should look like that shown below. Here, the org of
   Betty Bian has been rendered completely, along with a prefix that shows
   that betty seems to be part of a larger organization.
   ```
   |    |  +------------+
   |    +--| Betty Bian |
   |    |  +------------+
   |    |    |  +-----------------+
   |    |    +--| Konrad Kraikupt |
   |    |    |  +-----------------+
   |    |    |  +-----------------+
   |    |    +--| Lars Littlebear |
   |    |       +-----------------+
   |    |         |  +---------------+
   |    |         +--| Mandy Maalouf |
   |    |            +---------------+
   ```
   If the prefix is .empty,
   then the org chart is rendered as if the person was at the top of the org, as shown
   below:
   ```
   +------------+
   | Betty Bian |
   +------------+
     |  +-----------------+
     +--| Konrad Kraikupt |
     |  +-----------------+
     |  +-----------------+
     +--| Lars Littlebear |
        +-----------------+
          |  +---------------+
          +--| Mandy Maalouf |
             +---------------+
   ```
   - parameters:
     - prefix: The prefix strings to be applied to the org-chart (if it is part of a bigger org). The default value is empty.
   
   - returns An ASCII art representation of the org chart of  the manager, properly indented with branching included.
   */
  func display(prefix: BoxPrefix = .empty) -> String {
    var chart = ""
    
    let managerBox = displayEmployee(employee: self, prefix: prefix)
    chart += managerBox
    
    for (index, subordinate) in subordinates.enumerated() {
      let childPrefix
        = BoxPrefix(
          parent: prefix,
          childHasSiblings: childHasSiblings(
            childIndex: index,
            siblingsCount: subordinates.count))
      if let element = subordinate as? OrgChartElement {
        chart += element.display(prefix: childPrefix)
      }
    }
    return chart
  }
}
