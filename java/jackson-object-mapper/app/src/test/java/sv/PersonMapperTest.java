package sv;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

import com.fasterxml.jackson.core.JsonProcessingException;


public class PersonMapperTest {
  private final PersonMapper mapper = new PersonMapper();

  public @Test void testSerializePerson()
      throws JsonProcessingException {
    assertEquals(
        Data.firstPersonJson,
        mapper.serialize(Data.firstPerson));
    assertEquals(
        Data.secondPersonJson,
        mapper.serialize(Data.secondPerson));
    assertEquals(
        Data.firstPersonJson,
        mapper.serialize(Data.firstPerson));
    assertEquals(
        Data.secondPersonJson,
        mapper.serialize(Data.secondPerson));
  }

  public @Test void testDeSerializePerson()
      throws JsonProcessingException {
    assertEquals(
        Data.firstPerson,
        mapper.deserialize(Data.firstPersonJson));
    assertEquals(
        Data.secondPerson,
        mapper.deserialize(Data.secondPersonJson));
    assertEquals(
        Data.thirdPerson,
        mapper.deserialize(Data.thirdPersonJson));
    assertEquals(
        Data.fourthPerson,
        mapper.deserialize(Data.fourthPersonJson));
  }

  public @Test void testDeSerializePersonsList()
      throws JsonProcessingException {
    assertEquals(
        Data.personList1,
        mapper.deserializeList(Data.personList1Json));
    assertEquals(
        Data.personList2,
        mapper.deserializeList(Data.personList2Json));
  }

  public @Test void testSerializePersonsList()
      throws JsonProcessingException {
    assertEquals(
        Data.personList1Json,
        mapper.serialize(Data.personList1));
    assertEquals(
        Data.personList2Json,
        mapper.serialize(Data.personList2));
  }
}
