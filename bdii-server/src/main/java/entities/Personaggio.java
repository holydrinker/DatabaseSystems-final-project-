package entities;


import org.json.JSONException;
import org.json.JSONObject;

public class Personaggio extends Jsonizable {
    private String nome;
    private String tipo;

    public Personaggio (String nome, String tipo) {
        this.nome = nome;
        this.tipo = tipo;
    }

    @Override
    public String toString() {
        return nome + " " + tipo;
    }

    @Override
    public JSONObject toJson() throws JSONException {
        JSONObject json = new JSONObject();
        json.put("tipo", this.tipo);
        json.put("nome", this.nome);
        return json;
    }
}
