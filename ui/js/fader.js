App.directive("fader", function() {

	return {
		restrict: 'E',
		templateUrl: 'partials/fader.html',
		scope: {
			channel:"<",
			value:"=",
			onchange:"&",
		},
		controller: [ 
			"$scope",
			"$attrs",
			function($scope, $attrs) {

				var moving = false, moveStart = null
				$scope.mousedown = function(e) {
					var moveStart = e.originalEvent.x
					var posAtStart = $scope.value
					var mousemove = function(ev) {
						var moveDelta = ev.originalEvent.x-moveStart
						$scope.value = posAtStart+(moveDelta/2)
						$scope.value = Math.min(255, Math.max(0, $scope.value))
						$scope.value = Math.round($scope.value)
						$scope.$apply()
						$scope.onchange({
							chan: $scope.channel,
							val: $scope.value
						})
					}
					var mouseup = function(ev) {
						$(document).off("mousemove", mousemove)
						$(document).off("mouseup", mouseup)
					}
					$(document).on("mouseup", mouseup)
					$(document).on("mousemove", mousemove)
				}
			}
		]
	}
})