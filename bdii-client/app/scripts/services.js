'use strict';

app
    .constant("baseURL", "http://localhost:4567/")
    .factory('personaggiFactory', ['$http', 'baseURL', function ($http, baseURL) {

        var result = {};

        result.getPersonaggi = function () {
            return $http.get(baseURL + "getPersonaggi");
        };

        result.putPersonaggio = function (nuovoPersonaggio) {
            var data = "nome=" + nuovoPersonaggio.nome + "&tipo=" + nuovoPersonaggio.tipo;

            return $http.post(baseURL + "insertPersonaggio", data, {
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
            });
        };

        return result;
    }]);