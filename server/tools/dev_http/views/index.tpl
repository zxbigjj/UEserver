% rebase('base.tpl', child='index', sidemenu='')
<!-- <p>请先更新配置表</p> -->
<table class="table table-striped">
  <thead>
    <tr>
      <th style="width:200px">服务器</th>
      <th style="width:100px">服务器id</th>
      <th style="width:100px">重启时间</th>
      <th style="width:100px">状态</th>
      <th>操作</th>
    </tr>
  </thead>
  <tbody>
    % for server in server_list:
    <tr class="server" server_id="{{server.server_id}}" path="{{server.path}}" name="{{server.name}}"
      status="{{server.status}}" time="{{server.time}}">
    % end
  </tbody>
</table>


<!-- 浮动窗口 -->
<div class="modal fade" id="show_log" tabindex="-1" role="dialog">
  <div class="modal-dialog" style="width:800px">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        <h3 class="modal-title">操作结果</h3>
      </div>
      <div id="log_area" class="modal-body">
      </div>
    </div>
  </div><!-- /.modal -->
</div>


<!-- 控件 -->
<script type="text/javascript">
  $(document).ready(function () {
    $('#show_log').on('hidden.bs.modal', function (e) {
      setTimeout("window.location.reload()", 200)
    })

    $("tr.server").each(function (index, elem) {
      $(elem).append("<td>{0}</td>".format(elem.getAttribute('name')));
      $(elem).append("<td>{0}</td>".format(elem.getAttribute('server_id')));
      $(elem).append("<td>{0}</td>".format(elem.getAttribute('time')));
      status = elem.getAttribute('status')
      if (status == "运行") {
        $(elem).append('<td style="color:green">{0}</td>'.format(status));
      }
      else {
        $(elem).append('<td style="color:red">{0}</td>'.format(status));
      }

      $(elem).append("<td></td>");
      $(elem).children(":last")
        .append('<button op="reload_exceldata">更新配置表</button>')
        .append('<label style="width:20px"></label>')
        .append('<button op="restart">重启</button>')
        .append('<label style="width:20px"></label>')
        .append('<button op="del_database">删档重启</button>');
      $(elem).find("button").click(function () {
        server_id = elem.getAttribute('server_id')
        data = {
          op: this.getAttribute('op'),
          server_id: server_id,
          server_path: elem.getAttribute('path')
        }
        $.ajax({
          type: "POST",
          url: "/op_server",
          dataType: 'json',
          data: data,
          success: function (msg) {
            toastr.options.positionClass = 'toast-top-center';
            if (msg.err) {
              toastr.error(msg.err);
              return
            }
            $('#show_log').modal('show')
            $('#log_area').find('p').remove()
            fetch_log(server_id)
          }
        });
      });
    });
  });

  function fetch_log(server_id) {
    $.ajax({
      type: "POST",
      url: "/check_server_op",
      dataType: 'json',
      data: { server_id: server_id },
      success: function (msg) {
        msg.info.forEach(function (elem) {
          $('#log_area').append("<p>{0}</p>".format(elem))
        })
        if (msg.finish) {
        }
        else {
          setTimeout(function () { fetch_log(server_id) }, 500)
        }
      }
    })
  }
</script>