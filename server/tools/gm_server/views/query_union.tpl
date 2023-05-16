% rebase('base.tpl', child='query_union', sidemenu='other_mgr')
<link href="static/datetimepicker/css/bootstrap-datetimepicker.css" rel="stylesheet">
<script src="static/datetimepicker/js/bootstrap-datetimepicker.js"></script>
<script src="static/datetimepicker/js/bootstrap-datetimepicker.zh-CN.js"></script>

<link rel="stylesheet" href="static/bootstrap-table/bootstrap-table.min.css">
<script src="static/bootstrap-table/bootstrap-table.min.js"></script>
<script src="https://www.itxst.com/package/bootstrap-table-1.15.3/bootstrap-table-1.15.3/bootstrap-table.js"></script>


<!-- 窗口1 -->
<div class="panel panel-default">
    <div class="panel-heading">
        <h3>王朝查询</h3>
    </div>

    <div class="panel-body">
        <form id="query_dynasty" method="POST" class="form-horizontal" role="form">
            <div class="form-group">
                <label for="server_id" class="col-sm-1 control-label">服务器ID</label>
                <div class="col-sm-2">
                    <input type="text" class="form-control" id="server_id" required="required">
                </div>

                <label for="dynasty_name" class="col-sm-1 control-label">王朝名字</label>
                <div class="col-sm-2">
                    <input type="text" class="form-control" id="dynasty_name" required="required"
                        placeholder="请输入至少3个字符">
                </div>
            </div>

            <div class="form-group">
                <div class="col-sm-offset-3">
                    <button id="query_dynasty_btn" type="submit" class="btn btn-primary"
                        style="padding-left: 30px; padding-right: 30px">查询</button>
                </div>
            </div>
        </form>
    </div>

    <div class="panel-footer" id="dynasty_info_panel">
    </div>
</div>


<!-- 窗口2 -->
<div class="modal fade" id="set_dynasty_info_model" data-backdrop tabindex="-1" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title">添加经验</h4>
            </div>

            <div class="modal-body">
                <form class="form-horizontal" id="set_dynasty_info_form">
                    <div class="form-group">
                        <p class="col-sm-2">EXP</p>
                        <div class="col-sm-10 ">
                            <input type="text" class="form-control" id="dynasty_exp">
                        </div>
                    </div>

                    <div class="form-group">
                        <button class="btn btn-lg btn-primary btn-block" type="submit">
                            添加王朝经验</button>
                    </div>
                </form>
            </div>
        </div>
    </div><!-- /.modal -->
</div>


<script>
    function addFunctionAlty(value, row, index) {
        return [
            '<button id="set_dynasty_info_btn" type="button" class="btn btn-default" style="width:90px;margin:auto">管理</button>',
        ].join('');
    }

    window.operateEvents = {
        "click #set_dynasty_info_btn": function (e, value, row, index) {
            console.log(row,index);
            $("#set_dynasty_info_model").modal("show")
            $("#set_dynasty_info_model").unbind("submit")
            $("#set_dynasty_info_form").submit(function () {
                event.preventDefault();
                var server_id = $("#query_dynasty").find("#server_id").val();
                var dynasty_exp = $("#set_dynasty_info_form").find("#dynasty_exp").val();
                $.ajax({
                    url: "/set_dynasty_info",
                    type: "post",
                    data: { server_id: server_id, uuid: "", dynasty_id: row.dynasty_id, dynasty_exp: dynasty_exp },
                    success: function (msg) {
                        console.log(msg);
                        toastr.options.positionClass = "toast-top-center";
                        if (msg.err) { toastr.error(msg.err); return }
                        $("#set_dynasty_info_model").modal("hide")
                        toastr.success("操作成功");
                        // $("#query_dynasty_btn").click();
                        $("#dynasty_info_table").bootstrapTable('updateCell', {
                            index: 0,
                            field: "dynasty_exp",
                            value: parseInt(row.dynasty_exp) + parseInt(dynasty_exp)
                        });
                    }
                });
            })
        }
    }

    $(document).ready(function () {
        $("#query_dynasty").submit(function () {
            event.preventDefault();
            $('#dynasty_info_panel').empty();
            $('#dynasty_info_panel').append('<table id="dynasty_info_table"></table>');

            var server_id = $("#query_dynasty").find("#server_id").val();
            var dynasty_name = $("#query_dynasty").find("#dynasty_name").val();
            console.log(server_id, dynasty_name);
            $.ajax({
                type: "post",
                url: "/query_dynasty_info",
                data: { server_id: server_id, dynasty_name: dynasty_name },
                success: function (msg) {
                    toastr.options.positionClass = "toast-top-center";
                    if (msg.err) { toastr.error(msg.err); return }
                    console.log(msg);
                    $("#dynasty_info_table").bootstrapTable({
                        striped: true,
                        cache: false,
                        data: msg.info,
                        columns: [{
                            checkbox: true,
                        }, {
                            field: "dynasty_id",
                            title: "ID"
                        }, {
                            field: "dynasty_name",
                            title: "名字"
                        }, {
                            field: "dynasty_exp",
                            title: "经验"
                        }, {
                            field: "godfather_name",
                            title: "教父"
                        }, {
                            field: "member_count",
                            title: "成员"
                        }, {
                            field: "dynasty_score",
                            title: "战力"
                        }, {
                            field: "operate",
                            title: "管理",
                            events: operateEvents,
                            formatter: addFunctionAlty
                        }]
                    })
                },
            })
        })
    })
</script>


<!-- 其他组件 -->
<script>
</script>