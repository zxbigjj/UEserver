% rebase('base.tpl', child='welcome', sidemenu='')
<h4>欢迎：{{curr_user.nick}}</h4>
<ul>
    <li>上次登录时间：{{last_login_time}}</li>
    <li>上次登录ip：{{last_login_ip}}</li>
</ul>
<h4>若非本人登录请立即修改密码</h4>