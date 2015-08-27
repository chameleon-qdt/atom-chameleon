{$,View} = require 'atom-space-pen-views'
desc = require '../utils/text-description'
{TextEditorView} = require 'atom-space-pen-views'
config = require '../../config/config'

module.exports =
  class LoginView extends View
    @content: ->
      @div class:'login-box', =>
        @div class: 'head', =>
          @h2 '登陆'
          @span class: 'icon icon-remove-close close-view pull-right', click: 'onCancelClick'
        @div class: 'content', =>
          @img src: desc.getImgPath 'logo_login.png'
          @div class: 'login-row', =>
            @label class: 'label_view', '邮箱:'
            @div class: 'input-container', =>
              @subview 'loginEmail', new TextEditorView(mini: true, placeholderText: 'E-mail...')
          @div class: 'login-row', =>
            @label class: 'label_view', '密码:'
            @div class: 'input-container', id: 'psw', =>
              @subview 'loginPassword', new TextEditorView(mini: true, placeholderText: 'Password...')
          @div class: 'login-row', =>
            @a class: 'forgetpsw', href: 'http://bsl.foreveross.com/qdt-web/html/account/forget_pwd.html', '忘记密码?'
          @div class: 'login-row', =>
            @button id: 'login', class: 'btn login-btn', '登陆'
            @a '注册', class: 'btn login-btn', href: config.registerUrl


    getElement: ->
      @element

    move: ->
      @element.parentElement.classList.add('down')
    destroy: ->

    onCloseClick: ->

    onCancelClick: ->
      console.log 'onCancelClick'
