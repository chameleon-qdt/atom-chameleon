{$} = require 'atom-space-pen-views'
config = require '../../config/config'

module.exports = 
  request: (params) ->
    defaultsParams = 
      url: config.serverUrl + params.path
      type: 'GET'

    params = $.extend(defaultsParams, params)
    console.log params
    $.ajax(params)

  login: (params) ->
    params.path = 'usermanger/login'
    params.contentType = 'x-www-form-urlencoded'
    params.type = 'POST'
    @request(params)

  contentGit: (params) ->
    @request params