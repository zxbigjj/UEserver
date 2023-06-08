% rebase('base.tpl', child='user_log', sidemenu='log_mgr')
<link href="static/datetimepicker/css/bootstrap-datetimepicker.css" rel="stylesheet">
<script src="static/datetimepicker/js/bootstrap-datetimepicker.js"></script>
<script src="static/datetimepicker/js/bootstrap-datetimepicker.zh-CN.js"></script>

<h2>查询后台日志</h2>
<div class="panel panel-default">
  <div class="panel-heading">
    <form class="form-inline" id="query_form">
      <div class="form-group">
        <label for="account">账号</label>
        <input type="text" class="form-control" id="account" placeholder="留空则查询所有日志">
      </div>
      <div class="form-group">
        <label for="dtp_input1" class="control-label">开始日期</label>
        <div class="input-group date form_date" data-date="" data-date-format="yyyy/m/d" data-link-field="dtp_input1" data-link-format="yyyy-mm-dd">
            <input class="form-control" size="16" type="text" value="" readonly>
            <span class="input-group-addon"><span class="glyphicon glyphicon-remove"></span></span>
            <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
        </div>
        <input type="hidden" id="dtp_input1" value="" /><br/>
      </div>
      <div class="form-group">
        <label for="dtp_input2" class="control-label">结束日期</label>
        <div class="input-group date form_date" data-date="" data-date-format="yyyy/m/d" data-link-field="dtp_input2" data-link-format="yyyy-mm-dd">
            <input class="form-control" size="16" type="text" value="" readonly>
            <span class="input-group-addon"><span class="glyphicon glyphicon-remove"></span></span>
            <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
        </div>
        <input type="hidden" id="dtp_input2" value="" /><br/>
      </div>
      <button type="submit" class="btn btn-primary">查询</button>
    </form>
  </div>
  <div class="panel-body">
    <table class="table table-striped">
      <thead>
        <tr>
          <th>账号</th>
          <th>时间</th>
          <th>页面</th>
          <th>操作</th>
          <th>数据</th>
        </tr>
      </thead>
      <tbody id="log_list">
      </tbody>
    </table>
  </div>
</div>
<script type="text/javascript">
    $(document).ready( function(){
        $('.form_date').datetimepicker({
            language:  'zh-CN',
            weekStart: 1,
            todayBtn:  1,
            autoclose: 1,
            todayHighlight: 1,
            startView: 2,
            minView: 2,
            forceParse: 0
        });

        $("#query_form").submit(function(){
            event.preventDefault();

            var ts_begin = $("#dtp_input1").val()
            var ts_end = $("#dtp_input2").val()
            var name = $("#account").val()
            $('#log_list').find("tr").remove()
            $.ajax({  
               type: "POST",  
               url: "/query_user_log",  
               data: {name:name, ts_begin:ts_begin, ts_end:ts_end},  
               dataType: 'json',
               success: function(msg){
                  toastr.options.positionClass = 'toast-top-center';
                  if(msg.err) {
                    toastr.error(msg.err);
                    return;
                  }
                  for( var index = 0; index < msg.log_list.length; index++)
                  {
                      var log = msg.log_list[index];
                      var newrow = '<tr>'
                      newrow += '<td>' + log.uname + '</td>'
                      newrow += '<td>' + new Date(log.now * 1000).format("yyyy-MM-dd HH:mm:ss") + '</td>'
                      newrow += '<td>' + log.page_name + '</td>'
                      newrow += '<td>' + log.op_name + '</td>'
                      newrow += '<td>' + log.data + '</td>'
                      newrow += '</tr>'
                      $('#log_list').append(newrow)
                  }
               }
            })
        })
    })
</script>