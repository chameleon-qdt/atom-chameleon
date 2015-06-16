desc = require '../utils/text-description'
{$, TextEditorView, View} = require 'atom-space-pen-views'

module.exports =
class LoginView extends View

  modalPanel : null

  @content: ->
    @div class: 'chameleon login-box', =>
      @div class: 'block clearfix', =>
        @h2 desc.email, class: 'desc pull-left'
        @div class: 'info', =>
          @subview 'email', new TextEditorView(mini: true)
      @div class: 'block clearfix', =>
        @h2 desc.pwd, class: 'desc pull-left'
        @div class: 'info', =>
          @subview 'pwd', new TextEditorView(mini: true)
      @div class: 'action-bar block clearfix', =>
        @div class: 'pull-right', =>
          @button desc.cancel, class: 'btn cancel inline-block-tight', outlet: 'cancelBtn', click: 'onCancelClick'
          @button desc.login, class: 'btn login inline-block-tight', outlet: 'loginBtn'

  initialize: (params) ->
    # @cancelBtn = params.title

  attached: ->
    # console.log @
    # console.log "With CSS applied, my height is", @height()

  detached: ->
    console.log "I have been detached."

  destroy: ->
    @detach()

  hide: ->
    # super()
    if @modalPanel?
      if @modalPanel.isVisible()
        @modalPanel.hide()
    else
      @element.classList.add('hide')

  onCancelClick: ->
    @hide()
