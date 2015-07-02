AccountPanel = require './panels-account-view'
CodePanel = require './panels-code-view'
{$, ScrollView} = require 'atom-space-pen-views'

module.exports =
class ChameleonSettingsView extends ScrollView
  @content: ->
    @div class: 'chameleonsettingsview pane-item', tabindex: -1, =>
      @div class: 'settings-menu', =>
        @ul =>
          @li class: 'settingsItem active', panelType: 'account', =>
            @a class: 'icon icon-organization', '开发者账号'
          @li class: 'settingsItem', panelType: 'code', =>
            @a class: 'icon icon-file-code', '框架、模版'
      @div class: 'settingsPanel',outlet: "settingsPanel"

  getURI: -> @uri

  getTitle: -> '设置'

  initialize: ({@uri}) ->
    # super
    @accountPanel = new AccountPanel()
    @settingsPanel.html @accountPanel
    @accountPanel = null
    @on 'click', '.settingsItem', (e) =>
      @menuClick(e.currentTarget)
    
  menuClick: (target) =>
    $target = $(target)
    $settingsMenu = $('.settings-menu')
    $settingsMenu.find('.active').removeClass('active')
    $target.addClass('active')
    type = $target.attr('panelType')
    switch type
      when "account"
        @accountPanel = new AccountPanel()
        @settingsPanel.html @accountPanel
        @accountPanel = null
      when "code"
        @codePanel = new CodePanel()
        @settingsPanel.html @codePanel
        @codePanel = null
      else
        @settingsPanel.html @accountPanel