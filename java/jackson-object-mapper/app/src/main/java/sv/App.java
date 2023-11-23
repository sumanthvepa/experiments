package sv;


public class App {
  public static void main(String[] args) {
    try {
      var companyMapper = new CompanyMapper();
      System.out.println(companyMapper.serialize(Data.company));
    } catch (Exception ex) {
      ex.printStackTrace(System.err);
    }
  }
}
