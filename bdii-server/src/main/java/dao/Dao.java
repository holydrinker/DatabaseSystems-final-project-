package dao;

import entities.Medico;
import entities.Paziente;
import entities.Prodotto;
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

    public List<Paziente> getPazienti() {
        List<Paziente> result = new LinkedList<>();

        try {
            Statement st = connection.createStatement();
            ResultSet rs = st.executeQuery(Query.allPazienti);

            while (rs.next()) {
                String nome = rs.getString("nome");
                String cognome = rs.getString("cognome");
                String cf = rs.getString("cf");
                Paziente p = new Paziente(nome, cognome, cf);
                result.add(p);
            }

            rs.close();
            st.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    public void insertPaziente(String nome, String cognome, String cf){
        try {
            Statement st = connection.createStatement();
            st.execute(Query.insertPersonaggio(nome, cognome, cf));
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Medico> getMedici() {
        List<Medico> result = new LinkedList<>();

        try {
            Statement st = connection.createStatement();
            ResultSet rs = st.executeQuery(Query.allMedici);

            while (rs.next()) {
                String nome = rs.getString("nome");
                String cognome = rs.getString("cognome");
                int matricola = rs.getInt("matricola");
                Medico m = new Medico(nome, cognome, matricola);
                result.add(m);
            }

            rs.close();
            st.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    public void insertMedico(String nome, String cognome, int matricola){
        try {
            Statement st = connection.createStatement();
            st.execute(Query.insertMedico(nome, cognome, matricola));
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Prodotto> getProdotti() {
        List<Prodotto> result = new LinkedList<>();

        try {
            Statement st = connection.createStatement();
            ResultSet rs = st.executeQuery(Query.allProdotti);

            while (rs.next()) {
                int id = rs.getInt(Params.ID);
                String nome = rs.getString(Params.NOME);
                String descizione = rs.getString(Params.DESCRIZIONE);
                String tipo = rs.getString(Params.TIPO);
                boolean prescrivibile = rs.getBoolean(Params.PRESCRIVIBILE);
                int anni_brevetto = rs.getInt(Params.ANNI_BEVETTO);

                Prodotto p = new Prodotto(
                        id,
                        nome,
                        descizione,
                        tipo,
                        prescrivibile,
                        anni_brevetto
                );

                result.add(p);
            }

            rs.close();
            st.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    public void insertProdotto(
            int id,
            String nome,
            String descrizione,
            String tipo,
            boolean prevescrivibile,
            int anni_brevetto){

        try {
            Statement st = connection.createStatement();
            st.execute(Query.insertProdotto(id, nome, descrizione, tipo, prevescrivibile, anni_brevetto));
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

}
