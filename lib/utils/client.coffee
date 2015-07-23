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
    # console.log defaultsParams.baseUrl+params.url
    if params.sendCookie and util.store('chameleon-cookie').length > 0
      cookie = request.cookie(util.store('chameleon-cookie'))
      j.setCookie(cookie, config.serverUrl)
      params.jar = j
    params = $.extend defaultsParams, params
    cb = (err, httpResponse, body) =>
      console.log httpResponse
      if !err && httpResponse.statusCode is 200

        headerCookie = if typeof httpResponse.headers['set-cookie'] is 'undefined' then '' else httpResponse.headers['set-cookie'][0]
        params.success(JSON.parse(body), headerCookie)

      else if httpResponse.statusCode is 403
        util.removeStore('chameleon-cookie')
        util.removeStore('chameleon')
        alert '没有登录或登录超时，请重新登录'
        params.error(err)
      else
        params.error(err)
    request params, cb

  login: (params) ->
    params.url = 'anonymous/login'
    params.method = 'POST'
    @send params

  loggout: (params) ->
    params.url = 'usermanger/logout'
    params.method = 'POST'
    @send params

  getUserProjects: (params) ->
    params.url = 'app/list'
    @send params

  getProjectDetail: (params) ->
    params.url = 'app/app_info'
    @send params

  getModuleLastVersion: (params,identifier) ->
    userId = util.store('chameleon').account_id
    console.log userId,identifier
    params.url = "app_update/get_lastversion/#{identifier}"
    # params.url = "app_update/get_lastversion/#{identifier}"
    @send params

  postModuleMessage: (params) ->
    params.url = 'module/upload_module'
    params.form.create_by = util.store('chameleon').account_id
    console.log params.form
    params.method = 'POST'
    @send params

  uploadFile: (params,type,user) ->
    userId = util.store('chameleon').account_id
    params.url = "file/upload/#{type}/#{userId}"
    params.method = 'POST'
    @send params

  getAppPlugins: ( params, identifier, platform) ->
    userId = util.store('chameleon').mail
    params.url = "app/app_plugins/?account=#{userId}&identifier=#{identifier}&platform=#{platform}"
    console.log params.url
    @send params
