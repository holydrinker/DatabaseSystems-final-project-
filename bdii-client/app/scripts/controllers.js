'use strict';

app.controller('PazientiCtrl', ['$scope', '$route', 'pazientiFactory', function ($scope,$route, pazientiFactory) {

    $scope.pazienti = [];
    $scope.message = "Loading...";

    pazientiFactory.getPazienti()
        .then(
            function (response) {
                $scope.pazienti = response.data;
            },
            function (response) {
                $scope.message = "Error: " + response.status + " " + response.statusText;
            }
        );

    $scope.showAddForm = function () {
        $scope.showForm = true;
    };

    $scope.nuovoPaziente = {nome: "", cognome: "", cf: ""};

    $scope.inserisciPaziente = function () {
        pazientiFactory.putPaziente($scope.nuovoPaziente)
            .then(
                function (response) {
                    $scope.showForm = false;
                    $scope.nuovoPaziente.nome = "";
                    $scope.nuovoPaziente.cognome = "";
                    $scope.nuovoPaziente.cf = "";
                    $route.reload();
                },
                function (response) {
                    alert("Paziente non inserito");
                    $scope.message = "Error: " + response.status + " " + response.statusText;
                }
            );
    };

}])

    .controller('MediciCtrl', ['$scope', '$route', 'mediciFactory', function ($scope, $route, mediciFactory) {

        $scope.medici = [];
        $scope.message = "Loading...";

        mediciFactory.getMedici()
            .then(
                function (response) {
                    $scope.medici = response.data;
                },
                function (response) {
                    $scope.message = "Error: " + response.status + " " + response.statusText;
                }
            );

        $scope.showAddForm = function () {
            $scope.showForm = true;
        };

        $scope.nuovoMedico = {nome: "", cognome: "", matricola: ""};

        $scope.inserisciMedico = function () {
            mediciFactory.putMedico($scope.nuovoMedico)
                .then(
                    function (response) {
                        $scope.showForm = false;
                        $scope.nuovoMedico.nome = "";
                        $scope.nuovoMedico.cognome = "";
                        $scope.nuovoMedico.matricola = "";
                        $route.reload();
                    },
                    function (response) {
                        alert("Medico non inserito");
                        $scope.message = "Error: " + response.status + " " + response.statusText;
                    }
                );
        };

    }])
    .controller('ProdottiCtrl', ['$scope', '$route', 'prodottiFactory', function ($scope, $route, prodottiFactory) {

        $scope.prodotti = [];
        $scope.message = "Loading...";

        prodottiFactory.getProdotti()
            .then(
                function (response) {
                    $scope.prodotti = response.data;
                },
                function (response) {
                    $scope.message = "Error: " + response.status + " " + response.statusText;
                }
            );

        $scope.showAddForm = function () {
            $scope.showForm = true;
        };

        $scope.showAnniBrevetto = function () {
            if($scope.nuovoProdotto.tipo.localeCompare("farmaco brevettato") == 0){
                return true;
            } else {
                return false;
            }
        };

        $scope.nuovoProdotto = {
            id: "",
            nome: "",
            descrizione: "",
            tipo: "farmaco generico",
            prescrivibile: "true",
            anni_brevetto: "1"
        };

        $scope.inserisciProdotto = function () {

            prodottiFactory.putProdotto($scope.nuovoProdotto)
                .then(
                    function (response) {
                        $scope.showForm = false;
                        $scope.nuovoProdotto.id = "";
                        $scope.nuovoProdotto.nome = "";
                        $scope.nuovoProdotto.descrizione = "";
                        $scope.nuovoProdotto.tipo = "";
                        $scope.nuovoProdotto.prescrivibile = "";
                        $scope.nuovoProdotto.anni_brevetto = "";
                        $route.reload();
                    },
                    function (response) {
                        alert("Prodotto non inserito non inserito");
                        $scope.message = "Error: " + response.status + " " + response.statusText;
                    }
                );
        };

    }]);