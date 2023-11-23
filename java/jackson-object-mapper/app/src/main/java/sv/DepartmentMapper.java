package sv;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.jetbrains.annotations.NotNull;

public class DepartmentMapper {
  private final ObjectMapper mapper;

  public DepartmentMapper() {
    this.mapper = new ObjectMapper();
  }

  public @NotNull String serialize(@NotNull Department department)
      throws JsonProcessingException {
    return mapper.writeValueAsString(department);
  }

  public @NotNull Department deserialize(@NotNull String json)
      throws JsonProcessingException{
    return mapper.readValue(json, Department.class);
  }
}
