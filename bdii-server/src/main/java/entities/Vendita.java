package entities;


import org.json.JSONException;
import org.json.JSONObject;
import utilities.Params;


public class Vendita extends Jsonizable {
    public int id;
    public String data;
    public String prescrizione;
    public String prodotti;

    public Vendita(int id, String data, String prescrizione, String prodotti){
        this.id = id;
        this.data = data;
        this.prescrizione = prescrizione;
        this.prodotti = prodotti;
    }

    @Override
    public JSONObject toJson() throws JSONException {
        JSONObject json = new JSONObject();
        json.put(Params.PRODOTTI, this.prodotti);
        json.put(Params.PRESCRIZIONE, this.prescrizione);
        json.put(Params.DATA, this.data);
        json.put(Params.ID, this.id);
        return json;
    }
}
