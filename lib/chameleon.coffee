CreateProject = require './project/create-project'
CreateModule = require './module/module'
PublishModule = require './module/publish-module'
Login = require './login/login'
ConfigureModule = require './configure/module/module'
ConfigureApp = require './configure/application/app'
BuildProject = require './project/build-project'
UploadProject = require './project/upload-project'
# ConfigureGlobal = require './configure/global/global'
Settings = require './settings/settings'
RapidDev = require './rapid-dev/rapid-dev-mode'
Builder = require './QDT-Builder/builder'
OSCLogin = require './login/login-osc'
util = require './utils/util'
{CompositeDisposable} = require 'atom'

module.exports = Chameleon =
  createProject: null
  BuildProject: null
  uploadProject: null
  login: null
  configureModule: null
  configureApp: null
  subscriptions: null
  # configureGlobal: null
  createModule:null
  settings: null
  publishModule: null
  OSCLogin: null
  rapidDev: null

  activate: (state) ->
    @createProject = CreateProject
    @buildProject = BuildProject
    @uploadProject = UploadProject
    @login = Login
    @configureModule = ConfigureModule
    @configureApp = ConfigureApp
    # @configureGlobal = ConfigureGlobal
    @createModule = CreateModule
    @settings = Settings
    @Builder = Builder
    @OSCLogin = OSCLogin
    @publishModule = PublishModule
    @rapidDev = RapidDev

    @subscriptions = new CompositeDisposable

    util.windowEventInit()

    atom.workspace.getPanes()[0].onWillDestroyItem (e)=>
      if e.item.uri is 'atom://ChameleonBuilder'
        console.log 'close'
        util.stopServer()

    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:rapid-dev': => @openRapidDevMode()
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:settings': => @openSettings()
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:create-project': => @toggleCreateProject(state)
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:create-module' : => @toggleCreateModule(state)
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:bulid-project' : => @toggleBuildProject(state)
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:upload-project' : => @toggleUploadProject(state)
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:publish-module' : => @togglePublishModule(state,"no_select_path")
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:publish-module-select-path' : => @togglePublishModule(state,"select_path")
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:login': => @loginViewOpen(state)
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:configure-module': => @configureModuleViewOpen(state)
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:configure-application': => @configureAppViewOpen(state)
    # @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:configure-global' : => @configureGlobalViewOpen(state)
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:openSource' : => @openSourceFolder()
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:builder': => @openBuilder()
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:openOschinaLogin': => @openOschinaLogin()

  deactivate: ->
    @subscriptions.dispose()
    @createProject.destroy()
    @login.destroy()

  openOschinaLogin: ->
    @OSCLogin.activate()

  openBuilder: ->
    @Builder.activate('hi')

  openSettings: ->
    @settings.activate()

  serialize: ->
    @createProject.serialize()
    @login.serialize()
    @settings.serialize()
    @Builder.serialize()

  openRapidDevMode: ->
    @rapidDev.activate()

  toggleCreateProject:(state) ->
    @createProject.activate(state)
    @createProject.openView()

  toggleBuildProject: (state) ->
    # console.log BuildProject
    if util.isLogin()
      @buildProject.activate(state)
      @buildProject.openView()

  toggleUploadProject: (state) ->
    if util.isLogin()
      @uploadProject.activate(state)
      @uploadProject.openView()

  toggleCreateModule:(state) ->
    @createModule.activate(state)
    @createModule.openView()

  togglePublishModule:(state,flag) ->
    # console.log flag
    if util.isLogin()
      @publishModule.activate(state,flag)
      @publishModule.openView()

  # togglePublishModuleSelectPath:(state) ->
  #   if util.isLogin()
  #     @publishModule.activate(state)
  #     @publishModule.openView()

  loginViewOpen:(state) ->
    @login.activate(state)
    @login.openView()

  configureModuleViewOpen:(state) ->
    @configureModule.activate(state)
    @configureModule.openView()

  configureAppViewOpen:(state) ->
    @configureApp.activate(state)
    @configureApp.openView()

  # configureGlobalViewOpen:(state) ->
  #   @configureGlobal.activate(state)
  #   @configureGlobal.openView()

  openSourceFolder: ->
    path = atom.packages.getLoadedPackage('chameleon-qdt-atom').path
    console.log path
    atom.project.setPaths([path])

  # createProject: ->
  #   console.log 'create-project'
  #   unless @createProjectView.modalPanel.isVisible()
  #     @createProjectView.modalPanel.show()
  # $('.tree-view-resizer') 'tree-view:toggle'
# @eventElement.dispatchEvent(new CustomEvent(name, bubbles: true, cancelable: true))
# atom.views.getView(atom.workspace).dispatchEvent(new CustomEvent('chameleon:create-module', {bubbles: true, cancelable: true}))
