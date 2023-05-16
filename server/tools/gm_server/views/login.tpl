
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
    <link href="static/signin.css" rel="stylesheet">

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://cdn.bootcss.com/html5shiv/3.7.3/html5shiv.min.js"></script>
      <script src="https://cdn.bootcss.com/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>

  <body>
    <div class="container">
      <form class="form-signin" id="form_login">
        <h2 class="form-signin-heading">请输入账号密码</h2>
        <input type="text" name="username" class="form-control" placeholder="账号" required autofocus>
        <input type="password" name="password" class="form-control" placeholder="密码" required>
        <button class="btn btn-lg btn-primary btn-block" type="submit" style="width:120px;margin:auto">登录</button>
      </form>
      
    </div> <!-- /container -->

    <script type="text/javascript">
      $("#form_login").submit(function(event){
          // cancels the form submission
          event.preventDefault();
          $.ajax({  
             type: "POST",  
             url: "/login",  
             data: $("#form_login").serializeArray(),  
             dataType: 'text',
             success: function(msg){
                  toastr.options.positionClass = 'toast-top-center';
                  if(msg != "") {
                    toastr.error(msg);
                    return;
                  }
                  window.location.href='/welcome';
             }
          });
      });
    </script>

    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
  </body>
</html>
