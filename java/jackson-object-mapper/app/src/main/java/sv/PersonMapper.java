package sv;

import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.databind.JavaType;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.JsonProcessingException;

import org.jetbrains.annotations.NotNull;


public class PersonMapper {
  private final ObjectMapper mapper;

  public PersonMapper() {
    this.mapper = new ObjectMapper();
  }

  public @NotNull String serialize(Person person)
      throws JsonProcessingException {
    return mapper.writeValueAsString(person);
  }

  public @NotNull Person deserialize(String json)
      throws JsonProcessingException {
    return mapper.readValue(json, Person.class);
  }

  public @NotNull String serialize(List<Person> persons)
      throws JsonProcessingException {
    return mapper.writeValueAsString(persons);
  }

  public @NotNull ArrayList<Person> deserializeList(String json)
      throws JsonProcessingException {
    /*
      The problem with deserializing to a generic type is that you
      cannot call ArrayList<Person>.class at runtime. All generic type
      information is erased at runtime. You only have ArrayList.class
      which is a list of objects. If we used that method, the type
      signature of deserializeList would have to be @NotNull
      ArrayList. Which would cause syntax issues at compile time. The
      solution is to create a special object JavaType provided by the
      jackson library to capture both the type of the collection and
      the type of its elements. This class contains methods that
      allows See this StackOverflow thread for the technique
      mapper.readValue function to create list of the correct type.
      The return value is correct at compile time. (Exactly how this
      works is not clear to me yet.)
      See this link for details:
      https://stackoverflow.com/questions/6846244/jackson-and-generic-type-reference

      Also take a look at:
      https://www.baeldung.com/guava-reflection
      https://github.com/google/guava/wiki/ReflectionExplained
      https://guava.dev/releases/21.0/api/docs/com/google/common/reflect/TypeToken.html
      https://github.com/google/guava
      https://stackoverflow.com/questions/18471701/passing-a-class-with-type-parameter-as-type-parameter-for-generic-method-in-java
     */
    JavaType type
        = mapper.getTypeFactory().constructCollectionType(
            ArrayList.class, Person.class);
    return mapper.readValue(json, type);
  }
}
