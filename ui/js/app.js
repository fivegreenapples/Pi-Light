App = angular.module('pilight', [])


App.controller("mainCtrl", [
    "$scope",
	"$http",
	"$timeout",
	"pilightws",
    function($scope, $http, $timeout, pilightws) {

		$scope.faders = []

		pilightws.getAll().then(function(data) {
			$scope.faders = []
			data.forEach(val => {
				$scope.faders.push(val)
			});
		})

		$scope.faderChanged = function(ch, val) {
			pilightws.setChan(ch, val)
		}
	}
])



