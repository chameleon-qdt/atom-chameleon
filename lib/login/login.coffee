LoginView = require './login-view'

module.exports = Login =
  loginView: null
  modalPanel: null

  activate: (state) ->
    @loginView = new LoginView(state.loginViewState)
    @loginView.modalPanel = @modalPanel = atom.workspace.addModalPanel(item: @loginView, visible: false)

  deactivate: ->
    @modalPanel.destroy()
    @loginView.destroy()

  serialize: ->
    loginViewState: @loginView.serialize()

  toggle: ->
    console.log 'Login was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
      # @loginView.destroy()
    else
      @modalPanel.show()
