package sv;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

import com.fasterxml.jackson.core.JsonProcessingException;


public class CompanyMapperTest {
  private final CompanyMapper mapper = new CompanyMapper();

  public @Test void testSerializeCompany()
      throws JsonProcessingException {
    assertEquals(
        Data.companyJson,
        mapper.serialize(Data.company));
  }

  public @Test void testDeserializeCompany()
      throws JsonProcessingException {
    assertEquals(
        Data.company,
        mapper.deserialize(Data.companyJson));
  }

}
