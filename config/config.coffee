mode = 'test'
getModeUrl = ->
  switch mode
    when 'dev'
      url: 'qdt-web-dev'
      client_id: 'JEJAugLlTgnaOxVhA1g1'
    when 'pro'
      url: 'qdt-web'
      client_id: 'ql4p9NCK8qztzrWCpzbK'
    when 'test'
      url: 'qdt-web-test'
      client_id: '08yXEftRlLWMbdOpCzS1'

modeUrl = getModeUrl()

module.exports =
  repoUri: "https://git.oschina.net/linruheng/butterfly-tiny.git"
  registerUrl: "http://bsl.foreveross.com/#{modeUrl.url}/html/account/register.html"
  forgetpwdrUrl: "http://bsl.foreveross.com/#{modeUrl.url}/html/account/forget_pwd.html"
  serverUrl: "http://bsl.foreveross.com/#{modeUrl.url}/api/v1/"

  oscLoginUrl: "https://www.oschina.net/action/oauth2/authorize?client_id=#{modeUrl.client_id}&redirect_uri=http://bsl.foreveross.com/#{modeUrl.url}/api/v1/anonymous/oschina&response_type=code&state=qdt"

  tempList: [
    {
      name: '新闻模板'
      type: 'news'
      pic: 'http://7xifa4.com1.z0.glb.clouddn.com/a.png'
      url: "https://git.oschina.net/linruheng/butter_newstemp.git"
      thumbnail: [
        'http://7xifa4.com1.z0.glb.clouddn.com/pic_1.png'
        'http://7xifa4.com1.z0.glb.clouddn.com/pic_2.png'
        'http://7xifa4.com1.z0.glb.clouddn.com/pic_3.png'
        'http://7xifa4.com1.z0.glb.clouddn.com/pic_4.png'
        'http://7xifa4.com1.z0.glb.clouddn.com/pic_5.png'
      ]
    }
  ]
