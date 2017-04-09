package entities;


import org.json.JSONException;
import org.json.JSONObject;

public abstract class Jsonizable {
    public abstract JSONObject toJson() throws JSONException;
}
