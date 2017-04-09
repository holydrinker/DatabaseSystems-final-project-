'use strict';

app
    .constant("baseURL", "http://localhost:4567/")
    .factory('menuFactory', ['$http', 'baseURL', function ($http, baseURL) {

        var result = {};

        result.getPersonaggi = function () {
            return $http.get(baseURL + "getPersonaggi");
        };

        return result;
    }]);