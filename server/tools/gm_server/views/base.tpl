<!DOCTYPE html>
<html lang="zh-CN">

  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- 上述3个meta标签*必须*放在最前面，任何其他内容都*必须*跟随其后！ -->
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="static/favicon.ico">

    <script src="static/jquery/3.2.1/jquery-3.2.1.js"></script>
    <script src="static/bootstrap/3.3.7/js/bootstrap.min.js"></script>
    <script src="static/toastr/toastr.min.js"></script>
    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
    <script src="static/ie10-viewport-bug-workaround.js"></script>

    <title>罪惡城运营系统</title>

    <!-- Bootstrap core CSS -->
    <link href="static/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet">
    <link href="static/toastr/toastr.min.css" rel="stylesheet">

    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
    <link href="static/ie10-viewport-bug-workaround.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="static/dashboard.css" rel="stylesheet">
    % if defined('child_css'):
    <link href="static/{{child_css}}" rel="stylesheet">
    % end

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://cdn.bootcss.com/html5shiv/3.7.3/html5shiv.min.js"></script>
      <script src="https://cdn.bootcss.com/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>

  <body>
    % if defined('child_js'):
    <script src="static/{{child_js}}"></script>
    % end
    <nav class="navbar navbar-inverse navbar-fixed-top">
      <div class="container-fluid">
        <div class="navbar-header">
          <text class="navbar-brand">罪惡城运营系统</text>
        </div>
        <div id="navbar" class="navbar-collapse collapse">
          <ul class="nav navbar-nav navbar-right">
            <li><text class="navbar-brand">当前用户：{{curr_user.nick}}</text></li>
            <li><a href="#" data-toggle="modal" data-target="#changePwd">修改密码</a></li>
            <li><a href="logout">退出</a></li>
          </ul>
        </div>
      </div>
    </nav>

    <div class="container-fluid">
      <div class="row">
        <div id="menu-root" class="col-sm-3 col-md-2 sidebar">
          <div class="nav list-group navside-header">
            <a href="#menu-user-mgr" class="list-group-item" data-toggle="collapse">账号管理</a>
            <div id="menu-user-mgr" class="list-group navside-list{{"" if sidemenu==" user_mgr" else " collapse in" }}">
              <a href="/view_user_mgr" class="list-group-item{{get_view_class('user_mgr', child, curr_user)}}">账号管理</a>
              <a href="/view_group_mgr" class="list-group-item{{get_view_class('group_mgr', child, curr_user)}}">组管理</a>
            </div>

            <a href="#menu-player-mgr" class="list-group-item" data-toggle="collapse">游戏管理</a>
            <div id="menu-player-mgr" class="list-group navside-list{{"" if sidemenu==" player_mgr" else " collapse in" }}">
              <a href="/view_player_query" class="list-group-item{{get_view_class('player_query', child, curr_user)}}">玩家查询</a>
              <a href="/view_player_forbid" class="list-group-item{{get_view_class('player_forbid', child, curr_user)}}">封禁解封</a>
              <a href="/view_delete_item" class="list-group-item{{get_view_class('delete_item', child, curr_user)}}">删除道具</a>
              <a href="view_player_level" class="list-group-item{{get_view_class('level_query', child, curr_user)}}">等级修改</a>
              <a href="view_role_vip_mgr" class="list-group-item{{get_view_class('role_vip_mgr', child, curr_user)}}">vip修改</a>
              <a href="view_server_list" class="list-group-item{{get_view_class('server_list', child, curr_user)}}">服务器列表</a>
              <a href="view_version" class="list-group-item{{get_view_class('version', child, curr_user)}}">版本控制</a>
              <a href="view_server_time" class="list-group-item{{get_view_class('server_time', child, curr_user)}}">修改服务器时间</a>
            </div>

            <a href="#menu-log-mgr" class="list-group-item" data-toggle="collapse">日志管理</a>
            <div id="menu-log-mgr" class="list-group navside-list{{"" if sidemenu==" log_mgr" else " collapse in" }}">
              <a href="/view_user_log" class="list-group-item{{get_view_class('user_log', child, curr_user)}}">后台日志</a>
              <a href="/view_role_log" class="list-group-item{{get_view_class('role_log', child, curr_user)}}">玩家日志</a>
            </div>

            <a href="#menu-notify-mgr" class="list-group-item" data-toggle="collapse">公告管理</a>
            <div id="menu-notify-mgr" class="list-group navside-list{{"" if sidemenu==" notify_mgr" else " collapse in" }}">
              <a href="/view_online_notify" class="list-group-item{{get_view_class('online_notify', child, curr_user)}}">线上公告</a>
              <a href="/view_system_notify" class="list-group-item{{get_view_class('system_notify', child, curr_user)}}">系统公告</a>
            </div><!-- 改过notify -->

            <a href="#menu-mail-mgr" class="list-group-item" data-toggle="collapse">邮件管理</a>
            <div id="menu-mail-mgr" class="list-group navside-list{{"" if sidemenu==" mail_mgr" else " collapse in" }}">
              <a href="/view_sys_mail" class="list-group-item{{get_view_class('sys_mail', child, curr_user)}}">后台邮件</a>
              <a href="/view_role_mail" class="list-group-item{{get_view_class('role_mail', child, curr_user)}}">玩家邮件</a>
            </div>

            <a href="#menu-other-mgr" class="list-group-item" data-toggle="collapse">其他管理</a>
            <div id="menu-other-mgr" class="list-group navside-list{{"" if sidemenu==" other_mgr" else " collapse in" }}">
              <a href="/view_map_mgr" class="list-group-item{{get_view_class('map_mgr', child, curr_user)}}">开启地图</a>
              <a href="/view_query_vip" class="list-group-item{{get_view_class('query_vip', child, curr_user)}}">充值查询</a>
              <a href="/view_query_union" class="list-group-item{{get_view_class('query_union', child, curr_user)}}">王朝查询</a>
              <a href="/view_gift_key" class="list-group-item{{get_view_class('gift_key', child, curr_user)}}">礼包码</a>
              <a href="/view_statistic" class="list-group-item{{get_view_class('statistic', child, curr_user)}}">在线人数</a>
            </div>
            <a href="#menu-event-mgr" class="list-group-item" data-toggle="collapse">Event Online</a>
            <div id="menu-other-mgr" class="list-group navside-list{{"" if sidemenu==" event_mgr" else " collapse in" }}">
              <a href="/view_event_query" class="list-group-item{{get_view_class('event_query', child, curr_user)}}">Event List</a>
              <a href="/view_event_config" class="list-group-item{{get_view_class('event_config', child, curr_user)}}">Event Set</a>
            </div>
            <a href="/view_query_tool" class="list-group-item{{get_view_class('query_tool', child, curr_user)}}">Query Tool</a>
            <a href="/view_lover_activities" class="list-group-item{{get_view_class('lover_activities', child, curr_user)}}">Lover Activities</a>
            <a href="/view_hero_activities" class="list-group-item{{get_view_class('hero_activities', child, curr_user)}}">Hero Activities</a>
          </div>
        </div>
        <div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">
          {{!base}}
        </div>
      </div>
    </div>

    <div class="modal fade" id="changePwd" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            <h3 id="changePwdTips" class="modal-title">修改密码</h3>
          </div>
          <div class="modal-body">
            <form class="form-changePwd" id="form_changepwd">
              <input type="password" id="pwd1" class="form-control" placeholder="输入新密码" required autofocus>
              <input type="password" id="pwd2" class="form-control" placeholder="再次输入新密码" required>
              <button class="btn btn-lg btn-primary btn-block" type="submit" style="width:200px;margin:auto">确定</button>
            </form>
          </div>
        </div>
      </div><!-- /.modal -->
    </div>


    <script type="text/javascript">
      String.prototype.format = function (args) {
        var result = this;
        if (arguments.length > 0) {
          if (arguments.length == 1 && typeof (args) == "object") {
            for (var key in args) {
              if (args[key] != undefined) {
                var reg = new RegExp("({" + key + "})", "g");
                result = result.replace(reg, args[key]);
              }
            }
          }
          else {
            for (var i = 0; i < arguments.length; i++) {
              if (arguments[i] != undefined) {
                var reg = new RegExp("({)" + i + "(})", "g");
                result = result.replace(reg, arguments[i]);
              }
            }
          }
        }
        return result;
      }

      Date.prototype.format = function (fmt) {
        var o = {
          "M+": this.getMonth() + 1, //月份         
          "d+": this.getDate(), //日         
          "h+": this.getHours() % 12 == 0 ? 12 : this.getHours() % 12, //小时         
          "H+": this.getHours(), //小时         
          "m+": this.getMinutes(), //分         
          "s+": this.getSeconds(), //秒         
          "q+": Math.floor((this.getMonth() + 3) / 3), //季度         
          "S": this.getMilliseconds() //毫秒         
        };
        var week = {
          "0": "\u65e5",
          "1": "\u4e00",
          "2": "\u4e8c",
          "3": "\u4e09",
          "4": "\u56db",
          "5": "\u4e94",
          "6": "\u516d"
        };
        if (/(y+)/.test(fmt)) {
          fmt = fmt.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
        }
        if (/(E+)/.test(fmt)) {
          fmt = fmt.replace(RegExp.$1, ((RegExp.$1.length > 1) ? (RegExp.$1.length > 2 ? "\u661f\u671f" : "\u5468") : "") + week[this.getDay() + ""]);
        }
        for (var k in o) {
          if (new RegExp("(" + k + ")").test(fmt)) {
            fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
          }
        }
        return fmt;
      }


      $(document).ready(function () {
        $("#changePwd").on("show.bs.modal", function () {
          $('#pwd1').val("");
          $('#pwd2').val("");
        })
        $("#menu-root").find(".disabled").removeAttr("href");
        $("#form_changepwd").submit(function (event) {
          // cancels the form submission
          event.preventDefault();
          var pwd1 = $('#pwd1').val()
          var pwd2 = $('#pwd2').val()
          toastr.options.positionClass = 'toast-top-center';
          if (pwd1 != pwd2) {
            toastr.error("两次输入的密码不同！");
            return;
          }
          $.ajax({
            type: "POST",
            url: "/change_password",
            data: { "pwd": pwd1 },
            dataType: 'text',
            success: function (msg) {
              if (msg != "") {
                toastr.error(msg);
                return;
              }
              $('#changePwd').modal('hide');
              toastr.success("密码修改成功！")
            }
          });
        });
      });
    </script>

    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->

  </body>

</html>