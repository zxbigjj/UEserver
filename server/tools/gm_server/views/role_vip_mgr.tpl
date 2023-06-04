% rebase('base.tpl', child='role_vip_mgr', sidemenu='other_mgr')
<link href="static/datetimepicker/css/bootstrap-datetimepicker.css" rel="stylesheet">
<script src="static/datetimepicker/js/bootstrap-datetimepicker.js"></script>
<script src="static/datetimepicker/js/bootstrap-datetimepicker.zh-CN.js"></script>


<!-- 窗口1 -->
<div class="panel panel-default">
    <div class="panel-heading">
        <h3 class="panel-title">角色VIP</h3>
    </div>

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

                <label for="role_name" class="col-sm-1 control-label">VIP等级</label>
                <div class="col-sm-2">
                    <input type="text" class="form-control" id="vip_level" required="required">
                </div>
            </div>
        </form>
    </div>
</div>

<div class="panel panel-default">
    <div class="panel-body">
        <ul class="nav nav-pills" id="set_button">
            <button type="button" class="btn btn-warning navbar-btn" style="padding-left: 30px; padding-right: 30px"
                onclick="set_role_vip();">设置Vip等级</button>
        </ul>
    </div>
</div>


<!-- 查询角色 -->
<script type="text/javascript">
  var zone_list;

  /********************大区,服务器部分********************/
  function on_zone_change() {
    $("#server").find("option").remove()
    var area_name = $("#zone").val()
    $.each(zone_list, function (key, values) {
      
      var zone = values;
      console.log(values.server_id)
      if (zone.area_name == area_name) {
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
          if ( values.running_state) {
          $("#zone").append("<option>" + values.area_name + "</option>");
          }
        })
        
        on_zone_change();
      }
    });
  })

$("#zone").change(on_zone_change);

</script>


<!-- 控件2 -->
<script>
    function set_role_vip() {
        var server_id = $("#server").find(":selected").attr("server_id");
        var uuid = $("#query_player").find("#uid").val();
        var vip_level = $("#query_player").find("#vip_level").val();
        console.log(uuid, server_id, vip_level)
        $.ajax({
            type: 'post',
            url: '/set_role_vip',
            data: { uuid: uuid, server_id: server_id, vip_level: vip_level, },
            success: function (msg) {
                console.log(msg);
                toastr.options.positionClass = 'toast-top-center';
                if (msg.err) {
                    toastr.error(msg.err);
                    return;
                }
                toastr.success('操作成功');
            }
        })
    }
</script>