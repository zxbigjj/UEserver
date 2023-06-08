% rebase('base.tpl', child='role_log', sidemenu='')
<link href="static/datetimepicker/css/bootstrap-datetimepicker.css" rel="stylesheet">
<script src="static/datetimepicker/js/bootstrap-datetimepicker.js"></script>
<script src="static/datetimepicker/js/bootstrap-datetimepicker.zh-CN.js"></script>

<link rel="stylesheet" href="static/bootstrap-table/bootstrap-table.min.css">
<script src="static/bootstrap-table/bootstrap-table.min.js"></script>

<h1>欢迎</h1>
<h4 id="date"></h4>
<form class="form-horizontal" id="query_rol_log">
        <div class="form-group">
        <label for="gift_key" class="col-sm-1 control-label">玩家日志ID:</label>
        <div class="col-sm-2">
          <input type="text" class="form-control" id="id">
        </div>
        <div class="col-sm-offset-3">
          <button id="query_submit" type="submit" class="btn btn-primary"
            style="padding-left: 30px; padding-right: 30px">查询</button>
        </div>
        </div>
        </form>
<form class="form-horizontal" id="delete_rol_log">
        <div class="form-group">
        <label for="begin_time" class="col-sm-1 control-label">时间区间</label>
        <div class="col-sm-4">
          <div class="input-group date form_date form-control" id="begin_time" data-date=""
            data-date-format="yyyy/m/d hh:00" data-link-field="dtp_input1" data-link-format="yyyy-mm-dd hh:00">
            <input class="form-control" size="100" type="text" value="" placeholder="精确到小时" readonly>
            <span class="input-group-addon"><span class="glyphicon glyphicon-remove"></span></span>
            <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
          </div>
        </div>
        <div class="col-sm-4">
          <div class="input-group date form_date form-control" id="end_time" data-date=""
            data-date-format="yyyy/m/d hh:00" data-link-field="dtp_input1" data-link-format="yyyy-mm-dd hh:00">
            <input class="form-control" size="100" type="text" value="" placeholder="精确到小时" readonly>
            <span class="input-group-addon"><span class="glyphicon glyphicon-remove"></span></span>
            <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
          </div>
        </div>
        <div class="col-sm-offset-3">
          <button id="delete_submit" type="submit" class="btn btn-primary"
            style="padding-left: 30px; padding-right: 30px">删除</button>
        </div>
        </div>
        </form>
<table class="table table-striped">
            <thead>
                <tr>
                    <th style="width: 30%"></th>
                    <th style="width: 20%"></th>
                    <th style="width: 20%"></th>
                    <th style="width: 15%"></th>
                    <th style="width: 15%"></th>
                </tr>
            </thead>
            <tbody id="role_log_result">

            </tbody>
        </table>

<script type="text/javascript">
  $(document).ready(function () {
    $('.form_date').datetimepicker({
      language: 'zh-CN',
      weekStart: 1,
      todayBtn: 1,
      autoclose: 1,
      todayHighlight: 1,
      startView: 1,
      minView: 1,
      maxView: 2,
      forceParse: 0,
    });
  });
</script>
<script>
$(document).ready(function () {
   
        
       
      $.ajax({
        type: "GET",
        async: true,
        url: "patch_server_url",
        data: {
          "id": 123,
          "param1":123,
        },
        dataType: 'json',
        success: function (msg) {
          console.log(msg.info)
            toastr.options.positionClass = 'toast-top-center';
                    if (msg.err) {
                        toastr.error(msg.err);
                        return;
                    }
            
        }
      })
    })

    $(document).ready(function () {
      $("#delete_rol_log").submit(function () {
        
        event.preventDefault();
        var begin_time=Date.parse($('#begin_time').data().date).toString();
        if (begin_time == null || begin_time == "") {
        toastr.options.positionClass = 'toast-top-center';
        toastr.error("请选择开始时间");
        return;
      }
        var end_time=Date.parse($('#end_time').data().date).toString();
      if (end_time == null || end_time == "") {
        toastr.options.positionClass = 'toast-top-center';
        toastr.error("请选择结束时间");
        return;
      }
        console.log(end_time)
      $.ajax({
        type: "POST",
        async: true,
        url: "delete_server_url",
        data: {
          begin_time: begin_time,
          end_time:end_time,
        },
        dataType: 'json',
        success: function (msg) {
          console.log(msg.info)
            toastr.options.positionClass = 'toast-top-center';
                    if (msg.err) {
                        toastr.error(msg.err);
                        return;
                    }
            
            
        }
      })
    })
    $("#query_rol_log").submit(function () {
        
        event.preventDefault();
        var id=$("#id").val();
        $("#role_log_result").find("tr").remove();
      $.ajax({
        type: "POST",
        async: true,
        url: "view_server_url",
        data: {
          id: id,
        },
        dataType: 'json',
        success: function (msg) {
          console.log(msg.info)
            toastr.options.positionClass = 'toast-top-center';
                    if (msg.err) {
                        toastr.error(msg.err);
                        return;
                    }
            
            for( var index = 0; index < msg.info.length; index++)
                  {
                    var tr = "<tr>"
                    console.log(msg.info.length);
                        $.each(msg.info[index], function (key, val) {
                            if (key == "id") { tr += "<td>ID: " + val + "</td>" }
                            if (key == "now") { tr += "<td>时间: " +new  Date(val * 1000).format("yy-MM-dd<br>HH:mm") + "</td>" }
                            if (key == "param1") { tr += "<td>参数一: " + val + "</td>" }
                            if (key == "param2") { tr += "<td>参数二:  " + val + "</td>" }
                            if (key == "param3") { tr += "<td>参数三:  " + val + "</td>" }
                        })
                        tr += "</tr>"
                        console.log(tr);
                        $("#role_log_result").append(tr);
                  }
        }
      })
    })
})
</script>