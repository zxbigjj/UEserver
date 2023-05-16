% rebase('base.tpl', child='group_mgr', sidemenu='user_mgr', child_css='group_mgr.css')
<div style="width:800px;">
  <nav class="navbar navbar-inverse" role="navigation">
    <div class="container-fluid">
      <div>
        <ul class="nav navbar-nav">
          <li><a href="#" onclick="$('#add_group').modal('show');">添加</a></li>
          <li><a href="#" onclick="on_modify();">编辑</a></li>
          <li><a href="#" onclick="on_delete();">删除</a></li>
          <li><a href="#" onclick="on_set_power();">授权</a></li>
        </ul>
      </div>
    </div>
  </nav>
  <table class="table table-striped">
    <thead>
      <tr>
        <th></th>
        <th>编号</th>
        <th>名称</th>
        <th>描述</th>
      </tr>
    </thead>
    <tbody>
      % for group in all_group:
      <tr>
        <td><input type="checkbox" gid="{{group.gid}}" class="group_gid"></td>
        <td name="num">{{group.num}}</td>
        <td name="name">{{group.name}}</td>
        <td name="info">{{group.info}}</td>
      </tr>
      % end
    </tbody>
  </table>

  <div class="modal fade" id="add_group" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
          <h3 id="changePwdTips" class="modal-title">添加用户组</h3>
        </div>
        <div class="modal-body">
          <form id="form_add_group" class="form-addgroup form-inline">
            <div class="form-group">
              <label>组名：</label>
              <input type="text" name="name" class="form-control" placeholder="输入组名" required autofocus>
            </div>
            <div class="form-group">
              <label>描述：</label>
              <input type="text" name="info" class="form-control" placeholder="输入描述" required>
            </div>
            <button class="btn btn-lg btn-primary btn-block" type="submit" style="width:200px;margin:auto">添加</button>
          </form>
        </div>
      </div>
    </div><!-- /.modal -->
  </div>

  <div class="modal fade" id="modify_group" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
    aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
          <h3 id="changePwdTips" class="modal-title">修改用户组</h3>
        </div>
        <div class="modal-body">
          <form id="form_modify_group" class="form-addgroup form-inline">
            <div class="form-group">
              <label>组名：</label>
              <input type="text" name="name" class="form-control" placeholder="输入组名" required autofocus>
            </div>
            <div class="form-group">
              <label>描述：</label>
              <input type="text" name="info" class="form-control" placeholder="输入描述" required>
            </div>
            <input name="gid" class="hidden">
            <button class="btn btn-lg btn-primary btn-block" type="submit" style="width:200px;margin:auto">修改</button>
          </form>
        </div>
      </div>
    </div><!-- /.modal -->
  </div>

  <div class="modal fade" id="set_power" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
          <h3 class="modal-title">权限修改</h3>
        </div>
        <div class="modal-body">
          <form id="form_set_power" class="form-addgroup form-inline">
            <ul class="list-group">
              <li class="list-group-item">
                <table>
                  <thead>
                    <tr>
                      <th><label><input type="checkbox" onclick="click_power_menu('user_mgr', this.checked);">
                          用户管理</label></th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td><label style="padding-left: 20px"><input type="checkbox" name="user_mgr" class="user_mgr">
                          用户管理</label></td>
                    </tr>
                    <tr>
                      <td><label style="padding-left: 20px"><input type="checkbox" name="group_mgr" class="user_mgr">
                          用户组管理</label></td>
                    </tr>
                  </tbody>
                </table>
              </li>
              <li class="list-group-item">
                <table>
                  <thead>
                    <tr>
                      <th><label><input type="checkbox" onclick="click_power_menu('player_mgr', this.checked);">
                          游戏管理</label></th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td><label style="padding-left: 20px"><input type="checkbox" name="player_query"
                            class="player_mgr"> 玩家查询</label></td>
                    </tr>
                    <tr>
                      <td><label style="padding-left: 20px"><input type="checkbox" name="player_forbid"
                            class="player_mgr"> 封禁解禁</label></td>
                    </tr>
                  </tbody>
                </table>
              </li>
              <li class="list-group-item">
                <table>
                  <thead>
                    <tr>
                      <th><label><input type="checkbox" onclick="click_power_menu('log_mgr', this.checked);">
                          日志管理</label></th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td><label style="padding-left: 20px"><input type="checkbox" name="user_log" class="log_mgr">
                          后台日志</label></td>
                    </tr>
                    <tr>
                      <td><label style="padding-left: 20px"><input type="checkbox" name="role_log" class="log_mgr">
                          玩家日志</label></td>
                    </tr>
                  </tbody>
                </table>
              </li>
              <li class="list-group-item">
                <table>
                  <thead>
                    <tr>
                      <th><label><input type="checkbox" onclick="click_power_menu('not_mgr', this.checked);">
                          公告管理</label></th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td><label style="padding-left: 20px"><input type="checkbox" name="online_notify" class="not_mgr">
                          线上公告</label></td>
                    </tr>
                    <tr>
                      <td><label style="padding-left: 20px"><input type="checkbox" name="system_notify" class="not_mgr">
                          系统公告</label></td>
                    </tr>
                  </tbody>
                </table>
              </li>
              <li class="list-group-item">
                <table>
                  <thead>
                    <tr>
                      <th><label><input type="checkbox" onclick="click_power_menu('mail_mgr', this.checked);">
                          邮件管理</label></th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td><label style="padding-left: 20px"><input type="checkbox" name="sys_mail" class="mail_mgr">
                          后台邮件</label></td>
                    </tr>
                    <tr>
                      <td><label style="padding-left: 20px"><input type="checkbox" name="role_mail" class="mail_mgr">
                          玩家邮件</label></td>
                    </tr>
                  </tbody>
                </table>
              </li>
            </ul>
            <input name="gid" class="hidden">
            <button class="btn btn-lg btn-primary btn-block" type="submit" style="width:200px;margin:auto">修改</button>
          </form>
        </div>
      </div>
    </div><!-- /.modal -->
  </div>
</div>

<script type="text/javascript">

  $(document).ready(function () {
    toastr.options.positionClass = 'toast-top-center';
    $("#form_add_group").submit(function () {
      event.preventDefault();
      $.ajax({
        type: "POST",
        url: "/add_group",
        data: $("#form_add_group").serializeArray(),
        dataType: 'text',
        success: function (msg) {
          toastr.options.positionClass = 'toast-top-center';
          if (msg != "") {
            toastr.error(msg);
            return;
          }
          $('#add_group').modal('hide');
          toastr.success("添加成功！")
          setTimeout("window.location.reload()", 1000)
        }
      });
    })

    $("#form_modify_group").submit(function () {
      event.preventDefault();

      $.ajax({
        type: "POST",
        url: "/modify_group",
        data: $("#form_modify_group").serializeArray(),
        dataType: 'text',
        success: function (msg) {
          toastr.options.positionClass = 'toast-top-center';
          if (msg != "") {
            toastr.error(msg);
            return;
          }
          $('#modify_group').modal('hide');
          toastr.success("修改成功！")
          setTimeout("window.location.reload()", 1000)
        }
      });
    })

    $("#form_set_power").submit(function () {
      event.preventDefault();

      $.ajax({
        type: "POST",
        url: "/set_power",
        data: $("#form_set_power").serializeArray(),
        dataType: 'text',
        success: function (msg) {
          toastr.options.positionClass = 'toast-top-center';
          if (msg != "") {
            toastr.error(msg);
            return;
          }
          $('#modify_group').modal('hide');
          toastr.success("修改成功！")
          setTimeout("window.location.reload()", 1000)
        }
      });
    })
  });

  function on_modify() {
    var checked_list = $("input.group_gid").filter(":checked");
    if (checked_list.length == 0) {
      toastr.error("请先选择一个组");
      return;
    }
    if (checked_list.length > 1) {
      toastr.error("一次只能修改一个");
      return;
    }
    var gid = checked_list.first().attr("gid");
    var tr = checked_list.first().parent().parent();

    $('#modify_group').modal('show')
    $('#form_modify_group').find("[name='name']").val(tr.children("td[name='name']").html());
    $('#form_modify_group').find("[name='info']").val(tr.children("td[name='info']").html());
    $('#form_modify_group').find("[name='gid']").val(gid);
  }

  function on_delete() {
    var checked_list = $("input.group_gid").filter(":checked");
    var gid_list = checked_list.map(function () { return $(this).attr("gid"); }).get();

    if (gid_list.length < 1) { return; }
    $.ajax({
      type: "POST",
      url: "/delete_group",
      data: { "gid_list": JSON.stringify(gid_list) },
      dataType: 'text',
      success: function (msg) {
        toastr.options.positionClass = 'toast-top-center';
        if (msg != "") {
          toastr.error(msg);
          return;
        }
        toastr.success("删除成功！")
        setTimeout("window.location.reload()", 1000)
      }
    });
  }

  function on_set_power() {
    var checked_list = $("input.group_gid").filter(":checked");
    if (checked_list.length == 0) {
      toastr.error("请先选择一个组");
      return;
    }
    if (checked_list.length > 1) {
      toastr.error("一次只能修改一个");
      return;
    }
    var gid = checked_list.first().attr("gid");
    $('#form_set_power').find("[name='gid']").val(gid);
    $.ajax({
      type: "POST",
      url: "/query_group",
      data: { "gid": gid },
      dataType: 'json',
      success: function (msg) {
        toastr.options.positionClass = 'toast-top-center';
        if (msg.err) {
          toastr.error(msg.err);
          return;
        }
        console.log(msg)
        $('#set_power').modal('show')
        $('#form_set_power').find(':checkbox').prop('checked', false);
        console.log($('#form_set_power').find(':checkbox'));
        msg.group.power_list.every(function (x) {
          $('#form_set_power').find("[name='{0}']".format(x)).prop('checked', true);
          return true
        });
      }
    });
  }

  function click_power_menu(menu_name, checked) {
    $('input.' + menu_name).prop("checked", checked);
  }
</script>