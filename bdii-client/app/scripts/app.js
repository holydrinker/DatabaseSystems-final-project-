'use strict';

var app = angular.module('bd-client', ['ngRoute'])
    .config(function($routeProvider) {
        $routeProvider
            .when('/', {
                templateUrl : 'views/home.html'
            })
            .when('/personaggi', {
                templateUrl : 'views/personaggi.html',
                controller  : 'MainController'
            })
            .otherwise({
                redirectTo: '/'
            });
    });