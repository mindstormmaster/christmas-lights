'use strict';

var app = angular.module("christmaslightsApp", ['ngRoute', 'christmaslightsControllers']);

app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider
        .when("/songs", {
            templateUrl: "/bundles/christmaslights/templates/song-list.html",
            controller: "SongListController"
        })
        .otherwise({
            redirectTo: '/songs'
        });
}]);