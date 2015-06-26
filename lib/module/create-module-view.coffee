module.exports =
class CreateModuleView

  @content: ->
    @div class: 'create-module', =>
      @h2 '请填写要创建的模块信息:'
      @div class: 'form-horizontal', =>
        @div class: 'form-group', =>
          @label '模块标识', class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @subview 'moduleId', new TextEditorView(mini: true)
        @div class: 'form-group', =>
          @label '模块名称', class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @subview 'moduleName', new TextEditorView(mini: true)
        @div class: 'form-group', =>
          @label '模块起始页', class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @subview 'mainEntry', new TextEditorView(mini: true)

  attached: ->
    @parentView.setNextBtn('finish')
    @parentView.disableNext()
    @parentView.hidePrevBtn()

  destroy: ->
    @remove()

  getElement: ->
    @element

  serialize: ->


  onTypeItemClick: (e) ->
    el = e.currentTarget
    $('.item.select').removeClass 'select'
    el.classList.add 'select'
    @createType = el.dataset.type
    @parentView.enableNext()

  nextStep: (box)->
    nextStepView = new @v[@createType]()
    box.setPrevStep @
    box.mergeOptions {subview:nextStepView}
    box.nextStep()
