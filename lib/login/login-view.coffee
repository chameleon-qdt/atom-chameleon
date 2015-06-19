{$,View} = require 'atom-space-pen-views'
desc = require '../utils/text-description'
{TextEditorView} = require 'atom-space-pen-views'

module.exports =
	class LoginView extends View
		@content: ->
			@div class:'login-box container',=>
				@div class: 'col-md-12', =>
					@label class: 'col-md-3', style:'font-size:18px', "邮箱："
					@div class: 'col-md-9', =>
			      @subview 'loginEmail', new TextEditorView(mini: true,placeholderText: 'E-mail...')
				@div class: 'col-md-12', =>
					@label "密码：", class: 'col-md-3',style:'font-size:18px'
					@div class: 'col-md-9 ', =>
			      @subview 'loginPassword', new TextEditorView(mini: true,placeholderText: 'password...')
				@div class: 'col-md-12 ', =>
					@input type:'checkbox',style:'margin-right:2px;margin-left:18px;'
					@label  "记住密码" ,style:'font-size:12px;padding-bottom:2px'
				@div class: 'col-md-12 text-right', =>
					@button  "登 录",name: 'loginBtn', class:'btn' ,style:'font-size:12px;margin:5px'
					@button  "取 消", outlet:'cancelBtn', click: 'onCancelClick',name: 'loginCancelBtn', class:'btn' ,style:'font-size:12px'
				@div class: 'col-md-12 text-right', =>
					@input id:'loginPassword', type: "password", style: "display: none"
	  serialize: ->

	  initialize: ->

	  # Tear down any state and detach
	  # destroy: ->
	  #   if @modalPanel?
	  #     @modalPanel.destroy()
	  #   @element.remove()
	  #
	  getElement: ->
	    @element

		move: ->
			@element.parentElement.classList.add('down')
		destroy: ->

		onCloseClick: ->

		onCancelClick: ->
		  console.log 'onCancelClick'
