package entities;


import org.json.JSONException;
import org.json.JSONObject;

public class Equivalenza implements Jsonizable {
    private int farmacoBrevettato;
    private int farmacoEquivalente;

    public Equivalenza(int farmacoBrevettato, int farmacoEquivalente){
        this.farmacoBrevettato = farmacoBrevettato;
        this.farmacoEquivalente = farmacoEquivalente;
    }

    @Override
    public JSONObject toJson() throws JSONException {
        JSONObject json = new JSONObject();
        json.put("brevettato", this.farmacoBrevettato);
        json.put("equivalente", this.farmacoEquivalente);
        return json;
    }
}
