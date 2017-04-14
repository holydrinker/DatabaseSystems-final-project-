import entities.Medico;
import entities.Paziente;
import entities.Prodotto;
import org.json.JSONArray;
import spark.Request;
import spark.Response;
import utilities.Params;

import java.util.List;

import static spark.Spark.get;
import static spark.Spark.options;
import static spark.Spark.post;

import dao.Dao;

// mvn exec:java -Dexec.mainClass="Server"

public class Server {
    public static void main(String[] args) {
        Dao dao = Dao.getInstance();

        get("/getPazienti", (req, res) -> {
            JSONArray json = new JSONArray();

            List<Paziente> pazienti = dao.getPazienti();
            for(Paziente p : pazienti){
                json.put(p.toJson());
            }

            setResponseHeader(req, res);
            return json;
        });

        post("/insertPaziente", (req, res) -> {
            String nome = req.queryParams(Params.NOME);
            String cognome = req.queryParams(Params.COGNOME);
            String cf = req.queryParams(Params.CF);

            dao.insertPaziente(nome, cognome, cf);

            setResponseHeader(req, res);
            return "ok";
        });

        get("/getMedici", (req, res) -> {
            JSONArray json = new JSONArray();

            List<Medico> medici = dao.getMedici();
            for(Medico m : medici){
                json.put(m.toJson());
            }

            setResponseHeader(req, res);
            return json;
        });

        post("/insertMedico", (req, res) -> {
            String nome = req.queryParams(Params.NOME);
            String cognome = req.queryParams(Params.COGNOME);
            String matricola = req.queryParams(Params.MATRICOLA);

            dao.insertMedico(nome, cognome, Integer.parseInt(matricola));

            setResponseHeader(req, res);
            return "ok";
        });

        get("/getProdotti", (req, res) -> {
            JSONArray json = new JSONArray();

            List<Prodotto> medici = dao.getProdotti();
            for(Prodotto p : medici) {
                json.put(p.toJson());
            }

            setResponseHeader(req, res);
            return json;
        });

        post("/insertProdotto", (req, res) -> {
            String id_param = req.queryParams(Params.ID);
            String nome = req.queryParams(Params.NOME);
            String descrizione = req.queryParams(Params.DESCRIZIONE);
            String tipo = req.queryParams(Params.TIPO);
            String prescrivibile_param = req.queryParams(Params.PRESCRIVIBILE);
            String anni_brevetto_param = req.queryParams(Params.ANNI_BEVETTO);

            int id = Integer.parseInt(id_param);
            boolean prescrivibile = Boolean.parseBoolean(prescrivibile_param);
            int anni_brevetto = Integer.parseInt(anni_brevetto_param);

            dao.insertProdotto(id, nome, descrizione, tipo, prescrivibile, anni_brevetto);

            setResponseHeader(req, res);
            return "ok";
        });

        //Some settings
        options("/*", (request, response) -> {
            setOptionRequestResponseHeader(request, response);
            return null;
        });
    }

    private static void setResponseHeader(Request req,Response res){
        String origin=req.headers("Origin");
        res.header("access-control-allow-origin", origin);
        res.header("content-type", "text/plain");
    }

    private static void setOptionRequestResponseHeader(Request req,Response res){
        String origin=req.headers("Origin");
        res.header("access-control-allow-origin", origin);
        res.header("access-control-allow-methods", "GET, OPTIONS");
        res.header("access-control-allow-headers", "content-type, accept");
        res.header("access-control-max-age", 10 + "");
        res.header("content-length", 0 + "");
    }
}