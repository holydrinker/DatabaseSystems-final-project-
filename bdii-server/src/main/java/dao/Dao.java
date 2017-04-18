package dao;

import entities.*;
import utilities.Params;

import javax.sql.StatementEvent;
import javax.swing.plaf.nimbus.State;
import java.sql.*;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;


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

    public String getCasaFarmaceutica(int idProdotto){
        try{
            Statement st = connection.createStatement();
            ResultSet rs = st.executeQuery(Query.getCasaFarmaceutica(idProdotto));
            while(rs.next()){
                String nome = rs.getString(Params.NOME_CASA_FARMACEUTICA);
                String recapito = rs.getString(Params.RECAPITO_CASA_FARMACEUTICA);
                return nome + " (" + recapito + ")";
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "";
    }

    public List<CasaFarmaceutica> getAndComposeAllCaseFarmaceutiche(){
        List<CasaFarmaceutica> result = new LinkedList<>();
        try{
            Statement st = connection.createStatement();
            ResultSet rs = st.executeQuery(Query.getAllCaseFarmaceutiche);
            while(rs.next()){
                String nome = rs.getString(Params.NOME);
                String recapito = rs.getString(Params.RECAPITO);
                result.add(new CasaFarmaceutica(nome + " (" + recapito + ")"));
            }
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

    public List<Equivalenza> getEquivalenze(){
        List<Equivalenza> result = new LinkedList<>();
        try {
            Statement st = connection.createStatement();
            ResultSet rs = st.executeQuery(Query.allEquivalenze);
            while(rs.next()){
                Integer brevettato = Integer.parseInt(rs.getString(Params.FARMACO_BREVETTATO));
                Integer equivalente = Integer.parseInt(rs.getString(Params.FARMACO_GENERICO));
                Equivalenza e = new Equivalenza(brevettato, equivalente);
                result.add(e);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    public List<Prescrizione> getPrescrizioni() {
        List<Prescrizione> result = new LinkedList<>();
        try {
            Statement st = connection.createStatement();
            ResultSet rs = st.executeQuery(Query.allPrescrizioni);
            while(rs.next()){
                Integer id = rs.getInt(Params.ID);
                Integer codiceMedico = rs.getInt(Params.MEDICO);
                String cfPaziente = rs.getString(Params.PAZIENTE);
                Prescrizione p = new Prescrizione(id, codiceMedico, cfPaziente);
                result.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    public List<Integer> getFarmaciPrescrizione(int idPrescrizione) {
        List<Integer> result = new LinkedList<>();
        try{
            Statement st = connection.createStatement();
            ResultSet rs = st.executeQuery(Query.getFarmaci_Prescrizione(idPrescrizione));
            while(rs.next()){
                result.add(rs.getInt(Params.FARMACO));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    public void insertProduzione(int farmaco, String nome_casa_farmaceutica, String recapito_casa_farmaceutica) {
        try {
            Statement st = connection.createStatement();
            st.execute(Query.insertProduzione(farmaco, nome_casa_farmaceutica, recapito_casa_farmaceutica));
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<MedicoFarmaco> getMedicoFarmaco(){
        List<MedicoFarmaco> result = new LinkedList<>();
        try{
            Statement st = connection.createStatement();
            ResultSet rs = st.executeQuery(Query.getMediciFarmaci);
            while(rs.next()){
                Integer medico = rs.getInt(Params.MEDICO);
                Integer farmaco = rs.getInt(Params.FARMACO);
                MedicoFarmaco mf = new MedicoFarmaco(medico, farmaco);
                result.add(mf);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    public void insertPrescrizione(String medico, String paziente, List<Integer> farmaci){
        try{
            // Inserire prescrizione
            Statement st = connection.createStatement();
            st.execute(Query.insertPrescrizione(medico, paziente));

            // Recuperare ID
            st = connection.createStatement();
            ResultSet rs = st.executeQuery(Query.getLastIdPrescrizione);
            int id = -1;
            while(rs.next()){
                id = rs.getInt(Params.ID);
            }

            // Inserire coppie (id - faramco)
            for(Integer faramco: farmaci){
                st = connection.createStatement();
                st.execute(Query.insertProdottoPrescritto(id, faramco));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Integer> getFaramciPrescrivibili() {
        LinkedList<Integer> result = new LinkedList<>();
        try{
            Statement st = connection.createStatement();
            ResultSet rs = st.executeQuery(Query.getFarmaciPrescrivibili);
            while(rs.next()){
                result.add(rs.getInt(Params.ID));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    public List<Vendita> getVendite(){
        List <Vendita> result = new LinkedList<>();
        try{
            Statement st = connection.createStatement();
            ResultSet rs = st.executeQuery(Query.allVendite);
            while(rs.next()){
                int id = rs.getInt(Params.ID);
                String data = rs.getString(Params.DATA);
                String prescrizione = rs.getString(Params.PRESCRIZIONE);

                // Recupera i prodotti associati alla vendita
                String prodotti = "";
                st = connection.createStatement();
                ResultSet rsp = st.executeQuery(Query.getProdottiVendita(id));
                while(rsp.next()){
                    String prodotto = rsp.getString(Params.PRODOTTO);
                    String quantita = rsp.getString(Params.QUANTITA);
                    String format = Params.PRODOTTO + ": " + prodotto + " x " + quantita;
                    prodotti += format + " - ";
                }
                prodotti = prodotti.substring(0, prodotti.length() - 2);

                Vendita v = new Vendita(id, data, prescrizione, prodotti);
                result.add(v);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    public String insertVendita(String prescrizione, String data, int[] prodotti, int[] quantita){
        boolean ok = false;
        Set<Integer> prodottiAuditBackup = new HashSet<>();

        // Registrare la vendita
        try {
            Statement st = connection.createStatement();
            st.execute(Query.insertVendita(prescrizione, data));
            ok = true;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        if(ok){
            try {
                // Mi servono tutti i prodotti già presenti nella tabella audit prima di fare un nuovo insert.
                // Verranno usati in caso di rollback-----------------------|
                Statement st = connection.createStatement();
                ResultSet rs = st.executeQuery(Query.allProdottiAudit);
                while(rs.next()){
                    prodottiAuditBackup.add(rs.getInt(Params.ID));
                }//---------------------------------------------------------|

                // Registra i prodotti acquistati nell'ultima vendita
                for (int i = 0; i < prodotti.length; i++) {
                    rs = connection.createStatement().executeQuery(Query.getLastVenditaId);
                    int vendita = -1;
                    while (rs.next()) {
                        vendita = rs.getInt(Params.ID);
                    }
                    int prodotto = prodotti[i];
                    int quant = quantita[i];

                    connection.createStatement().execute(Query.insertProdottoVendita(vendita, prodotto, quant));
                }
            } catch(SQLException e){
                /* Se ci sono stati problemi nell'inserimento dei prodotti, bisogna gestire manualmente
                   il rollback sia sui prodotti di questa vendita già inseriti prima dell'errore, sia poi sulla vendita */
                try {
                    Statement st = connection.createStatement();
                    ResultSet rs = st.executeQuery(Query.getLastVenditaId);
                    int id = -1;
                    while(rs.next()){
                        id = rs.getInt(Params.ID);
                    }
                    int rowDeleted = connection.createStatement().executeUpdate(Query.deleteVenditaProdotto(id));
                    connection.createStatement().execute(Query.deleteVendita(id));

                    // Infine, bisogna fare il rollback anche sulle tuple inserite dai trigger nelle tabella audit
                    // Cancello le ultime k vendite inserite basandomi sul numero di rowDeleted
                    rs = connection.createStatement().executeQuery(Query.getVenditaAuditIdToDelete(rowDeleted));
                    while(rs.next()){
                        int id_audit = rs.getInt(Params.ID);
                        st = connection.createStatement();
                        //System.out.println(Query.deleteFromVenditaAudit(id_audit));
                        st.execute(Query.deleteFromVenditaAudit(id_audit));
                    }

                    // Cancello i prodotti inseriti nella audit. Qui devo fare un confronto fra ciò ceh c'era prima e dopo
                    // Uso prodottiAuditBackup calcolati all'inizio. Rifaccio lo stesso calcolo e lo confronto
                    rs = connection.createStatement().executeQuery(Query.allProdottiAudit);
                    while(rs.next()){
                        int id_audit = rs.getInt(Params.PRODOTTO);
                        if(!prodottiAuditBackup.contains(id_audit)){ //è stato appena inserito e va coinvolto nel rollback
                            connection.createStatement().execute(Query.deleteFromProdottiAudit(id_audit));
                        }
                    }
                    return "no";

                } catch (SQLException e1) {
                    System.out.println("Impossibile effettuare il rollback delle vendite");
                    e1.printStackTrace();
                }
            }
        }
        return "ok";
    }

    public List<Vendita> getVenditeBrevettate(){
        List <Vendita> result = new LinkedList<>();
        try{
            Statement st = connection.createStatement();
            ResultSet rs = st.executeQuery(Query.allVenditeBrevettate);
            while(rs.next()){
                int id = rs.getInt(Params.ID);
                String data = rs.getString(Params.DATA);
                String prescrizione = rs.getString(Params.PRESCRIZIONE);

                // Recupera i prodotti associati alla vendita
                String prodotti = "";
                st = connection.createStatement();
                ResultSet rsp = st.executeQuery(Query.getProdottiVendita(id));
                while(rsp.next()){
                    String prodotto = rsp.getString(Params.PRODOTTO);
                    String quantita = rsp.getString(Params.QUANTITA);
                    String format = Params.PRODOTTO + ": " + prodotto + " x " + quantita;
                    prodotti += format + " - ";
                }
                prodotti = prodotti.substring(0, prodotti.length() - 2);

                Vendita v = new Vendita(id, data, prescrizione, prodotti);
                result.add(v);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }
    // DW --------------------------------------------------------------------------------------------------------------

    public void dwSync(){
        svuota_prodotto_audit();
        svuota_vendite_audit();
    }

    private void svuota_prodotto_audit(){
        try {
            Statement st1 = connection.createStatement();
            ResultSet rs = st1.executeQuery(Query.allProdottiAudit);

            while(rs.next()){
                String prodotto = rs.getString(Params.PRODOTTO);
                String nome_prodotto = rs.getString(Params.NOME_PRODOTTO);
                String tipo_prodotto = rs.getString(Params.TIPO_PRODOTTO);

                connection.createStatement()
                        .execute(Query.insertProdotto_dt(prodotto, nome_prodotto, tipo_prodotto));
            }
            connection.createStatement().execute(Query.truncateProdotto_audit);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private void svuota_vendite_audit(){
        try {
            Statement st1 = connection.createStatement();
            ResultSet rs = st1.executeQuery(Query.allVenditeAudit);
            String prodotto_id = "";

            while(rs.next()) {
                Integer id = rs.getInt(Params.ID);
                Integer tempo = rs.getInt(Params.TEMPO);
                Integer quantita = rs.getInt(Params.QUANTITA);
                Integer prodotto = rs.getInt(Params.PRODOTTO);

                ResultSet prodotto_rs =
                        connection.createStatement().executeQuery(Query.recupera_record_prodotto(prodotto.toString()));

                while(prodotto_rs.next()){
                    prodotto_id = prodotto_rs.getString(Params.ID);
                }

                connection.createStatement()
                        .execute(Query.insertVendita_ft(id, tempo.toString(), quantita.toString(), prodotto_id));
            }
            connection.createStatement().execute(Query.truncateVendita_audit);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
