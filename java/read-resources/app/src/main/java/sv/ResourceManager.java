package sv;

import org.jetbrains.annotations.NotNull;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

public class ResourceManager {
  public static @NotNull String loadFileFromResources(
      @NotNull String filename) throws IOException {
    var stringBuilder = new StringBuilder();
    var classLoader = Thread.currentThread().getContextClassLoader();
    if (classLoader == null)
      throw new IOException(
          "Could not get class loader for the current thread.");
    var is = classLoader.getResourceAsStream(filename);
    if (is == null)
      throw new IOException(
          "Could not find resource stream " + filename);
    var isr =  new InputStreamReader(is, StandardCharsets.UTF_8);
    try (var br = new BufferedReader(isr)) {
      String line;
      while ((line = br.readLine()) != null) {
        stringBuilder.append(line).append("\n");
      }
    }
    return stringBuilder.toString();
  }
}
