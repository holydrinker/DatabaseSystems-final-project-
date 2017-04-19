package entities;


import org.json.JSONException;
import org.json.JSONObject;
import utilities.Params;

public class MedicoFarmaco implements Jsonizable {
    private int medico;
    private int farmaco;

    public MedicoFarmaco(int medico, int farmaco){
        this.medico = medico;
        this.farmaco = farmaco;
    }

    @Override
    public JSONObject toJson() throws JSONException {
        JSONObject json = new JSONObject();
        json.put(Params.FARMACO, this.farmaco);
        json.put(Params.MEDICO, this.medico);
        return json;
    }
}
