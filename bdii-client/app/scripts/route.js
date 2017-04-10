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
            .when('/personaggi', {
                templateUrl: 'views/personaggi.html',
                controller: 'PersonaggiCtrl'
            })
    }]);