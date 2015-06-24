{$,View,TextEditorView} = require 'atom-space-pen-views'
desc = require '../../utils/text-description'

module.exports =
	class GlobalView extends View
		@content: ->
			@div class:'login-box container',=>
				@div class: 'col-md-12', =>
					@label class: 'col-md-3 label_view', "邮箱："
					@div class: 'col-md-9', =>
			      @subview 'loginEmail', new TextEditorView(mini: true,placeholderText: 'E-mail...')
				@div class: 'col-md-12', =>
					@label "密码：", class: 'col-md-3 label_view'
					@div class: 'col-md-9 ', =>
			      @subview 'loginPassword', new TextEditorView(mini: true,placeholderText: 'password...')
				@div class: 'col-md-12 ', =>
					@input type:'checkbox',style:'margin-right:2px;margin-left:18px;'
					@label  "记住密码" ,class:'checkBox_label_view'
				@div class: 'col-md-12 text-right', =>
					@button  "登 录",name: 'loginBtn', class:'btn loginBtn'
					@button  "取 消", outlet:'cancelBtn', click: 'onCancelClick',name: 'loginCancelBtn', class:'btn cancelBtn'
				@div class: 'col-md-12 text-right', =>
					@a '注册', src:desc.registerUrl
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
