'use strict';

app.controller('PazientiCtrl', ['$scope', '$route', 'pazientiFactory',
    function ($scope,$route, pazientiFactory) {

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
        $scope.medici_farmaci = [];
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

        mediciFactory.getMediciFarmaci()
            .then(
                function (response) {
                    $scope.medici_farmaci = response.data;
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
        $scope.case = [];

        prodottiFactory.getProdotti()
            .then(
                function (response) {
                    $scope.prodotti = response.data;
                },
                function (response) {
                    $scope.message = "Error: " + response.status + " " + response.statusText;
                }
            );

        prodottiFactory.getCase()
            .then(
                function (response) {
                    $scope.case = response.data;
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

        $scope.showCasa = function () {
            if(
                $scope.nuovoProdotto.tipo.localeCompare("farmaco brevettato") == 0 ||
                $scope.nuovoProdotto.tipo.localeCompare("farmaco generico") == 0
            ){
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
            anni_brevetto: "-1",
            casa_farmaceutica: ""
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
                        $scope.nuovoProdotto.casa_farmaceutica = "";
                        $route.reload();
                    },
                    function (response) {
                        alert("Prodotto non inserito non inserito");
                        $scope.message = "Error: " + response.status + " " + response.statusText;
                    }
                );
        };

    }])
    .controller('EquivalenzaCtrl', ['$scope', '$route', 'equivalenzaFactory', function ($scope, $route, equivalenzaFactory) {

        $scope.equivalenze = [];
        $scope.message = "Loading...";
        $scope.ricerca = "";

        equivalenzaFactory.getFarmaciEquivalenti()
            .then(
                function (response) {
                    $scope.equivalenze = response.data;
                },
                function (response) {
                    $scope.message = "Error: " + response.status + " " + response.statusText;
                }
            );

        $scope.filtra = function(){
            return function (record) {
                return record.brevettato == $scope.ricerca;
            }
        };
    }])

    .controller('PrescrizioniCtrl', ['$scope', '$route', 'prescrizioniFactory', 'prodottiFactory',
        function ($scope, $route, prescrizioniFactory, prodottiFactory) {

        $scope.prescrizioni = [];
        $scope.message = "Loading...";
        $scope.nuovaPrescrizione = {
            medico: "",
            cliente: "",
            farmaci: []
        };
        $scope.prodotti = [];

        $scope.showAddForm = function () {
            $scope.showForm = true;
        };

        prescrizioniFactory.getPrescrizioni()
            .then(
                function (response) {
                    $scope.prescrizioni = response.data;
                },
                function (response) {
                    $scope.message = "Error: " + response.status + " " + response.statusText;
                }
            );

        prodottiFactory.getProdottiPrescrivibili()
            .then(
                function (response) {
                    $scope.prodotti = response.data;
                },
                function (response) {
                    alert("Impossibile recuperare i prodotti");
                }
            );


        
        $scope.toggleSelection = function (id) {
            var idx = $scope.nuovaPrescrizione.farmaci.indexOf(id);
            if (idx > -1) {
                $scope.nuovaPrescrizione.farmaci.splice(idx, 1);
            } else{
                $scope.nuovaPrescrizione.farmaci.push(id);
            }
        };
        
        $scope.inserisciPrescrizione = function () {
            prescrizioniFactory.putPrescrizione($scope.nuovaPrescrizione)
                .then(
                    function (response) {
                        $scope.showForm = false;
                        $scope.nuovaPrescrizione.medico = "";
                        $scope.nuovaPrescrizione.paziente= "";
                        $scope.nuovaPrescrizione.farmaci= [];
                        $route.reload();
                    },
                    function (response) {
                        alert("Prescrizione non inserita.");
                    }
                );
        };

    }])

    .controller('VenditeCtrl', ['$scope', '$route', 'venditeFactory', 'prescrizioniFactory',
        function ($scope, $route, venditeFactory, prescrizioniFactory) {
            $scope.titolo = "Vendite";

            $scope.vendite = [];
            $scope.prescrizioni_ids = [];
            $scope.nuovaVendita = {
                prescrizione: "",
                prodotti: ""
            };

            $scope.showAddForm = function () {
                $scope.showForm = true;
            };


            venditeFactory.getVendite()
                .then(
                    function (response) {
                        $scope.vendite = response.data;
                        $scope.titolo = "Vendite";
                    },
                    function (response) {
                        alert("Impossibile recuperare le vendite");
                    }
                );

            $scope.getVendite = function () {
                venditeFactory.getVendite()
                    .then(
                        function (response) {
                            $scope.vendite = response.data;
                            $scope.titolo = "Vendite";
                        },
                        function (response) {
                            alert("Impossibile recuperare le vendite");
                        }
                    );
            };

            prescrizioniFactory.getPrescrizioni()
                .then(
                    function (response) {
                        var prescrizioni = response.data;
                        for(var i in prescrizioni){
                            $scope.prescrizioni_ids.push(prescrizioni[i].id);
                        }
                    },
                    function (response) {
                        alert("Impossibile recuperare le vendite");
                    }
                );

            $scope.inserisciVendita = function () {
                venditeFactory.putVendita($scope.nuovaVendita)
                    .then(
                        function (response) {
                            $scope.showForm = false;
                            $scope.nuovaVendita.prescrizione = "";
                            $scope.nuovaVendita.prodotti= "";

                            if(response.data.stato.localeCompare("no") == 0){
                                alert("Hai cercato di acquistare prodotti non validi.");
                            }

                            $route.reload();
                        },
                        function (response) {
                            alert("Vendita non inserita.");
                        }
                    );
            };

            $scope.getVenditeBrevettati = function () {
                venditeFactory.getVenditeBrevettati()
                    .then(
                        function (response) {
                            $scope.vendite = response.data;
                            $scope.titolo = "Vendite (con farmaci brevettati)";
                        },
                        function (response) {
                            alert("Impossibile recuperare le vendite brevettate");
                        }
                    );
            }
        }])
;