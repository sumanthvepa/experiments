package sv;

import java.util.Map;

import com.fasterxml.jackson.annotation.JsonAutoDetect;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.jetbrains.annotations.NotNull;


@JsonAutoDetect(fieldVisibility = JsonAutoDetect.Visibility.ANY)
public class Company {
  final @NotNull Map<String, Department> departments;

  // A dummy field to illustrate the use of @JsonIgnore.
  // It serves no other purpose.
  @JsonIgnore
  final double seed; // This field will not be serialized.

  public Company(@NotNull @JsonProperty("departments") Map<String, Department> departments) {
    this.departments = departments;
    this.seed = Math.random();
  }

  @Override
  public boolean equals(Object o) {
    if (o == this) return true;
    if (!(o instanceof Company company)) return false;
    return company.departments.equals(this.departments);
  }

  @Override
  public int hashCode() {
    return this.departments.hashCode();
  }
}
