{$} = require 'atom-space-pen-views'
config = require '../../config/config'

module.exports = 
	request: (parmas) ->
		defaultsParams = 
			url: config.serverUrl + parmas.path
			type: 'GET'

		parmas = $.extend(defaultsParams, parmas)
		
		$.ajax(parmas)