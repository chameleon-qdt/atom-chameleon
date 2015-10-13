{$, View} = require 'atom-space-pen-views'
LoginView = require '../login/login'

config = require '../../config/config'
util = require '../utils/util'
client = require '../utils/client'

module.exports =

class AccountPanel extends View
  @content: ->
    @div =>
      @div class: 'accountMessage' ,outlet: 'accountMessage'

  initialize: () =>
    account = util.store('chameleon').uname
    shownSection = if account? then new hadAccount(account) else new notFoundAccount()
    @accountMessage.html shownSection
    shownSection = null
    console.log @initialize

class notFoundAccount extends View
  @content: ->
    @div =>
      @div class: 'accountMsg', =>
        @h3 '没有账号信息，请先登录或者注册。'
      @button '登录', class: 'btn', click: 'login'
      @button '使用osc账号登录', class: 'btn', click: 'loginWithOSC'
      @a '注册', class: 'btn', href: config.registerUrl

  login: ->
    @LoginView = LoginView
    @LoginView.activate()
    @LoginView.openView()

  loginWithOSC: ->
    iframe = $("<iframe src='#{config.oscLoginUrl}'></iframe>")
    iframe.css({
      'width': 1000,
      'height': 500,
      'background': '#fff'
      })
    @.append(iframe)
    window.addEventListener 'message', (e)=>
      buf = JSON.parse(new Buffer(e.data, 'base64').toString("ascii"))
      console.log buf
      if typeof buf isnt 'undefined'
        switch buf.flag
          when '0'
            alert "登录失败：邮箱或密码不正确"
          when '1' or '3'
            util.store('chameleon', buf)
            util.store('chameleon-cookie', "auth=#{e.data}")
            $('.accountMessage').html(new hadAccount(buf.uname))
          when '2'
            alert "登录失败：用户未激活"
          when '4'
            alert "登录失败：用户被禁用"
          when '5'
            alert "邮箱或密码不正确"



class hadAccount extends View
  @content: (account) ->
    @div =>
      @div class: 'accountMsg', =>
        @h3 "你好, #{account}"
      @button '退出', class: 'btn', click: 'logout'

  logout: ->
    console.log util.store('chameleon').session_id
    params =
      form:
        session_id: util.store('chameleon').session_id
      sendCookie: true
      success: (data) ->
        console.log data
        util.removeStore('chameleon')
        util.removeStore('chameleon-cookie')
        $('.accountMessage').html(new notFoundAccount)
      error: (err) ->
        console.log err
    client.logout(params)
