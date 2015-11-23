Path = require 'path'

module.exports = TextDescription =
  headtitle : '标题'
  cancel : '取消'
  next : '下一步'
  prev : '上一步'
  upload : '上传'
  back : '返回'
  finish : '完成'
  edit: '编辑'
  save : '保存'
  recovery : '还原'
  login : '登录'
  osclogin: 'osc账号登录'
  logout : '退出登录'
  email : '邮箱'
  pwd : '密码'
  save : '保存'
  forgetPwd: '忘记密码'
  other: '其他'
  openFromFolder: '从文件夹打开'
  framework: '框架'
  _module: '模块'
  add: '添加'

  createProject: '创建应用'
  createAppType: '请选择要创建的应用类型'
  createAppInfo: '请填写要创建的应用信息'
  inputAppID: '请输入应用标识'
  appIDPlaceholder: '例如: com.foreveross.myapp'
  appIDError: '只能输入字母和点，且至少三级目录，11-64个字符，例如: com.foreveross.myapp'
  inputAppName: '请输入应用名称'
  appNamePlaceholder: '应用显示的名称'
  inputAppPath: '应用创建位置'
  appPathExist:'该应用目录已存在'
  emptyApp: '空白应用'
  createLocalAppDesc: '创建一个本地应用'
  syncAccountAppDesc: '同步已登录帐户中的应用到本地，未登录的用户请登录'
  createAppSuccess: '创建应用成功！'
  createAppError: '应用创建失败'

  appFrameworks: '应用框架'
  appFrameworksDesc: '用户常用的开发框架'
  appTemplate: '应用模板'
  appTemplateDesc: '提供一些日常应用的场景，例如：新闻，电商，移动OA，小说阅读'

  selectAPPTemplate: '请选择应用模板'
  selectAPPFrameworks: '请选择开发框架'

  defaultModule: '默认模块'
  defaultModuleDesc: '将生成默认的配置文件和主页'


  createModule : '创建模块'
  createModuleTitle: '请填写要创建的模块信息'
  createModuleType: '请选择要创建的模块类型'
  selectProjectPath: '请选择应用目录'
  modulePath: '独立模块(保存目录)'
  moduleInApp: '基于应用'
  moduleId: '模块标识'
  moduleName: '模块名称'
  mainEntry: '模块入口'
  createModuleSuccess: '创建模块成功！'
  createModuleError: '模块创建失败'


  emptyModule: '空白模块'
  simpleMoudle: '快速开发'
  simpleMoudleDesc: '通过简单的拖拽页面组件生成主页和配置文件'
  defaultTemplateModule:'自定义框架'

  selectModuleTemplate: '请选择模块模板'



  createModuleErrorMsg: '模块或同名目录已存在'
  moduleIdErrorMsg:'模块标识以字母开头,长度必须在6-32个字符范围内,只能输入数字,字母,下划线'

  newProject: '新建应用'

  syncProject: '同步账号中的应用'

  registerUrl : 'http://www.baidu.com'

  gitFolder: '.git'
  gitCloneError: 'git clone失败，请检查网络连接'

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
  appModule: "应用的模块"
  uAppModule: "非应用的模块"
  publishModuleFirstStep: "请选择要上传的模块"
  publishModuleSecondStep: "请填写模块信息"
  changeLogoBtn: "更换模块LOGO"
  moduleNameLabel: "模块名称:"
  moduleUploadVersionLabel: "上传版本:"
  uploadMessageLabel: "更新内容"
  selectModuleErrorTips: "请选择要上传的模块"
  uploadModuleVersionErrorTips: "上传模块的版本小于等于服务器上的版本"
  moduleNameIsNullError: "模块名称不能为空"
  moduleVersionIsNullError: "模块版本不能为空"
  moduleVersionUnLegelError: "模块版本格式不合法，正确格式如下：10.3.10"
  moduleUploadProcessLabel: "上传中"

  publishModulePageOneTitle: '请选择需要发布的模块'
  publishModulePageTwoTitle: '确认发布模块信息'

  moduleConfigFileName: 'module-config.json'
  projectConfigFileName: 'app-config.json'
  builderConfigFileName: 'builder-config.json'
  nodeModuleConfigFileName: 'package.json'

  projectConfig : '应用配置'
  moduleConfig : '模块配置'

  defaultModuleName : 'butterfly-tiny'
  minVersion : '0.0.0'

  # 设置模块
  panelTitle: '设置'
  menuAccount: '开发者账号'
  menuCode: '框架、模版'

  buildProjectMainTitle: "构建应用"
  uploadProjectTitle: "上传应用"

  moduleLogoFileName: 'icon.png'
  moduleLocatFileName: 'modules'

  uploadAppError: ""
  uploadAppSuccess: "上传应用成功"

  projectTipsStep5_1: "请选择横竖屏支持"
  projectTipsStep5_2: "请选择硬件支持"
  projectTipsStep6_selectImg:"请选择扩展名为 .png"

  # builder
  builderPanelTitle: 'QDT-Builder'

  oscLoginPanelTitle: 'OSChina登录'

  selectCorrectProject: "请选择变色龙应用"
  rapidDevTitle: '快速开发'
  noModules: '暂无相关模块'
  projectList: '项目列表'
