% rebase('base.tpl', child='user_mgr', sidemenu='user_mgr', child_css='user_mgr.css')
<div style="width:800px;">
    <nav class="navbar navbar-inverse" role="navigation">
        <div class="container-fluid">
        <div>
            <ul class="nav navbar-nav">
                <li><a href="#" onclick="on_add();">添加</a></li>
                <li><a href="#" onclick="on_modify();">编辑</a></li>
                <li><a href="#" onclick="on_delete();">删除</a></li>
            </ul>
        </div>
        </div>
    </nav>
    <table class="table table-striped">
      <thead>
        <tr>
          <th></th>
          <th>账号</th>
          <th>用户名</th>
          <th>所属组</th>
          <th>创建日期</th>
          <th>修改日期</th>
          <th>状态</th>
        </tr>
      </thead>
      <tbody>
        % for user in all_user:
        <tr>
          <td><input type="checkbox" uid="{{user.uid}}" class="uid"></td>
          <td name="name">{{user.name}}</td>
          <td name="nick">{{user.nick}}</td>
          <td name="group">{{user.group}}</td>
          <td name="create_ts">{{user.create_ts}}</td>
          <td name="modify_ts">{{user.modify_ts}}</td>
          <td name="status">{{user.status}}</td>
        </tr>
        % end
      </tbody>
    </table>
    <div class="modal fade" id="add_user" tabindex="-1" role="dialog">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            <h3 id="add_user_header" class="modal-title">添加用户</h3>
          </div>
          <div class="modal-body">
            <form id="form_add_user" class="form-adduser form-horizontal">
              <div class="form-group">
                <label class="col-sm-2 control-label">账号</label>
                <div class="col-sm-8">
                    <input type="text" name="name" class="form-control" placeholder="输入账号" required autofocus>
                </div>
              </div>
              <div class="form-group">
                <label class="col-sm-2 control-label">用户名</label>
                <div class="col-sm-8">
                    <input type="text" name="nick" class="form-control" placeholder="输入用户名" required autofocus>
                </div>
              </div>
              <div class="form-group">
                <label class="col-sm-2 control-label">密码</label>
                <div class="col-sm-8">
                    <input type="password" name="pwd" class="form-control" placeholder="输入密码" autofocus>
                </div>
              </div>
              <div class="form-group">
                <label class="col-sm-2 control-label">所属组</label>
                <div class="col-sm-8">
                    <select class="form-control required" name="group_name">
                        % for group in all_group:
                        <option>{{group.name}}</option> 
                        % end
                    </select>
                </div>
              </div>
              <div class="form-group">
                <label class="col-sm-2 control-label">状态</label>
                <div class="col-sm-8">
                    <select class="form-control required" name="status">
                        % for status in all_status:
                        <option>{{status}}</option> 
                        % end
                    </select>
                </div>
              </div>
              <input name="uid" class="hidden">
              <button id="add_user_submit" class="btn btn-lg btn-primary btn-block" type="submit" style="width:200px;margin:auto">添加</button>
            </form>
          </div>
        </div>
      </div><!-- /.modal -->
    </div>
</div>
<script type="text/javascript">
    $(document).ready( function(){
        toastr.options.positionClass = 'toast-top-center';
        $("#form_add_user").submit(function(){
            event.preventDefault();

            if($('#add_user_submit').html() == "修改") {
                $.ajax({  
                   type: "POST",  
                   url: "/modify_user",  
                   data: $("#form_add_user").serializeArray(),  
                   dataType: 'text',
                   success: function(msg){
                      toastr.options.positionClass = 'toast-top-center';
                      if(msg) {
                        toastr.error(msg);
                        return;
                      }
                      $('#add_user').modal('hide');
                      toastr.success("修改成功！")
                      setTimeout("window.location.reload()", 1000)
                   }
                });  
            }
            else {
                $.ajax({  
                   type: "POST",  
                   url: "/add_user",  
                   data: $("#form_add_user").serializeArray(),  
                   dataType: 'text',
                   success: function(msg){
                      toastr.options.positionClass = 'toast-top-center';
                      if(msg) {
                        toastr.error(msg);
                        return;
                      }
                      $('#add_user').modal('hide');
                      toastr.success("添加成功！")
                      setTimeout("window.location.reload()", 1000)
                   }
                });  
            } 
        })
    })
    function on_add() {
        $('#add_user').modal('show');
        $('#add_user_header').html("添加用户")
        $('#add_user_submit').html("添加")
        $('#form_add_user').find("input").val("");
        $('#form_add_user').find("[name='pwd']").prop("placeholder", "输入密码");
        $('#form_add_user').find("select").prop("selectedIndex", 0)
    }
    function on_modify() {
        var checked_list = $("input.uid").filter(":checked");
        if(checked_list.length == 0) {
            toastr.error("请先选择一个用户");
            return;
        }
        if(checked_list.length > 1) {
            toastr.error("一次只能修改一个");
            return;
        }

        $('#add_user').modal('show');
        $('#add_user_header').html("修改用户")
        $('#add_user_submit').html("修改")
        $('#form_add_user').find("input").val("");
        $('#form_add_user').find("select").prop("selectedIndex", 0)

        var uid = checked_list.first().attr("uid");
        var tr = checked_list.first().parent().parent();
        $('#form_add_user').find("[name='name']").val(tr.children("td[name='name']").html());
        $('#form_add_user').find("[name='nick']").val(tr.children("td[name='nick']").html());
        $('#form_add_user').find("[name='pwd']").prop("placeholder", "输入新密码，留空表示不修改");
        $('#form_add_user').find("[name='group_name']").val(tr.children("td[name='group']").html());
        $('#form_add_user').find("[name='status']").val(tr.children("td[name='status']").html());
        $('#form_add_user').find("[name='uid']").val(uid);

    }
    function on_delete() {
        var checked_list = $("input.uid").filter(":checked");
        var uid_list = checked_list.map(function(){return $(this).attr("uid");}).get();
        
        if(uid_list.length < 1) { return; }
        $.ajax({  
            type: "POST",  
            url: "/delete_user",  
            data: {"uid_list":JSON.stringify(uid_list)},  
            dataType: 'text',
            success: function(msg){
              toastr.options.positionClass = 'toast-top-center';
              if(msg != "") {
                toastr.error(msg);
                return;
              }
              toastr.success("删除成功！")
              setTimeout("window.location.reload()", 1000)
            }
        });
    }
</script>
