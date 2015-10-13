Path = require 'path'

module.exports = TextDescription =
  headtitle : '标题'
  cancel : '取消'
  next : '下一步'
  prev : '上一步'
  upload : '上传'
  back : '返回'
  finish : '完成'
  save : '保存'
  recovery : '还原'
  login : '登录'
  logout : '退出登录'
  email : '邮箱'
  pwd : '密码'
  save : '保存'
  createProject : '创建应用'

  createModule : '创建模块'
  CreateModuleTitle: '请填写要创建的模块信息'
  modulePath: '模块所在路径'
  moduleId: '模块标识'
  moduleName: '模块名称'
  mainEntry: '模块入口'
  createModuleErrorMsg: '模块或同名目录已存在'

  newProject: '新建应用'

  syncProject: '同步账号中的应用'

  chameleonHome: atom.packages.getLoadedPackage('chameleon-qdt-atom').path
  newProjectDefaultPath: atom.config.get('core').projectHome

  # 获取自带框架存储目录位置
  getFrameworkPath: ->
    Path.join @chameleonHome,'src','frameworks'

  # 获取空白模版存储目录位置
  getProjectTempPath: ->
    Path.join @chameleonHome,'src','ProjectTemp'

  # 获取业务模板存储目录位置
  getTemplatePath: ->
    Path.join @chameleonHome,'src','templates'

  getImgPath:(imgName) ->
    Path.join @chameleonHome,'images',imgName

  mainEntryFileName: 'index.html'


  publishModule: "上传模块"
  publishModulePageOneTitle: '请选择需要发布的模块'
  publishModulePageTwoTitle: '确认发布模块信息'

  moduleConfigFileName: 'package.json'
  ProjectConfigFileName: 'appConfig.json'

  projectConfig : '应用配置'
  moduleConfig : '模块配置'

  defaultModule : 'butterfly-tiny'
  minVersion : '0.0.1'

  # 设置模块
  panelTitle: '设置'
  menuAccount: '开发者账号'
  menuCode: '框架、模版'

  buildProjectMainTitle: "构建应用"
  uploadProjectTitle: "上传应用"
