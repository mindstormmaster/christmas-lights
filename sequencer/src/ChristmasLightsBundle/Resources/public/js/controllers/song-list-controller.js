var christmaslightsControllers = angular.module('christmaslightsControllers', []);

christmaslightsControllers.controller('SongListController', ['$scope', '$http',
    function ($scope, $http) {
        $http.get(window.urls.songs).success(function(data) {
            $scope.songs = data;
        });
    }]);

christmaslightsControllers.controller('SongDetailController', ['$scope', '$routeParams', '$http', '$filter',
    function($scope, $routeParams, $http, $filter) {
        $scope.songId = $routeParams.songId;

        $scope.song = {
            Offset: 8
        };

        $http.get(window.urls.leds).success(function(data) {
            $scope.leds = data;
        });
        $http.get(window.urls.keyframes.replace('{song_id}', $scope.songId)).success(function(data) {
            $scope.keyframes = data;

            var foo = [];
            for (var i = 1; i <= Math.floor($scope.keyframes.length / 40); i++) {
                foo.push(i);
            }
            $scope.measures = foo;

            $('#waveform').css('width', data.length*10+'px');

            var waveform = new Waveform({
                container: document.getElementById("waveform"),
                data: $scope.waveformData.left,
                innerColor: "#333"
            });
        });
        $http.get(window.urls.led_keyframes.replace('{song_id}', $scope.songId)).success(function(data) {
            $scope.ledKeyframes = data;
        });

        $http.get('/lovedrug.json').success(function(data) {
            $scope.waveformData = data;
        });

        $scope.keyframeValue = function(led, frame) {
            if ($scope.ledKeyframes !== undefined) {
                var ledFrame = $filter('filter')($scope.ledKeyframes[led.Id], {Timestamp: frame.Timestamp}, true);
                if (ledFrame.length > 0) {
                    return ledFrame[0].Value;
                } else {
                    return 0;
                }
            }
        };

        $scope.keyframeStyle = function(led, frame) {
            var value = $scope.keyframeValue(led, frame);
            return "background-color: rgb("+value+","+value+","+value+");";
        };

        $scope.toggleLed = function(led, frame) {
            $http.get(window.urls.toggle_led
                .replace('{song_id}', $scope.songId)
                .replace('{timestamp}', frame.Timestamp)
                .replace('{led_id}', led.Id)
            ).success(function(data) {
                $scope.refreshLedFrames(led);
            });
        };

        $scope.refreshLedFrames = function(led) {
            $http.get(window.urls.single_led
                .replace('{song_id}', $scope.songId)
                .replace('{led_id}', led.Id)
            ).success(function(data) {
                $scope.ledKeyframes[led.Id] = data;
            });
        };

    }]);