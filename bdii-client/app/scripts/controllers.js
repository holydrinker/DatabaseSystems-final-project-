'use strict';

app.controller('PersonaggiCtrl', ['$scope', 'personaggiFactory', function ($scope, personaggiFactory) {

    $scope.personaggi = [];
    $scope.message = "Loading...";

    personaggiFactory.getPersonaggi()
        .then(
            function (response) {
                $scope.personaggi = response.data;
            },
            function (response) {
                $scope.message = "Error: " + response.status + " " + response.statusText;
            }
        );

    $scope.showAddForm = function () {
        $scope.showForm = true;
    };

    $scope.nuovoPersonaggio = {nome: "", tipo: ""};

    $scope.inserisciPersonaggio = function () {
        personaggiFactory.putPersonaggio($scope.nuovoPersonaggio)
            .then(
                function (response) {
                    $scope.showForm = false;
                },
                function (response) {
                    alert("Personaggio non inserito");
                    $scope.message = "Error: " + response.status + " " + response.statusText;
                }
            );
    };

}]);