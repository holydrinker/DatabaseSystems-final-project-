package dao;


public class Query {

    public static String allPazienti = "SELECT * FROM paziente";

    public static String insertPersonaggio(String nome, String cognome, String cf){
        return "INSERT INTO paziente VALUES ('" + nome + "', '" + cognome + "', '" + cf + "')";
    }

    public static String allMedici = "SELECT * FROM medico";

    public static String insertMedico(String nome, String cognome, int matricola){
        return "INSERT INTO medico VALUES ('" + nome + "', '" + cognome + "', '" + matricola + "')";
    }

    public static String allProdotti = "SELECT * FROM prodotto";

    public static String insertProdotto(
            int id,
            String nome,
            String descrizione,
            String tipo,
            boolean prevescrivibile,
            int anni_brevetto
    ){
        return "INSERT INTO prodotto VALUES ('"
                + id + "', '"
                + nome + "', '"
                + descrizione + "', '"
                + tipo + "', '"
                + prevescrivibile + "', '"
                + anni_brevetto + "')";
    }


}
