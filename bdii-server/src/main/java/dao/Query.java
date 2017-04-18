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

    public static String getCasaFarmaceutica(int idProdotto){
        return "SELECT * FROM produzione WHERE farmaco = " + idProdotto;
    }

    public static String insertProdotto(
            int id,
            String nome,
            String descrizione,
            String tipo,
            boolean prevescrivibile,
            int anni_brevetto
    ){
        return "INSERT INTO prodotto VALUES ("
                + id + ", '"
                + nome + "', '"
                + descrizione + "', '"
                + tipo + "', '"
                + prevescrivibile + "', "
                + anni_brevetto + ")";
    }

    public static String allProdottiAudit = "SELECT * FROM prodotto_audit";

    public static String insertProdotto_dt(
            String prodotto,
            String nome_prodotto,
            String tipo_prodotto){

        return "INSERT INTO prodotto_dt(prodotto, nome_prodotto, tipo_prodotto) VALUES ('" +
                prodotto + "', '" +
                nome_prodotto + "', '" +
                tipo_prodotto + "')";
    }

    public static String truncateProdotto_audit = "TRUNCATE prodotto_audit";

    public static String allVenditeAudit = "SELECT * FROM vendita_audit";

    public static String insertVendita_ft(int id, String tempo, String quantita, String prodotto){
        return "INSERT INTO vendita_ft VALUES (" +
                id          + ", " +
                tempo       + ", " +
                quantita    + ", " +
                prodotto    + ")";
    }

    public static String truncateVendita_audit = "TRUNCATE vendita_audit";

    public static String recupera_record_prodotto(String prodotto){
            return "SELECT id FROM prodotto_dt WHERE prodotto = '" + prodotto + "'";
    }

    public static String allEquivalenze = "SELECT * FROM equivalenza";

    public static String allPrescrizioni = "SELECT * FROM prescrizione";

    public static String getFarmaci_Prescrizione (int idPrescrizione) {
        return "SELECT * FROM prescrizione_farmaci WHERE prescrizione = " + idPrescrizione;
    }

    public static String getAllCaseFarmaceutiche = "SELECT * FROM casa_farmaceutica";

    public static String insertProduzione(int farmaco, String nome_casa, String recapito_casa){
        return "INSERT INTO produzione VALUES (" + farmaco + ", '" + nome_casa + "', '" + recapito_casa + "')";
    }

    public static String getMediciFarmaci = "SELECT * FROM medico_farmaco";
}
