package dao;

/**
 * Created by Peppo on 20/03/2017.
 */
public class Query {

    public static String getPersonaggi(){
        return "select * from personaggio";
    }

    public static String getPersonaggio(String nome){
        return "SELECT * FROM Personaggio WHERE nome = '" + nome + "'";
    }
}
