{Directory,File} = require 'atom'
desc = require './../../utils/text-description'
{$, View} = require 'atom-space-pen-views'
{TextEditorView} = require 'atom-space-pen-views'
pathM = require 'path'
fs = require 'fs-extra'
ChameleonBox = require '../../utils/chameleon-box-view'
util = require '../../utils/util'
_ = require 'underscore-plus'

class ModuleInfoView extends View

  # version: null
  moduleConfigFileName: desc.moduleConfigFileName
  projectConfigFileName: desc.projectConfigFileName
  moduleLogoFileName: desc.moduleLogoFileName
  moduleLocatFileName: desc.moduleLocatFileName

  @content: ->
    @div class: 'configure-module container', =>
      @div class: 'row',outlet: 'main', =>
        @div class:'', =>
          @label '选择要配置的模块'
        @div outlet : 'moduleList'
      @div class: 'row hide',outlet: "second", =>
        @div class: "hole-line", =>
          @label class: 'label-extend label-right', "logo"
          @div class: 'input-line-1', =>
            @img outlet:"logo",class:'pic', src: desc.getImgPath 'icon.png'
        @div class: "hole-line ", =>
          @label class: 'label-extend label-right', "模块名称"
          @div class: 'input-line-2', =>
            @subview 'moduleName', new TextEditorView(mini: true,placeholderText: 'moduleName...')
        @div class: " hole-line", =>
          @label class: 'label-extend label-right', "模块版本"
          @div class: 'input-line-2', =>
            @subview 'moduleVersion', new TextEditorView(mini: true,placeholderText: 'moduleVersion...')
      @div class: 'layout hide',outlet:"layout"
        # @div class: "col-sm-12 ", =>
        #   @label class: 'col-sm-3 ', "模块描述"
        #   @div class: 'col-sm-9 ', =>
        #     @subview 'moduleDescription', new TextEditorView(mini: true,placeholderText: 'moduleDescription...')
        # @div class: "col-xs-12 ", =>
        #   @label class: 'col-sm-3 col-md-3', "模块入口"
        #   @div class: 'col-sm-9 col-md-9', =>
        #     @subview 'moduleInput', new TextEditorView(mini: true,placeholderText: 'moduleInput...')


  serialize: ->

  selectIcon:(e) ->
    real_path = $('.modulecheckbox:checked').attr('value')
    img_path = pathM.join real_path,"..",@moduleLogoFileName
    options={}
    # console.log "bb"
    @layout.removeClass('hide')
    cb = (selectPath) =>
      # console.log selectPath[0]
      # console.log selectPath[0].lastIndexOf('.')
      if selectPath? and selectPath.length != 0
        tmp = selectPath[0].substring(selectPath[0].lastIndexOf('.'))
        console.log tmp
        if tmp is ".jpeg" or tmp is ".png"
          fs.writeFileSync(img_path,fs.readFileSync(selectPath[0]))
          @logo.attr("src",img_path)
          @layout.addClass('hide')
        else
          alert "请选择扩展名为 .jpeg 或者 .png"
          @layout.addClass('hide')
          return
      else
        @layout.addClass('hide')
    util.openFile options,cb


  attached: ->
    @logo.on 'click', (e) => @selectIcon(e)
    project_path = pathM.join $('.entry.selected span').attr('data-path'),@moduleLocatFileName
    # 判断文件是否存在，存在则执行  || 后面的代码 即：判断文件是否为文件夹
    # 文件不存在 则提示，文件不是文件夹时 也输出
    if !fs.existsSync(project_path) || !fs.statSync(project_path).isDirectory()
      alert "不存在 #{project_path} 文件夹"
      @parentView.enable = false
      return
    list = fs.readdirSync(project_path)
    _moduleList = @moduleList
    _moduleList.empty()
    index = 0
    # moduleConfigFileName =  desc.moduleConfigFileName
    printName = (filePath) =>
      stats = fs.statSync(filePath)
      if stats.isDirectory()
        # console.log file.getPath()
        basename = pathM.basename filePath
        path = pathM.join filePath,@moduleConfigFileName
        if fs.existsSync(path)
          contentList = JSON.parse(fs.readFileSync(path))
          _moduleList.append('<div class="checkbox-layout"><div class="checkboxFive"><input value="'+path+'" id="module-config'+basename+'" type="checkbox" class="modulecheckbox hide"/><label for="module-config'+basename+'"></label></div><label class="label-empty" for="module-config'+basename+'">'+contentList['name']+'</label></div>')
          index = index + 1
    printName pathM.join project_path,file for file in list
    if index is 0
      @parentView.enable = false
      alert "没有模块"
      return
    this.find('input').on 'click', (e) => @checkedBox(e)
    @prevStep()

  checkedBox: (e) ->
    @.find('input[type=checkbox]').attr('checked',false)
    el = e.currentTarget
    el.checked = true

  nextStep: ->
    # projectConfigFileName = desc.projectConfigFileName
    if @second.hasClass('hide')
      # console.log 'second has hide'
      flag = @getInitInput()
      if !flag
        return
      @main.addClass('hide')
      @second.removeClass('hide')
      @parentView.nextBtn.text('保存')
      @parentView.prevBtn.removeClass('hide')
      @parentView.cancelBtn.text('还原')
    else
      real_path = $('.modulecheckbox:checked').attr('value')
      if fs.existsSync(real_path)
        options =
          encoding: 'utf-8'
        contentList = JSON.parse(fs.readFileSync(real_path,options))
        contentList['name'] = @moduleName.getText().trim()
        contentList['version'] = @moduleVersion.getText().trim()
        # contentList['description'] = @moduleDescription.getText().trim()
        # contentList['main'] = @moduleInput.getText().trim()
        if contentList['name'] is "" or contentList['version'] is ""
          alert "模块名、版本不能为空"
          return

        configPath = pathM.join real_path, '..', '..', '..', @projectConfigFileName
        # console.log configPath
        # console.log contentList
        cb = (err,written,string) =>
          if err
            alert '保存失败'
          else
            if fs.existsSync(configPath)
              configContentList = JSON.parse(fs.readFileSync(configPath))
              configContentList['modules'][contentList['identifier']] = @moduleVersion.getText()
              cb2 = (err,written,string) =>
                if err
                  console.log '写入应用配置失败'
                else
                  console.log '写入应用配置成功'
              fs.writeJson configPath,configContentList,cb2
            alert '保存成功'
          @parentView.closeView()
        fs.writeJson real_path,contentList,cb
        @parentView.closeView()
      else
        alert "不存在#{real_path}"

  prevStep: ->
    @main.removeClass('hide')
    @second.addClass('hide')
    @parentView.nextBtn.text('下一步')
    @parentView.prevBtn.addClass('hide')
    @parentView.cancelBtn.text('取消')

  getInitInput: ->
    if this.find('input[type=checkbox]').is(':checked')
      console.log $('.modulecheckbox:checked')
      real_path = $('.modulecheckbox:checked').attr('value')
      img_path = pathM.join real_path,"..",@moduleLogoFileName
      console.log real_path
    else
      alert('请选择模块')
      return false
    # console.log real_path
    file = new File(real_path)
    file.setEncoding('UTF-8')
    #读取文件中的内容
    if fs.existsSync(img_path)
      @logo.attr("src",img_path)
    else
      @logo.attr("src",desc.getImgPath @moduleLogoFileName)
    file.read(false).then (contents) =>
      # console.log JSON.parse(contents)
      contentList = JSON.parse(contents)
      @moduleName.setText(contentList['name'])
      @moduleVersion.setText(contentList['version'])
      @moduleDescription.setText(contentList['description'])
      # @moduleInput.setText(contentList['main'])
      # @version = contentList['version']
      # console.log @version
      # contentList = contents.split(',')
      # console.log contentList
      # @moduleName.setText(contentList[0].split(':')[1])
      # @moduleVersion.setText(contentList[1].split(':')[1])
      # @moduleDescription.setText(contentList[2].split(':')[1])
      # @muduleInput.setText(contentList[3].split(':')[1])

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

module.exports =
  class ModuleView extends ChameleonBox
    options :
      title: desc.moduleConfig
      subview: new ModuleInfoView()
