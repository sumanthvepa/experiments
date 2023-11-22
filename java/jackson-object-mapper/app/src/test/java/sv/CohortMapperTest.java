package sv;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

import com.fasterxml.jackson.core.JsonProcessingException;

import java.util.ArrayList;
import java.util.List;


public class CohortMapperTest {

  private final Person firstPerson
      = new Person("First Person", 25);
  private final String firstPersonJson
      = "{\"name\":\"First Person\",\"age\":25}";
  private final Person secondPerson
      = new Person("Second Person", 26);
  private final String secondPersonJson
      = "{\"name\":\"Second Person\",\"age\":26}";

  private final List<Person> personList = new ArrayList<>();
  {
    personList.add(firstPerson);
    personList.add(secondPerson);
  }
  private final String personListJson;
  {
    personListJson
        = "[" + firstPersonJson + "," + secondPersonJson + "]";
  }

  private final CohortMapper mapper = new CohortMapper();

  public @Test void testSerializePerson()
      throws JsonProcessingException {
    assertEquals(firstPersonJson, mapper.serialize(firstPerson));
    assertEquals(secondPersonJson, mapper.serialize(secondPerson));
  }

  public @Test void testDeSerializePerson()
      throws JsonProcessingException {
    assertEquals(firstPerson, mapper.deserialize(firstPersonJson));
  }

  public @Test void testDeSerializePersonsList()
      throws JsonProcessingException {
    assertEquals(personList, mapper.deserializeList(personListJson));
  }

  public @Test void testSerializePersonsList()
      throws JsonProcessingException {
    assertEquals(personListJson, mapper.serialize(personList));
  }
}
