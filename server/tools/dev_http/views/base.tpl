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

  <title>罪惡城</title>

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
        <text class="navbar-brand">罪惡城</text>
      </div>
    </div>
  </nav>
  <div class="container-fluid">
    <div class="row">
      <div id="menu-root" class="col-sm-3 col-md-2 sidebar">
        <div class="nav list-group navside-header">
          <a href="/index" class="list-group-item{{get_view_class('index', child)}}">基础</a>
          <a href="/test_page" class="list-group-item{{get_view_class('test_page', child)}}">测试</a>
        </div>
      </div>
      <div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">
        {{!base}}
      </div>
    </div>
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
      $("#menu-root").find(".disabled").removeAttr("href");
    });
  </script>
  <!-- Bootstrap core JavaScript
    ================================================== -->
  <!-- Placed at the end of the document so the pages load faster -->

</body>

</html>