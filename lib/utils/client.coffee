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

    if params.sendCookie
      cookie = request.cookie("session=#{util.store('chameleon').session_id}")
      j.setCookie(cookie, config.serverUrl)
      params.jar = j
    params = $.extend defaultsParams, params
    request params, params.cb

  login: (params) ->
    params.url = 'anonymous/login'
    params.method = 'POST'
    @send params

  getUserProjects: (params) ->
    console.log util.store('chameleon').session_id
    params.url = 'app/list'
    @send params

  getModuleLastVersion: (params,identifier) ->
    console.log identifier
    params.url = "app_update/get_lastversion/#{identifier}/d"
    @send params

  postModuleMessage: (params) ->
    params.url = 'module/upload_module'
    params.method = 'POST'
    @send params

  uploadFile: (params,type,user) ->
    params.url = "file/upload/#{type}/#{user}"
    params.method = 'POST'
    @send params
