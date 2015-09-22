mode = 'dev'
getModeUrl = ->
	switch mode
		when 'dev' then 'qdt-web-dev'
		when 'pro' then 'qdt-web'
		when 'test' then 'qdt-web-test'
modeUrl = getModeUrl()

module.exports =
	repoUri: "https://git.oschina.net/linruheng/butterfly-tiny.git"
	registerUrl: "http://bsl.foreveross.com/#{modeUrl}/html/account/register.html"
	forgetpwdrUrl: "http://bsl.foreveross.com/#{modeUrl}/html/account/forget_pwd.html"
	serverUrl: "http://bsl.foreveross.com/#{modeUrl}/api/v1/"

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
