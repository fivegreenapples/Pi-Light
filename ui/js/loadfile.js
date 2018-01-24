App.service("loadFile", [
	"$q",
	"$timeout",
	function($q, $timeout) {

		function getFile(asType) {
			var deferred = $q.defer()
			var ip = document.createElement("input");
			ip.setAttribute("type", "file");

			$(ip).on("change", function (ev) {
				var file = ip.files[0];
				
				var reader = new FileReader();
				reader.onload = function(e) {
					deferred.resolve({
						name: file.name,
						data: e.target.result
					})
				}
				reader.onerror = function(e) {
					deferred.reject()
				}
				reader.onabort = function(e) {
					deferred.reject()
				}

				if (asType === "text") {
					reader.readAsText(file);
				} else if (asType === "dataurl") {
					reader.readAsDataURL(file);
				} else if (asType === "arraybuffer") {
					reader.readAsArrayBuffer(file);
				} else {
					reader.readAsBinaryString(file);
				}
			})

			$timeout(function() {
				deferred.reject()
			}, 180000)

			ip.click()

			return deferred.promise

		}

		var service = {
			getFileAsText: function() {
				return getFile("text")
			},
			getFileAsDataURL: function() {
				return getFile("dataurl")
			},
			getFileAsArrayBuffer: function() {
				return getFile("arraybuffer")
			},
			getFileAsBinary: function() {
				return getFile("binary")
			},
		}
		return service
	}
])
