import dao.Dao;
import entities.Vendita;
import java.util.List;
import dao.Query;

public class Brevet {
    public static void main(String[] args) {
        Dao dao = Dao.getInstance();
        System.out.println(Query.allVenditeBrevettate);
        //List<Vendita> br = dao.getVenditeBrevettate();
        //System.out.println("ok");

    }
}
