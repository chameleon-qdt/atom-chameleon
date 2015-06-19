CreateProject = require './project/create-project'
Login = require './login/login'
ConfigureModule = require './configure/module/module'

{CompositeDisposable} = require 'atom'

module.exports = Chameleon =
  createProject: null
  login: null
  configureModule: null
  subscriptions: null

  activate: (state) ->
    # console.log CreateProject,Login
    @createProject = CreateProject
    @createProject.activate(state)
    @login = Login
    @login.activate(state)
    @configureModule = ConfigureModule
    @configureModule.activate(state)
    # @login = Login
    # @login.activate(state)
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:create-project': => @createProject.openView()
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:login': => @login.openView()
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:configure:module': => @configureModule.openView()
  deactivate: ->
    @subscriptions.dispose()
    @createProject.destroy()
    @login.destroy()

  serialize: ->
    @createProject.serialize()
    @login.serialize()
  toggle: ->
    console.log 'Chameleon was toggled!'
    # @login.toggle()

  # createProject: ->
  #   console.log 'create-project'
  #   unless @createProjectView.modalPanel.isVisible()
  #     @createProjectView.modalPanel.show()
