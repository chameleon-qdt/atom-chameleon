{$, ScrollView} = require 'atom-space-pen-views'

desc = require '../utils/text-description'
Settings = require '../settings/settings'
Config = require '../../config/config'
Util = require '../utils/util'

module.exports =
class ChameleonBuilderView extends ScrollView
  @content: ->
    @iframe class: 'builder-iframe', src: Config.oscLoginUrl
    # @iframe class: 'builder-iframe', src: 'http://bsl.foreveross.com/qdt-web-dev/html/account/login.html?osc_flag=false'
      
  getURI: -> @uri

  getTitle: -> desc.oscLoginPanelTitle

  initialize: ({@uri}) ->
    @settings = Settings
    getMessageCB = (e) =>
      if e.data isnt 'false'
        buf = JSON.parse(new Buffer(e.data, 'base64').toString("ascii"))
        if typeof buf isnt 'undefined'
          switch buf.flag
            when '0'
              alert "登录失败：邮箱或密码不正确"
            when '1' or '3'
              Util.store('chameleon', buf)
              Util.store('chameleon-cookie', "auth=#{e.data}")
              Util.getPanes().destroyItem(Util.getThatPane("atom://ChameleonSettings"))
              Util.getPanes().destroyItem(Util.getThatPane("atom://ChameleonLoginOSC"))
              @settings.activate()
            when '2'
              alert "登录失败：用户未激活"
            when '4'
              alert "登录失败：用户被禁用"
            when '5'
              alert "邮箱或密码不正确"
      else
        Util.getPanes().destroyItem(Util.getThatPane("atom://ChameleonLoginOSC"))
      window.removeEventListener 'message', getMessageCB, false
    window.addEventListener 'message', getMessageCB, false

    
    # super
    # @accountPanel = new AccountPanel()
    # @settingsPanel.html @accountPanel
    # @accountPanel = null
    # @on 'click', '.settingsItem', (e) =>
    #   @menuClick(e.currentTarget)

  attached: ->
