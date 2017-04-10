'use strict';

app.controller('PersonaggiCtrl', ['$scope', 'menuFactory', function($scope, menuFactory) {

    $scope.personaggi = [];
    $scope.message = "Loading...";

    menuFactory.getPersonaggi()
        .then(
            function(response){
                $scope.personaggi = response.data;
            },
            function(response) {
                $scope.message = "Error: "+response.status + " " + response.statusText;
            }
        );
}]);