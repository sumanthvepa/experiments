package sv;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Data {
  static final Person firstPerson
      = new Person("First Person", 25);
  static final String firstPersonJson
      = "{\"name\":\"First Person\",\"age\":25}";
  static final Person secondPerson
      = new Person("Second Person", 26);
  static final String secondPersonJson
      = "{\"name\":\"Second Person\",\"age\":26}";
  static final Person thirdPerson
      = new Person("Third Person", 25);
  static final String thirdPersonJson
      = "{\"name\":\"Third Person\",\"age\":25}";
  static String fourthPersonJson
      = "{\"name\":\"Fourth Person\",\"age\":26}";

  static final Person fourthPerson
      = new Person("Fourth Person", 26);

  static final List<Person> personList1 = new ArrayList<>();
  static {
    personList1.add(firstPerson);
    personList1.add(secondPerson);
  }
  static final String personList1Json;
  static {
    personList1Json
        = "[" + firstPersonJson + "," + secondPersonJson + "]";
  }

  static final List<Person> personList2 = new ArrayList<>();
  static {
    personList2.add(thirdPerson);
    personList2.add(fourthPerson);
  }

  static final String personList2Json;
  static {
    personList2Json
        = "[" + thirdPersonJson + "," + fourthPersonJson + "]";
  }
  static final Department firstDepartment
      = new Department(personList1);
  static final String firstDepartmentJson
      = "{\"employees\":" + personList1Json + "}";

  static final Department secondDepartment
      = new Department(personList2);
  static final String secondDepartmentJson
      = "{\"employees\":" + personList2Json + "}";

  static final Map<String, Department> departments = new HashMap<>();
  static {
    departments.put("department1", firstDepartment);
    departments.put("department2", secondDepartment);
  }

  static final String departmentMapJson
      = "{" + "\"department1\":" + firstDepartmentJson + ","
      + "\"department2\":" + secondDepartmentJson + "}";

  static final Company company = new Company(departments);

  static final String companyJson
      = "{\"departments\":" + departmentMapJson + "}";
}
