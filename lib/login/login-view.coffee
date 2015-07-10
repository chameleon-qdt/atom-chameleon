{$,View} = require 'atom-space-pen-views'
desc = require '../utils/text-description'
{TextEditorView} = require 'atom-space-pen-views'

module.exports =
	class LoginView extends View
		@content: ->
			@div class:'login-box container',=>
				@div class: 'col-sm-12 col-md-12', =>
					@label class: 'col-sm-3 col-md-3 label_view', "邮箱："
					@div class: 'col-sm-9 col-md-9', =>
			      @subview 'loginEmail', new TextEditorView(mini: true,placeholderText: 'E-mail...')
				@div class: 'col-sm-12 col-md-12', =>
					@label "密码：", class: 'col-sm-3 col-md-3 label_view'
					@div class: 'col-sm-9 col-md-9 ', =>
			      @subview 'loginPassword', new TextEditorView(mini: true,placeholderText: 'password...')
			      @input type: 'hidden', id: 'loginPassword'
				@div class: 'col-sm-12 col-md-12 ', =>
					@input type:'checkbox',style:'margin-right:2px;margin-left:18px;'
					@label  "记住密码" ,class:'checkBox_label_view'
				@div class: 'col-md-12 text-right', =>
					@button  "登 录",name: 'loginBtn', class:'btn loginBtn'
					@button  "取 消", outlet:'cancelBtn', click: 'onCancelClick',name: 'loginCancelBtn', class:'btn cancelBtn'
	      

	  getElement: ->
	    @element

		move: ->
			@element.parentElement.classList.add('down')
		destroy: ->

		onCloseClick: ->

		onCancelClick: ->
		  console.log 'onCancelClick'
