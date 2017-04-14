package entities;


import org.json.JSONException;
import org.json.JSONObject;

public class Paziente extends Jsonizable {
    private String nome;
    private String cognome;
    private String cf;

    public Paziente(String nome, String cognome, String cf){
        this.nome = nome;
        this.cognome = cognome;
        this.cf = cf;
    }

    @Override
    public JSONObject toJson() throws JSONException {
        JSONObject json = new JSONObject();
        json.put("cf", this.cf);
        json.put("cognome", this.cognome);
        json.put("nome", this.nome);
        return json;
    }
}
