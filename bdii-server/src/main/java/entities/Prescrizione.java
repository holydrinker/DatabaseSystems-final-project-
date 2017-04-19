package entities;


import org.json.JSONException;
import org.json.JSONObject;

public class Prescrizione implements Jsonizable {
    private int id;
    private int codiceMedico;
    private String cfPaziente;

    public Prescrizione(int id, int codiceMedico, String cfPaziente) {
        this.id = id;
        this.codiceMedico = codiceMedico;
        this.cfPaziente = cfPaziente;
    }

    @Override
    public JSONObject toJson() throws JSONException {
        JSONObject json = new JSONObject();
        json.put("id", this.id);
        json.put("codiceMedico", this.codiceMedico);
        json.put("cfPaziente", this.cfPaziente);
        return json;
    }
}
