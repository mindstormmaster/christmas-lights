var christmaslightsControllers = angular.module('christmaslightsControllers', []);

christmaslightsControllers.controller('SongListController', ['$scope', '$http',
    function ($scope, $http) {
        $http.get(window.urls.songs).success(function(data) {
            $scope.songs = data;
        });
        $http.get(window.urls.leds).success(function(data) {
            $scope.leds = data;
        });
    }]);