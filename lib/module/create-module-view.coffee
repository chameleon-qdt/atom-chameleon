module.exports =
class CreateModuleView

  @content: ->
    @div class: 'create-module', =>
      @h2 '请填写要创建的项目信息:'
      @div class: 'form-horizontal', =>
        @div class: 'form-group', =>
          @label '请输入应用标识', class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @subview 'appId', new TextEditorView(mini: true)
        @div class: 'form-group', =>
          @label '请输入应用名称', class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @subview 'appName', new TextEditorView(mini: true)

  attached: ->
    @parentView.disableNext()
    @parentView.hidePrevBtn()

  destroy: ->
    @element.remove()

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
