'use strict';

app.config(['$routeProvider', '$httpProvider',
    function ($routeProvider, $httpProvider) {

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