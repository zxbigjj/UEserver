% rebase('base.tpl', child='level_query', sidemenu='player_mgr')
<link href="static/datetimepicker/css/bootstrap-datetimepicker.css" rel="stylesheet">
<script src="static/datetimepicker/js/bootstrap-datetimepicker.js"></script>
<script src="static/datetimepicker/js/bootstrap-datetimepicker.zh-CN.js"></script>

<div class="panel panel-default">
    <div class="panel-heading">修改角色经验、等级</div>
    <div class="panel-body">
        <form class="form-horizontal" id="query_player">
            <div class="form-group">
                <label for="zone" class="col-sm-1 control-label">大区</label>
                <div class="col-sm-2">
                    <select class="form-control required" id="zone">
                    </select>
                </div>

                <label for="server" class="col-sm-1 control-label">服务器</label>
                <div class="col-sm-2">
                    <select class="form-control required" id="server">
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label for="uid" class="col-sm-1 control-label">角色id</label>
                <div class="col-sm-2">
                    <input type="text" class="form-control" id="uid" required="required" placeholder="优先使用角色id查询">
                </div>

                <label for="role_name" class="col-sm-1 control-label">角色名字</label>
                <div class="col-sm-2">
                    <input type="text" class="form-control" id="" placeholder="选填">
                </div>
            </div>
        </form>
    </div>
</div>

<div class="panel panel-default">
    <div class="panel-body">
        <ul class="nav nav-pills" id="set_button">
            <button type="button" class="btn btn-warning navbar-btn" onclick="set_role_level();">修改等级</button>
            <button type="button" class="btn btn-warning navbar-btn" onclick="add_role_exp();">增加经验</button>
            <button type="button" class="btn btn-warning navbar-btn" onclick="delete_role_exp();">减少经验</button>
        </ul>


        <table class="table table-striped">
            <thead>
                <tr>
                    <th style="width: 33%"></th>
                    <th style="width: 33%"></th>
                    <th style="width: 33%"></th>
                </tr>
            </thead>
            <tbody id="query_result" class="hidden">
                <tr>
                    <td>ID：<label id="uuid"></label></td>
                    <td>经验：<lable id="exp"></lable>
                    </td>
                    <td>等级：<lable id="level"></lable>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</div>


<!-- 窗口2 -->
<div class="modal fade" id="set_role_level" tabindex="-1" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h3 id="set_role_level_header" class="modal-title">修改等级</h3>
            </div>
            <div class="modal-body">
                <form id="form_set_role_level" class="form-horizontal">
                    <div class="form-group">
                        <input type="text" id="inner_set_role_level" class="form-control" placeholder="请输入等级" required>
                        <input type="hidden" id="dtp_input1" value="" /><br />
                    </div>
                    <button class="btn btn-lg btn-primary btn-block" type="submit"
                        style="width:120px;margin:auto">修改等级</button>
                </form>
            </div>
        </div>
    </div><!-- /.modal -->
</div>
</div>

<div class="modal fade" id="add_role_exp" tabindex="-1" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h3 id="add_role_exp_header" class="modal-title">增加经验</h3>
            </div>
            <div class="modal-body">
                <form id="form_add_role_exp" class="form-horizontal">
                    <div class="form-group">
                        <input type="text" id="inner_add_role_exp" class="form-control" placeholder="请输入经验" required>
                        <input type="hidden" id="dtp_input1" value="" /><br />
                    </div>
                    <button class="btn btn-lg btn-primary btn-block" type="submit"
                        style="width:120px;margin:auto">增加经验</button>
                </form>
            </div>
        </div>
    </div><!-- /.modal -->
</div>
</div>

<div class="modal fade" id="delete_role_exp" tabindex="-1" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h3 id="delete_role_exp_header" class="modal-title">减少经验</h3>
            </div>
            <div class="modal-body">
                <form id="form_delete_role_exp" class="form-horizontal">
                    <div class="form-group">
                        <input type="text" id="inner_delete_role_exp" class="form-control" placeholder="请输入经验" required>
                        <input type="hidden" id="dtp_input1" value="" /><br />
                    </div>
                    <button class="btn btn-lg btn-primary btn-block" type="submit"
                        style="width:120px;margin:auto">减少经验</button>
                </form>
            </div>
        </div>
    </div><!-- /.modal -->
</div>
</div>





<!-- 初始化设置 -->
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


<!-- 查询角色 -->
<script type="text/javascript">
  var zone_list;

  /********************大区,服务器部分********************/
  function on_zone_change() {
    $("#server").find("option").remove()
    var name = $("#zone").val()
    
    $.each(zone_list, function (key, values) {
      
      var zone = values;
      console.log(values.server_id)
      if (zone.name == name) {
        var option = '<option server_id="' + zone.server_id + '">' + zone.server_id + "</option>"
        $("#server").append(option);
      }
    })
  }

  //全局加载
  $(document).ready(function () {
    $.ajax({
      type: "POST",
      url: "/query_zone",
      dataType: 'json',
      success: function (msg) {
        console.log(msg)
        zone_list=msg.info
        $.each(msg.info, function (key, values) {
          if (zone.name == name && values.running_state) {
          $("#zone").append("<option>" + values.name + "</option>");
          }
        })
        
        on_zone_change();
      }
    });
  })

$("#zone").change(on_zone_change);

</script>



<!-- 窗口2 -->
<script type="text/javascript">
    function set_role_level() {
        var uuid = $("#query_player").find("#uid").val();
        var server_id = $("#server").find(":selected").attr("server_id");
        console.log(uuid, server_id)

        $('#set_role_level').modal('show')
        $('#form_set_role_level').unbind('submit');
        $('#form_set_role_level').submit(function () {
            event.preventDefault()
            var set_role_level = $("#inner_set_role_level").val();
            $.ajax({
                type: "POST",
                url: "/set_role_level",
                data: { server_id: server_id, uuid: uuid, level: set_role_level },
                dataType: 'json',
                success: function (msg) {
                    toastr.options.positionClass = 'toast-top-center';
                    if (msg.err) {
                        toastr.error(msg.err);
                        return;
                    }
                    toastr.success("操作成功")
                    $("#query_result").removeClass('hidden')
                    $("#query_result").find("#uuid").html(uuid);
                    $("#query_result").find("#level").html(msg.info.level);
                    $("#query_result").find("#exp").html(msg.info.exp);
                    $('#form_set_role_level')[0].reset() //cal Dom's reset
                    $('#set_role_level').modal('hide')
                }
            });
        })
    }


    function add_role_exp() {
        var uuid = $("#query_player").find("#uid").val();
        var server_id = $("#server").find(":selected").attr("server_id");
        console.log(uuid, server_id)

        $('#add_role_exp').modal('show')
        $('#form_add_role_exp').unbind('submit');
        $('#form_add_role_exp').submit(function () {
            event.preventDefault()
            var add_role_exp = $("#inner_add_role_exp").val();
            $.ajax({
                type: "POST",
                url: "/add_role_exp",
                data: { uuid: uuid, server_id: server_id, exp: add_role_exp },
                dataType: 'json',
                success: function (msg) {
                    toastr.options.positionClass = 'toast-top-center';
                    if (msg.err) {
                        toastr.error(msg.err);
                        return;
                    }
                    toastr.success("操作成功")
                    $("#query_result").removeClass('hidden')
                    $("#query_result").find("#uuid").html(uuid);
                    $("#query_result").find("#level").html(msg.info.level);
                    $("#query_result").find("#exp").html(msg.info.exp);
                    $('#form_add_role_exp')[0].reset() // cal Dom's reset
                    $('#add_role_exp').modal('hide')
                }
            });
        })
    }


    function delete_role_exp() {
        var uuid = $("#query_player").find("#uid").val();
        var server_id = $("#server").find(":selected").attr("server_id");
        console.log(uuid, server_id)

        $('#delete_role_exp').modal('show')
        $('#form_delete_role_exp').unbind('submit');
        $('#form_delete_role_exp').submit(function () {
            event.preventDefault()
            var delete_role_exp = $("#inner_delete_role_exp").val();
            $.ajax({
                type: "POST",
                url: "/delete_role_exp",
                data: { uuid: uuid, server_id: server_id, exp: delete_role_exp },
                dataType: 'json',
                success: function (msg) {
                    toastr.options.positionClass = 'toast-top-center';
                    if (msg.err) {
                        toastr.error(msg.err);
                        return;
                    }
                    toastr.success("操作成功")
                    $("#query_result").removeClass('hidden')
                    $("#query_result").find("#uuid").html(uuid);
                    $("#query_result").find("#level").html(msg.info.level);
                    $("#query_result").find("#exp").html(msg.info.exp);
                    $('#form_delete_role_exp')[0].reset() // cal Dom's reset
                    $('#delete_role_exp').modal('hide')
                }
            });

        })
    }
</script>