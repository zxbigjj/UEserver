% rebase('base.tpl', child='map_mgr', sidemenu='other_mgr')
<link href="static/datetimepicker/css/bootstrap-datetimepicker.css" rel="stylesheet">
<script src="static/datetimepicker/js/bootstrap-datetimepicker.js"></script>
<script src="static/datetimepicker/js/bootstrap-datetimepicker.zh-CN.js"></script>


<div class="panel panel-default">
    <div class="panel-heading">
        <h3 class="panel-title">开启地图</h3>
    </div>
    <div class="panel-body">
        <form class="form-horizontal" role="form" id="role_map_mgr">
            <div class="form-group">
                <p class="col-sm-2">服务器ID</p>
                <input id="server_id" type="text" class="form-control">
            </div>
            <div class="form-group">
                <p class="col-sm-2">角色ID</p>
                <input id="uuid" type="text" class="form-control">
            </div>
            <div class="form-group">
                <p class="col-sm-2">关卡ID</p>
                <input id="stage_id" type="text" class="form-control">
            </div>
            <div class="form-group">
                <div class="col-sm-10 col-sm-offset-2">
                    <button type="submit" class="btn btn-primary">开启关卡</button>
                </div>
            </div>
        </form>
    </div>
</div>

<script>
    $(document).ready(function () {
        $("#role_map_mgr").submit(function () {
            event.preventDefault();
            var uuid = $("#uuid").val();
            var server_id = $("#server_id").val();
            var stage_id = $("#stage_id").val();
            console.log(uuid, server_id, stage_id);

            $.ajax({
                type: "post",
                url: "/set_role_stage_to",
                data: { server_id: server_id, uuid: uuid, stage_id: stage_id },
                success: function (msg) {
                    console.log(msg)
                    toastr.options.positionClass = 'toast-top-center';
                    if (msg.err) {
                        toastr.error("操作失败");
                        return;
                    }
                    toastr.success("操作成功")
                }
            });
        });
    });
</script>