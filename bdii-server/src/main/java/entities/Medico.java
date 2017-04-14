package entities;


import org.json.JSONException;
import org.json.JSONObject;

public class Medico extends Jsonizable{
    private String nome;
    private String cognome;
    private int matricola;

    public Medico(String nome, String cognome, int matricola) {
        this.nome = nome;
        this.cognome = cognome;
        this.matricola = matricola;
    }

    @Override
    public JSONObject toJson() throws JSONException {
        JSONObject json = new JSONObject();
        json.put("matricola", this.matricola);
        json.put("cognome", this.cognome);
        json.put("nome", this.nome);
        return json;
    }
}
