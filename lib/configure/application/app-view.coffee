{$,View,TextEditorView} = require 'atom-space-pen-views'
desc = require '../../utils/text-description'
{File,Directory} = require 'atom'
PathM = require 'path'
# fs = require 'fs-extra'
Util = require '../../utils/util'
ChameleonBox = require './../../utils/chameleon-box-view'
_ = ChameleonBox._

# module.exports =
class AppView extends View
  @content: ->
    @div class: 'container', =>
      @div class: "col-xs-12", =>
        @label class: 'col-sm-3 col-md-3', "应用标识"
        @div class: 'col-sm-9 col-md-9', =>
          @subview 'appId', new TextEditorView(mini: true,placeholderText: 'appId...')
      @div class: "col-xs-12 ", =>
        @label class: 'col-sm-3 col-md-3', "应用名称"
        @div class: 'col-sm-9 col-md-9', =>
          @subview 'appName', new TextEditorView(mini: true,placeholderText: 'appName...')
      @div class: "col-xs-12 ", =>
        @label class: 'col-sm-3 col-md-3', "应用版本"
        @div class: 'col-sm-9 col-md-9', =>
          @subview 'appVersion', new TextEditorView(mini: true,placeholderText: 'appVersion...')
      @div class: "col-xs-12 ", =>
        @label class: 'col-sm-3 col-md-3', "启动模块"
        @div class: 'col-sm-9 col-md-9', =>
          @subview 'appStartModule', new TextEditorView(mini: true,placeholderText: 'mainModule...')

  serialize: ->

  attached: ->
    # 首先检查 是否有应用的配置文件
    result = @searchAppConfig()

    # 删除已保存的配置和路径
    delete @config
    delete @configPath

    console.log result,@config
    unless result.isExist
      alert '没有找到应用的配置文件'
      @parentView.enable = false
    # ==================
    else
      @readConfig result.path
      @parentView.setNextBtn('finish',desc.save)
      @parentView.setPrevBtn('normal',desc.recovery)
      @parentView.prevBtn.addClass('other')

  saveInput: ->
    project_path = if @configPath? then @configPath else PathM.join $('.entry.selected span').attr('data-path'),'appConfig.json'
    mod =
      identifier: @appId.getText().trim()
      name: @appName.getText().trim()
      version: @appVersion.getText().trim()
      mainModule: @appStartModule.getText().trim()
    config = _.extend(@config,mod)
    callback= (err) ->
      unless err?
        alert "应用信息保存成功！"
        @parentView.closeView()
      else
        console.log err
        alert "应用信息保存失败..."
    Util.writeJson project_path, config ,callback

  resetConfig: ->
    @setConfig @config


  searchAppConfig: ->
    select_path = $('.entry.selected span').attr('data-path')
    if PathM.basename(select_path) is desc.ProjectConfigFileName
      result =
        isExist: true
        path: select_path
    else
      projects = atom.project.getDirectories()
      currProject = (dir for dir in atom.project.getDirectories() when dir.path is select_path or dir.contains(select_path))[0]
      appConfigPath = PathM.join currProject.path, desc.ProjectConfigFileName if currProject?
      isExist = Util.isFileExist(appConfigPath,'sync') if appConfigPath?
      result =
        isExist: if isExist? then isExist else false
        path:  appConfigPath if isExist is yes

  readConfig: (configPath) ->
    config = Util.readJsonSync(configPath)
    if config?
      # 保存 路径和配置
      @configPath = configPath
      @config = config

      console.log config
      @setConfig config
    else
      console.log '读取文件失败'

  setConfig:(config) ->
    @appId.setText(config['identifier'])
    @appName.setText(config['name'])
    @appVersion.setText(config['version'])
    @appStartModule.setText(config['mainModule'])

  getElement: ->
    @element

  nextStep:(box) ->
    console.log box
    box.mergeOptions {configPath:@configPath}
    box.nextStep()

  prevStep: (box) ->
    @resetConfig()


module.exports =
class appConfigView extends ChameleonBox

  options :
    title : desc.projectConfig
    subview : new AppView()
