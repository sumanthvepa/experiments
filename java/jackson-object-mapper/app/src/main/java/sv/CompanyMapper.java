package sv;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.jetbrains.annotations.NotNull;

public class CompanyMapper {
  private final ObjectMapper mapper;

  public CompanyMapper() { this.mapper = new ObjectMapper(); }

  public @NotNull String serialize(@NotNull Company company)
      throws JsonProcessingException {
    return mapper.writeValueAsString(company);
  }

  public @NotNull Company deserialize(@NotNull String json)
      throws JsonProcessingException{
    return mapper.readValue(json, Company.class);
  }
}
