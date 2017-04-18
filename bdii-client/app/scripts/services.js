'use strict';

app
    .constant("baseURL", "http://localhost:4567/")
    .factory('pazientiFactory', ['$http', 'baseURL', function ($http, baseURL) {

        var result = {};

        result.getPazienti = function () {
            return $http.get(baseURL + "getPazienti");
        };

        result.putPaziente = function (nuovoPaziente) {
            var data =
                "nome=" + nuovoPaziente.nome +
                "&cognome=" + nuovoPaziente.cognome +
                "&cf=" + nuovoPaziente.cf;

            return $http.post(baseURL + "insertPaziente", data, {
                headers: {'Content-Type': 'application/x-www-form-urlencoded'}
            });
        };

        return result;
    }])

    .factory('mediciFactory', ['$http', 'baseURL', function ($http, baseURL) {

        var result = {};

        result.getMedici = function () {
            return $http.get(baseURL + "getMedici");
        };

        result.putMedico = function (nuovoMedico) {
            var data =
                "nome=" + nuovoMedico.nome +
                "&cognome=" + nuovoMedico.cognome +
                "&matricola=" + nuovoMedico.matricola;

            return $http.post(baseURL + "insertMedico", data, {
                headers: {'Content-Type': 'application/x-www-form-urlencoded'}
            });
        };

        result.getMediciFarmaci = function () {
            return $http.get(baseURL + "getMedicoFarmaco");
        };

        return result;
    }])

    .factory('prodottiFactory', ['$http', 'baseURL', function ($http, baseURL) {

        var result = {};

        result.getProdotti = function () {
            return $http.get(baseURL + "getProdotti");
        };

        result.putProdotto = function (nuovoProdotto) {
            var data =
                "id=" + nuovoProdotto.id +
                "&nome=" + nuovoProdotto.nome +
                "&descrizione=" + nuovoProdotto.descrizione +
                "&tipo=" + nuovoProdotto.tipo +
                "&prescrivibile=" + nuovoProdotto.prescrivibile +
                "&anni_brevetto=" + nuovoProdotto.anni_brevetto +
                "&casa_farmaceutica=" + nuovoProdotto.casa_farmaceutica ;

            return $http.post(baseURL + "insertProdotto", data, {
                headers: {'Content-Type': 'application/x-www-form-urlencoded'}
            });
        };

        result.getCase = function () {
            return $http.get(baseURL + "getCaseFarmaceutiche");
        };

        return result;
    }])

    .factory('equivalenzaFactory', ['$http', 'baseURL', function ($http, baseURL) {

        var result = {};

        result.getFarmaciEquivalenti = function(){
            return $http.get(baseURL + "getEquivalenze");
        };

        return result;
    }])

    .factory('prescrizioniFactory', ['$http', 'baseURL', function ($http, baseURL) {

        var result = {};

        result.getPrescrizioni = function(){
            return $http.get(baseURL + "getPrescrizioni");
        };

        return result;
    }])
;

