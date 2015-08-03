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
  createProject : '创建项目'

  createModule : '创建模块'
  CreateModuleTitle: '请填写要创建的模块信息'
  modulePath: '模块所在路径'
  moduleId: '模块标识'
  moduleName: '模块名称'
  mainEntry: '模块入口'
  createModuleErrorMsg: '模块或同名目录已存在'

  newProject: '新建项目'

  syncProject: '同步账号中的项目'

  registerUrl : 'http://www.baidu.com'

  chameleonHome: atom.packages.getLoadedPackage('chameleon-test').path
  getFrameworkPath: ->
    Path.join @chameleonHome,'src','frameworks'
  newProjectDefaultPath: atom.config.get('core').projectHome
  iconPath:'atom://chameleon-test/images/icon.png'
  mainEntryFileName: 'index.html'


  publishModule: "发布模块"
  publishModulePageOneTitle: '请选择需要发布的模块：'
  publishModulePageTwoTitle: '确认发布模块信息'

  moduleConfigFileName: 'package.json'
  ProjectConfigFileName: 'appConfig.json'

  projectConfig : '应用配置'
  moduleConfig : '模块配置'

  # 设置模块
  panelTitle: '设置'
  menuAccount: '开发者账号'
  menuCode: '框架、模版'

  buildProjectMainTitle: "构建项目"
  uploadProjectTitle: "上传应用"

  newsTemplate:
    name: '新闻'
    type: 'news'
    pic: 'http://7xifa4.com1.z0.glb.clouddn.com/a.png'
