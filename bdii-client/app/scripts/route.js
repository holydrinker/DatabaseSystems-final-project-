'use strict';

app.config(['$routeProvider', '$httpProvider', '$locationProvider',
    function ($routeProvider, $httpProvider, $locationProvider) {

        $locationProvider.hashPrefix('');

        $httpProvider.defaults.headers.common = {};
        $httpProvider.defaults.headers.post = {};
        $httpProvider.defaults.headers.put = {};
        $httpProvider.defaults.headers.patch = {};

        $routeProvider
            .when('/', {
                templateUrl: 'views/home.html'
            })
            .when('/pazienti', {
                templateUrl: 'views/pazienti.html',
                controller: 'PazientiCtrl'
            })
            .when('/medici', {
                templateUrl: 'views/medici.html',
                controller: 'MediciCtrl'
            })
            .when('/prodotti', {
                templateUrl: 'views/prodotti.html',
                controller: 'ProdottiCtrl'
            })
            .when('/equivalenze', {
                templateUrl: 'views/equivalenze.html',
                controller: 'EquivalenzaCtrl'
            })
            .when('/prescrizioni', {
                templateUrl: 'views/prescrizioni.html',
                controller: 'PrescrizioniCtrl'
            })
            .when('/medici_farmaci', {
                templateUrl: 'views/medici_farmaci.html',
                controller: 'MediciCtrl'
            })
            .when('/vendite', {
                templateUrl: 'views/vendite.html',
                controller: 'VenditeCtrl'
            })
    }]);