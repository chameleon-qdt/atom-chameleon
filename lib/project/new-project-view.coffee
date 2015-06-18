desc = require '../utils/text-description'
{$, View} = require 'atom-space-pen-views'

module.exports =
class NewProjectView extends View

  @content: ->
    @div class: 'new-project hide', =>
      @h2 '请选择要创建的项目类型:'
      @div class: 'new-item inline-block text-center', =>
        @img class: 'pic', src: 'atom://chameleon/images/icon.png'
        @h3 '空白项目',class: 'project-name'
      @div class: 'new-item inline-block text-center', =>
        @img class: 'pic', src: 'atom://chameleon/images/icon.png'
        @h3 '自带框架项目',class: 'project-name'
      @div class: 'new-item inline-block text-center', =>
        @img class: 'pic', src: 'atom://chameleon/images/icon.png'
        @h3 '业务模板',class: 'project-name'

  getElement: ->
    @element
