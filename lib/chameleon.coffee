CreateProject = require './project/create-project'
CreateModule = require './module/module'
Login = require './login/login'
ConfigureModule = require './configure/module/module'
ConfigureApp = require './configure/application/app'
ConfigureGlobal = require './configure/global/global'
Settings = require './settings/settings'
{CompositeDisposable} = require 'atom'

module.exports = Chameleon =
  createProject: null
  login: null
  configureModule: null
  configureApp: null
  subscriptions: null
  configureGlobal: null
  createModule:null
  settings: null

  activate: (state) ->
    @createProject = CreateProject
    @login = Login
    @configureModule = ConfigureModule
    @configureApp = ConfigureApp
    @configureGlobal = ConfigureGlobal
    @createModule = CreateModule
    @settings = Settings

    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:settings': => @openSettings()
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:create-project': => @toggleCreateProject(state)
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:create-module' : => @toggleCreateModule(state)
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:login': => @loginViewOpen(state)
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:configure:module': => @configureModuleViewOpen(state)
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:configure:application': => @configureAppViewOpen(state)
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:configure:global' : => @configureGlobalViewOpen(state)
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:openSource' : => @openSourceFolder()

  deactivate: ->
    @subscriptions.dispose()
    @createProject.destroy()
    @login.destroy()

  openSettings: ->
    @settings.activate()

  serialize: ->
    @createProject.serialize()
    @login.serialize()
    @settings.serialize()

  toggleCreateProject:(state) ->
    @createProject.activate(state)
    @createProject.openView()

  toggleCreateModule:(state) ->
    @createModule.activate(state)
    @createModule.openView()

  loginViewOpen:(state) ->
    @login.activate(state)
    @login.openView()

  configureModuleViewOpen:(state) ->
    @configureModule.activate(state)
    @configureModule.openView()

  configureAppViewOpen:(state) ->
    @configureApp.activate(state)
    @configureApp.openView()

  configureGlobalViewOpen:(state) ->
    @configureGlobal.activate(state)
    @configureGlobal.openView()

  openSourceFolder: ->
    path = atom.packages.getLoadedPackage('chameleon').path
    atom.project.setPaths([path])

  # createProject: ->
  #   console.log 'create-project'
  #   unless @createProjectView.modalPanel.isVisible()
  #     @createProjectView.modalPanel.show()
# @eventElement.dispatchEvent(new CustomEvent(name, bubbles: true, cancelable: true))
# atom.views.getView(atom.workspace).dispatchEvent(new CustomEvent('chameleon:create-module', {bubbles: true, cancelable: true}))
