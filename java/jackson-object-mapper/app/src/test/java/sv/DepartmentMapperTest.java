package sv;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

import com.fasterxml.jackson.core.JsonProcessingException;


public class DepartmentMapperTest {
  private final DepartmentMapper mapper = new DepartmentMapper();

  public @Test void testSerializeDepartment()
      throws JsonProcessingException {
    assertEquals(
        Data.firstDepartmentJson,
        mapper.serialize(Data.firstDepartment));
    assertEquals(
        Data.secondDepartmentJson,
        mapper.serialize(Data.secondDepartment));
  }

  public @Test void testDeserializeDepartment()
      throws JsonProcessingException {
    assertEquals(
        Data.firstDepartment,
        mapper.deserialize(Data.firstDepartmentJson));
    assertEquals(
        Data.secondDepartment,
        mapper.deserialize(Data.secondDepartmentJson));
  }

}
