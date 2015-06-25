ModuleView = require './module-view'
{CompositeDisposable} = require 'atom'

module.exports = Module =
  moduleView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @moduleView = new ModuleView(state.moduleViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @moduleView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'module:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @moduleView.destroy()

  serialize: ->
    moduleViewState: @moduleView.serialize()

  toggle: ->
    console.log 'Module was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
