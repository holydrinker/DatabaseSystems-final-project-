package entities;


import org.json.JSONException;
import org.json.JSONObject;

public class Prodotto extends Jsonizable {
    private int id;
    private String nome;
    private String descrizione;
    private String tipo;
    private boolean prescrivibile;
    private int anni_brevetto;

    public Prodotto(int id, String nome, String descrizione, String tipo, boolean prescrivibile, int anni_brevetto){
        this.id = id;
        this.nome = nome;
        this.descrizione = descrizione;
        this.tipo = tipo;
        this.prescrivibile = prescrivibile;
        this.anni_brevetto = anni_brevetto;
    }

    @Override
    public JSONObject toJson() throws JSONException {
        JSONObject json = new JSONObject();
        json.put("anni_brevetto", this.anni_brevetto);
        json.put("prescrivibile", this.prescrivibile);
        json.put("tipo", this.tipo);
        json.put("descrizione", this.descrizione);
        json.put("nome", this.nome);
        json.put("id", this.id);
        return json;
    }
}
