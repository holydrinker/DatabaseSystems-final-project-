'use strict';

app.config(['$routeProvider',
    function ($routeProvider) {
        $routeProvider
            .when('/', {
                templateUrl: 'views/home.html'
            })
            .when('/home', {
                templateUrl: 'views/home.html'
            })
            .when('/personaggi', {
                templateUrl: 'views/personaggi.html',
                controller: 'PersonaggiCtrl'
            })
            .otherwise({
                redirectTo: '/'
            });
    }]);