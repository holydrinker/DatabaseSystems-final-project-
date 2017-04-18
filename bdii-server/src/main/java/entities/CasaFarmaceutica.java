package entities;


import org.json.JSONException;
import org.json.JSONObject;
import utilities.Params;

public class CasaFarmaceutica extends Jsonizable{
    private String nome_e_recapito;

    public CasaFarmaceutica(String nome_e_recapito){
        this.nome_e_recapito = nome_e_recapito;
    }

    @Override
    public JSONObject toJson() throws JSONException {
        JSONObject json = new JSONObject();
        json.put(Params.CASA, this.nome_e_recapito);
        return json;
    }
}
