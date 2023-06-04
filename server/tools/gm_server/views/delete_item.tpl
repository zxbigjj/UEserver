% rebase('base.tpl', child='delete_item', sidemenu='player_mgr')
<link href="static/datetimepicker/css/bootstrap-datetimepicker.css" rel="stylesheet">
<script src="static/datetimepicker/js/bootstrap-datetimepicker.js"></script>
<script src="static/datetimepicker/js/bootstrap-datetimepicker.zh-CN.js"></script>



<div class="panel panel-default">
    <div class="panel-heading">
        <h3 class="panel-title">
            删除道具
        </h3>
    </div>
    <div class="panel-body">
        <form class="form-horizontal" role="form" id="delete_item_from">
            
            <div class="form-group" >
                        <p class="col-sm-2">服务器ID</p>
                        <div class="col-sm-10" >
                            <select class="form-control" id="server_id">
                                
                            </select>
                        </div>
                    </div>
            <div class="form-group">
                <p class="col-sm-2">UUID</p>
                <div class="col-sm-10 ">
                    <input type="text" class="form-control" id="uuid">
                </div>
            </div>

            <div class="form-group">
                <p class="col-sm-2">角色名称</p>
                <div class="col-sm-10 ">
                    <input type="text" class="form-control" id="name">
                </div>
            </div>

            <div class="form-group">
                <p class="col-sm-2">道具ID</p>
                <div class="col-sm-10 ">
                    <input type="text" class="form-control" id="item_id">
                </div>
            </div>
            <div class="form-group">
                <p class="col-sm-2">道具数量</p>
                <div class="col-sm-10 ">
                    <input type="text" class="form-control" id="item_count">
                </div>
            </div>

            <div class="form-group">
                <div class="col-sm-10 col-sm-offset-2">
                    <button type="submit" class="btn btn-primary"
                        style="padding-left: 30px; padding-right: 30px">删除</button>
                </div>
            </div>
        </form>

    </div>
    <!-- <div class="panel-footer">
        Panel footer
    </div> -->
</div>

<script>
    $(document).ready(function () {
        $.ajax({
      type: "POST",
      url: "/query_zone",
      dataType: 'json',
      success: function (msg) {
        console.log(msg)
        $.each(msg.info, function (key, values) {
          if (values.running_state) {
          $("#server_id").append("<option>" + values.server_id + "</option>");
          }
        })
      }
    });
    })
    $(document).ready(function () {
        $("#delete_item_from").submit(function () {
            event.preventDefault();

            var server_id = $("#delete_item_from").find("#server_id").val();
            var uuid = $("#delete_item_from").find("#uuid").val();
            var name = $("#delete_item_from").find("#name").val();
            var item_id = $("#delete_item_from").find("#item_id").val();
            var item_count = $("#delete_item_from").find("#item_count").val();
            console.log(server_id, uuid, item_id, item_count, name);

            $.ajax({
                type: "POST",
                url: "/role_delete_item",
                data: { server_id: server_id, uuid: uuid, item_id: item_id, item_count: item_count, name: name },
                success: function (msg) {
                    toastr.options.positionClass = 'toast-top-center';
                    if (msg.err) {
                        toastr.error(msg.err);
                        return;
                    }
                    toastr.success("操作成功");
                }
            })
        })
    })
</script>