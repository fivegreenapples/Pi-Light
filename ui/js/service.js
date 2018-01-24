App.service("pilightws", [

	"$http",
	"$q",
	function($http, $q) {

		var endpoint = "/ws"

		function apicall(method, params) {
			return dummyapicall(method, params)

			var methodUrl = endpoint + method
			return $http.get(methodUrl).catch(function(e) {
				console.error("web service api call to '"+methodUrl+"' failed with:", e)
			})
		}

		function dummyapicall(method, params) {

			if (method == "/getall") {
				var ret = []
				for (var i=1; i<=512; i++) {
					ret.push(Math.floor(256 * Math.random()))
				}
				return $q.when(ret)
			}
			if (method == "/setsingle") {
				return $q.when()
			}

		}

		var service = {

			getAll: function() {
				return apicall("/getall")
			},
			setChan: function(ch, val) {
				return apicall("/setsingle/"+ch, {
					value: val
				})
			}


		}
		return service

	}


])