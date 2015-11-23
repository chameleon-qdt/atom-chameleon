{$} = require 'atom-space-pen-views'
config = require '../../config/config'
request = require 'request'
util = require './util'
j = request.jar()
Settings = require '../settings/settings'

module.exports =
  settings: Settings
  send: (params) ->
    console.log(config.serverUrl)
    defaultsParams =
      baseUrl: config.serverUrl
      method: 'GET'
    if params.sendCookie and util.store('chameleon-cookie').length > 0
      cookie = request.cookie(util.store('chameleon-cookie'))
      j.setCookie(cookie, config.serverUrl)
      params.jar = j
    params = $.extend defaultsParams, params
    cb = (err, httpResponse, body) =>
      # console.log httpResponse
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
          isLogout = httpResponse.request.path.indexOf 'logout'
          if isLogout < 0
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

  logout: (params) ->
    params.url = 'usermanger/logout'
    params.method = 'POST'
    @send params

  getUserProjects: (params) ->
    params.url = 'app/list'
    @send params

  # getProjectDetail: (params) ->
  #   params.url = 'app/app_info'
  #   @send params

  getProjectDetail: (params) ->
    params.url = 'app/app_platform_info'
    @send params

  getProjectPlatformDetail: (params) ->
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

  #上传模块接口 2015-10-22
  uploadModuleZip:(params) ->
    params.url = "module/upload_module_by_file"
    params.method = "POST"
    @send params
  #分页获取 与相应模块关联的 app 列表
  getAppMessage:(params,moduleIdentifer,pageIndex,showNumber,platform)->
    params.url = "app_update/get_app_msg/#{moduleIdentifer}/#{platform}/#{pageIndex}/#{showNumber}"  # /#{platform}
    console.log params.url
    @send params
  applyModuleToApp:(params,appVersionId,moduleId)->
    params.url = "module_detail/applu_new_module/#{appVersionId}/#{moduleId}"
    @send params

  getAppId:(params,projectIdentifer)->
    params.url = "#{projectIdentifer}"
    @send params

  getEngineList:(params,auth_type,platform,page,pagesize) ->
    params.url = "engine/list?auth_type=#{auth_type}&platform=#{platform}&page=#{page}&pagesize=#{pagesize}"
    @send params

  getEngineVersionList:(params,engine_id,page,pagesize) ->
    params.url = "engine_version/list?engine_id=#{engine_id}&page=#{page}&pagesize=#{pagesize}"
    @send params

  getDefaultEngineMessage:(params,platform) ->
    params.url = "app/get_default_engine?id=appId&platform=#{platform}"
    @send params

  getAppIdByAppIndentifer:(params,identifier) ->
    params.url = "app/app_info_single?identifier=#{identifier}"
    @send params

  getModuleList:(params,platform,type,exceptModuleIds,page,pagesize) ->
    params.url = "app_version/module_tree?platform=#{platform}&module_type=#{type}&id_list=#{exceptModuleIds}&page=#{page}&pagesize=#{pagesize}"
    @send params

  getLastBuildProjectMessage:(params,projectId,platform) ->
    params.url = "app_version/newest_info/?appId=#{projectId}&platform=#{platform}"
    @send params

  # getPluginList:(params,platform,type,exceptModuleIds,page,pagesize) ->
  #   params.url = "app_version/plugin_tree?platform=#{platform}&plugin_type=#{type}&id_list=#{exceptModuleIds}&page=#{page}&pagesize=#{pagesize}"
  #   @send params
  getPluginByModuleIds:(params,dataStr) ->
    params.url = "app_version/get_plugin_list?#{dataStr}"
    console.log params.url
    @send params

  uploadFileSync:(params,up_classify,need_file_type) ->
    userId = util.store('chameleon').account_id
    params.url = "file/sync_upload/#{up_classify}/#{userId}?need_file_type=#{need_file_type}"
    params.method = "POST"
    @send params

  requestBuildApp:(params) ->
    params.url = "app/qdt/build"
    params.method = "POST"
    @send params
  check_cert_android:(params) ->
    params.url = "app/check_cert_android"
    params.method = "POST"
    @send params

  check_cert_iOS:(params) ->
    params.url = "app/check_cert_ios"
    params.method = "POST"
    @send params
