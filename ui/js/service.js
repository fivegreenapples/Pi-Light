App.service("pilightws", [

	"$http",
	"$q",
	function($http, $q) {

		var endpoint = "/ws/0"

		function apicall(httpMethod, method, params) {
			var methodUrl = endpoint + method
			return $http[httpMethod](methodUrl, params)
				.then(function(resp) {
					var data = resp.data
					if (data.status && data.status == "OK") {
						return data.data
					}
					if (data.status && data.status == "ERROR") {
						console.error("web service api call to '"+methodUrl+"' failed with:", data.reason)
					}
					console.error("web service api call to '"+methodUrl+"' failed with bad response", data)
				})
				.catch(function(e) {
					console.error("web service api call to '"+methodUrl+"' failed with:", e)
					return $q.reject(e)
				})
		}

		var service = {

			getAll: function() {
				return apicall("get", "/getall")
			},
			setChan: function(ch, val) {
				return apicall("post", "/setsingle/"+ch, {
					value: Number(val)
				})
			}


		}
		return service

	}


])