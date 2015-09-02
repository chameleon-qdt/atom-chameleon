{$} = require 'atom-space-pen-views'
config = require '../../config/config'
request = require 'request'
util = require './util'
j = request.jar()
Settings = require '../settings/settings'

module.exports =
  settings: Settings
  send: (params) ->
    defaultsParams =
      baseUrl: config.serverUrl
      method: 'GET'
    if params.sendCookie and util.store('chameleon-cookie').length > 0
      cookie = request.cookie(util.store('chameleon-cookie'))
      j.setCookie(cookie, config.serverUrl)
      params.jar = j
    params = $.extend defaultsParams, params
    cb = (err, httpResponse, body) =>
      console.log httpResponse
      # console.log err
      # console.log body
      if httpResponse.complete
        if typeof params.complete is 'function'
          params.complete()

        if !err && httpResponse.statusCode is 200
          headerCookie = if typeof httpResponse.headers['set-cookie'] is 'undefined' then '' else httpResponse.headers['set-cookie'][0]
          params.success(JSON.parse(body), headerCookie)
        else if httpResponse.statusCode is 403
          util.removeStore('chameleon-cookie')
          util.removeStore('chameleon')
          if httpResponse.request.path isnt '/qdt-web/api/v1/usermanger/logout'
            alert '登录超时，请重新登录'
            util.findCurrModalPanel()?.item.closeView?()
            util.rumAtomCommand('chameleon:login')

          atom.workspace.getPanes()[0].destroyActiveItem()
          @settings.activate()

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

  getModuleLastVersion: (params) ->
    userId = util.store('chameleon').account_id
    # console.log userId,identifier
    params.url = "app_update/get_lastversion/"
    params.method = 'POST'
    # console.log params
    # params.url = "app_update/get_lastversion/#{identifier}"
    @send params

  postModuleMessage: (params) ->
    params.url = 'module/upload_module'
    console.log params
    params.method = 'POST'
    @send params

  uploadFile: (params,type,user) ->
    userId = util.store('chameleon').account_id
    params.url = "file/upload/#{type}/#{userId}"
    params.method = 'POST'
    @send params

  getAppPlugins: ( params, identifier, platform) ->
    userMail = util.store('chameleon').mail
    params.url = "app/app_plugins/?account=#{userMail}&identifier=#{identifier}&platform=#{platform}"
    # console.log params.url
    @send params

  getAppAllPlugins:(params,identifier) ->
    params.url = "app/app_all_plugins?identifier=#{identifier}"
    @send params

  buildApp: (params) ->
    # userMail = util.store('chameleon').mail
    # params.form.account = userMail
    params.url = "app/build"
    params.method = 'POST'
    @send params

  uploadApp: (params) ->
    params.url = "app/create"
    params.method = "POST"
    @send params

  getBuildUrl: (params,buildId) ->
    params.url = "build/get_build_info?build_id="+ buildId
    @send params

  getAppListByModule: (params,moduleIdentifer) ->
    console.log params
    params.url = "app_update/get_app_msg/"+moduleIdentifer
    @send params

  uploadModuleAndAct:(params) ->
    params.url = "module/upload_use_module"
    params.method = "POST"
    @send params
