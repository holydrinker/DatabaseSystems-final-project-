import dao.*;
import entities.Personaggio;
import org.json.JSONArray;
import spark.Request;
import spark.Response;
import utilities.Params;

import java.util.List;

import static spark.Spark.get;
import static spark.Spark.options;
import static spark.Spark.post;

// mvn exec:java -Dexec.mainClass="Server"

public class Server {
    public static void main(String[] args) {
        Dao dao = Dao.getInstance();

        get("/hello", (req, res) -> {
            System.out.println("Say hello...");
            return "Hello World";
        });

        get("/getPersonaggi", (req, res) -> {
            JSONArray json = new JSONArray();

            List<Personaggio> personaggi = dao.getPersonaggi();
            for(Personaggio p : personaggi){
                json.put(p.toJson());
            }

            setResponseHeader(req, res);
            return json;
        });

        get("/getPersonaggio", (req, res) -> {
            String nome = req.queryParams(Params.NOME);

            setResponseHeader(req, res);
            return dao.getPersonaggio(nome).toJson();
        });

        post("/insertPersonaggio", (req, res) -> {
            String nome = req.queryParams(Params.NOME);
            String tipo = req.queryParams(Params.TIPO);
            System.out.println("nuovo = [" + nome + " " + tipo + "]");
            dao.insertPersonaggio(nome, tipo);

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