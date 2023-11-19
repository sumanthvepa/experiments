package sv;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.io.IOException;


public class ResourceManagerTest {
  @Test public void testLoadFileFromResources() throws IOException {
    var input = "test-sample.txt";
    var expectedOutput = "test data\n";
    var actualOutput
        = ResourceManager.loadFileFromResources(input);
    assertEquals(expectedOutput, actualOutput);
  }
}
