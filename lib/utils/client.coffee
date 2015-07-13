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

  getModuleLastVersion: (params,identifier) ->
    console.log identifier
    params.path = "app_update/get_lastversion/#{identifier}/d"
    params.type = 'GET'
    @request(params)

  postModuleMessage: (params) ->
    params.path = 'module/upload_module'
    params.type = 'POST'
    @request(params)
