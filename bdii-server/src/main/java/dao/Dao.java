package dao;

import entities.Personaggio;
import org.json.JSONException;
import utilities.Params;

import java.sql.*;
import java.util.LinkedList;
import java.util.List;


public class Dao {
    // Implement singleton pattern ---------------------------------------------
    private static Dao dao = null;
    private Connection connection = null;


    private Dao (){
        String db = Config.DB;
        String username = Config.USER;
        String password = Config.PASSWORD;

        try {
            Class.forName(Config.DRIVER);
            connection = DriverManager.getConnection(db, username, password);
            if(connection == null){
                System.out.println("Connection failed :(");
                System.exit(0);
            } else {
                System.out.println("Connection established! :)");
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
    }

    public static Dao getInstance(){
        if (dao == null)
                return new Dao();
        else
            return dao;
    }
    // -----------------------------------------------------------------------------

    public List<Personaggio> getPersonaggi(){
        List<Personaggio> result = new LinkedList<>();

        try {
            Statement st = connection.createStatement();
            ResultSet rs = st.executeQuery(Query.getPersonaggi());

            while (rs.next()) {
                Personaggio p = new Personaggio(rs.getString("nome"), rs.getString("tipo"));
                result.add(p);
            }

            rs.close();
            st.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    public Personaggio getPersonaggio(String nome) throws JSONException {
        Personaggio result = null;

        try {
            Statement st = connection.createStatement();
            ResultSet rs = st.executeQuery(Query.getPersonaggio(nome));

            while (rs.next()) {
                result = new Personaggio(rs.getString(Params.NOME), rs.getString(Params.TIPO));
            }
            rs.close();
            st.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return result;
    }

    public void insertPersonaggio(String nome, String tipo){
        try {
            Statement st = connection.createStatement();
            st.execute(Query.insertPersonaggio(nome, tipo));
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
