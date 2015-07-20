
{$,TextEditorView,View} = require 'atom-space-pen-views'
desc = require './../utils/text-description'
module.exports =
	class SelectTemplate extends View
		@content: ->
			@div class: 'new-project', =>
				@h2 '创建业务模板:'
				@div class: 'col-sm-12 col-md-12', outlet:'template', =>
					@div class: 'new-template text-center', 'data-type': 'empty',  =>
						@img class: 'pic', src:'atom://chameleon-qdt-atom/images/1.jpeg'
						@h3 '电商',class: 'project-name'
					@div class: 'new-template text-center', 'data-type': 'empty',  =>
						@img class: 'pic', src:'atom://chameleon-qdt-atom/images/2.jpg'
						@h3 '新闻',class: 'project-name'
				@div class: 'col-sm-1 col-md-1 text-center', =>
					@button outlet: "preImage", =>
						@span "《"
				@div class: 'col-sm-10 col-md-10', outlet:'showTemplate'
					# @div class : 'template-item text-center', 'data-type' : 'empty', =>
					# 	@img class: 'pic', src:'atom://chameleon-qdt-atom/images/3.jpeg'
				@div style:class: 'col-sm-1 col-md-1 text-center ', =>
					@button outlet: "nextImage", =>
						@span "》"

    attached: ->
			# 调获取样板的接口  获取 样板列表
			images = [
				'atom://chameleon-qdt-atom/images/3.jpeg',
				'atom://chameleon-qdt-atom/images/8.jpeg',
				'atom://chameleon-qdt-atom/images/5.jpg',
				'atom://chameleon-qdt-atom/images/3.jpeg',
				'atom://chameleon-qdt-atom/images/8.jpeg',
				'atom://chameleon-qdt-atom/images/5.jpg'
			]
			showImageCount = 0
			console.log @showTemplate
			showImage = (imageSrc) ->
				if imageSrc isnt null
					showImageCount = showImageCount + 1
					options =
						src: imageSrc
					if showImageCount > 3
						options['class'] = "hide"
					else
						options['class'] = ""
					item = new Item(options)
					# @show_template.append(item)
			showImage image for image in images

class Item extends View
	@content:(options) ->
		@div class : 'template-item text-center '+ options['class'], 'data-type' : 'empty', =>
			@img class: 'pic', src:options['src']
