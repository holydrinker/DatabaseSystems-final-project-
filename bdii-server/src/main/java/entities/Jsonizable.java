package entities;


import org.json.JSONException;
import org.json.JSONObject;

public interface Jsonizable {
    JSONObject toJson() throws JSONException;
}
