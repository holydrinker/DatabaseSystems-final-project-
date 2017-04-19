package dao;


class Query {

    static String allPazienti = "SELECT * FROM paziente";

    static String insertPersonaggio(String nome, String cognome, String cf){
        return "INSERT INTO paziente VALUES ('" + nome + "', '" + cognome + "', '" + cf + "')";
    }

    static String allMedici = "SELECT * FROM medico";

    static String insertMedico(String nome, String cognome, int matricola){
        return "INSERT INTO medico VALUES ('" + nome + "', '" + cognome + "', '" + matricola + "')";
    }

    static String allProdotti = "SELECT * FROM prodotto";

    static String getCasaFarmaceutica(int idProdotto){
        return "SELECT * FROM produzione WHERE farmaco = " + idProdotto;
    }

    static String insertProdotto(
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

    static String allProdottiAudit = "SELECT * FROM prodotto_audit";

    static String insertProdotto_dt(
            String prodotto,
            String nome_prodotto,
            String tipo_prodotto){

        return "INSERT INTO prodotto_dt(prodotto, nome_prodotto, tipo_prodotto) VALUES ('" +
                prodotto + "', '" +
                nome_prodotto + "', '" +
                tipo_prodotto + "')";
    }

    static String truncateProdotto_audit = "TRUNCATE prodotto_audit";

    static String allVenditeAudit = "SELECT * FROM vendita_audit";

    static String insertVendita_ft(int id, String tempo, String quantita, String prodotto){
        return "INSERT INTO vendita_ft VALUES (" +
                id          + ", " +
                tempo       + ", " +
                quantita    + ", " +
                prodotto    + ")";
    }

    static String truncateVendita_audit = "TRUNCATE vendita_audit";

    static String recupera_record_prodotto(String prodotto){
            return "SELECT id FROM prodotto_dt WHERE prodotto = '" + prodotto + "'";
    }

    static String allEquivalenze = "SELECT * FROM equivalenza";

    static String allPrescrizioni = "SELECT * FROM prescrizione";

    static String getFarmaci_Prescrizione (int idPrescrizione) {
        return "SELECT * FROM prescrizione_farmaci WHERE prescrizione = " + idPrescrizione;
    }

    static String getAllCaseFarmaceutiche = "SELECT * FROM casa_farmaceutica";

    static String insertProduzione(int farmaco, String nome_casa, String recapito_casa){
        return "INSERT INTO produzione VALUES (" + farmaco + ", '" + nome_casa + "', '" + recapito_casa + "')";
    }

    static String getMediciFarmaci = "SELECT * FROM medico_farmaco";

    static String insertPrescrizione(String medico, String paziente){
        return "INSERT INTO prescrizione(medico, paziente) VALUES (" + medico + ", '" + paziente + "')";
    }

    static String insertProdottoPrescritto(int prescrizione, int farmaco){
        return "INSERT INTO prescrizione_farmaci(prescrizione, farmaco) VALUES (" + prescrizione + ", " + farmaco + ")";
    }

    static String getLastIdPrescrizione = "SELECT MAX(id) AS id FROM prescrizione";

    static String getFarmaciPrescrivibili = "SELECT id FROM prodotto WHERE prescrivibile=true";

    static String allVendite = "SELECT * FROM vendita";

    static String getProdottiVendita(int idVendita){
        return "SELECT * FROM vendita_prodotto WHERE vendita = " + idVendita ;
    }

    static String insertVendita(String prescrizione, String data){
        if(prescrizione.equals("")){
            return "INSERT INTO vendita(data) VALUES (to_date('" + data + "', 'DD/MM/YYYY'))";
        } else {
            //System.out.println("INSERT INTO vendita VALUES (" + Integer.parseInt(prescrizione) + ", to_date('" + data + "', 'DD/MM/YYYY'))");
            return "INSERT INTO vendita(prescrizione, data) VALUES (" + Integer.parseInt(prescrizione) + ", to_date('" + data + "', 'DD/MM/YYYY'))";
        }
    }

    static String insertProdottoVendita(int vendita, int prodotto, int quantita){
        return  "INSERT INTO vendita_prodotto VALUES (" + vendita + ", " + prodotto + ", " + quantita + ")";
    }

    static String getLastVenditaId = "SELECT MAX(id) AS id FROM vendita";

    static String deleteVenditaProdotto(int idVendita){
        return "DELETE FROM vendita_prodotto WHERE vendita = " + idVendita;
    }

    static String deleteVendita(int idVendita) {
        return "DELETE FROM vendita WHERE id = " + idVendita;
    }

    static String getVenditaAuditIdToDelete(int rowDeleted){
        return "SELECT * FROM vendita_audit ORDER BY id LIMIT " + rowDeleted;
    }

    static String deleteFromVenditaAudit(int id){
        return "DELETE FROM vendita_audit WHERE id = " + id;
    }

    static String deleteFromProdottiAudit(int id){
        return "DELETE FROM prodotto_audit WHERE prodotto = '" + id + "'";
    }

    static String allVenditeBrevettate = "" +
            "SELECT vendita.id, vendita.data, vendita.prescrizione " +
            "FROM prodotto, vendita_prodotto, vendita " +
            "WHERE prodotto.id = vendita_prodotto.prodotto " +
            "AND vendita_prodotto.vendita = vendita.id " +
            "AND tipo = 'farmaco brevettato'";

}
