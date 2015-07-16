{$} = require 'atom-space-pen-views'
config = require '../../config/config'
request = require 'request'
util = require './util'
j = request.jar()

module.exports =

  send: (params) ->
    defaultsParams =
      baseUrl: config.serverUrl
      method: 'GET'

    if params.sendCookie and util.store('chameleon-cookie').length > 0

      cookie = request.cookie(util.store('chameleon-cookie'))
      j.setCookie(cookie, config.serverUrl)
      params.jar = j
    params = $.extend defaultsParams, params
    request params, params.cb

  login: (params) ->
    params.url = 'anonymous/login'
    params.method = 'POST'
    @send params

  getUserProjects: (params) ->
    params.url = 'app/list'
    @send params

  getModuleLastVersion: (params,identifier) ->
    userId = util.store('chameleon').account_id
    console.log userId,identifier
    params.url = "app_update/get_lastversion/#{identifier}/#{userId}"
    @send params

  postModuleMessage: (params) ->
    params.url = 'module/upload_module'
    params.method = 'POST'
    @send params

  uploadFile: (params,type,user) ->
    userId = util.store('chameleon').account_id
    params.url = "file/upload/#{type}/#{userId}"
    params.method = 'POST'
    @send params
