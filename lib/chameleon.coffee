CreateProject = require './project/create-project'
Login = require './login/login'
{CompositeDisposable} = require 'atom'

module.exports = Chameleon =
  createProject: null
  login: null
  subscriptions: null

  activate: (state) ->
    # console.log CreateProject,Login
    @createProject = CreateProject
    @createProject.activate(state)
    @login = Login
    @login.activate(state)
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:create-project': => @createProject.openView()

  deactivate: ->
    @subscriptions.dispose()
    @createProject.destroy()

  serialize: ->
    @createProject.serialize()

  toggle: ->
    console.log 'Chameleon was toggled!'
    @login.toggle()

  # createProject: ->
  #   console.log 'create-project'
  #   unless @createProjectView.modalPanel.isVisible()
  #     @createProjectView.modalPanel.show()
