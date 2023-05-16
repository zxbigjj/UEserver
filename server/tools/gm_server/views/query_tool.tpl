% rebase('base.tpl', child='query_tool', sidemenu='other_mgr')
<link href="static/datetimepicker/css/bootstrap-datetimepicker.css" rel="stylesheet">
<script src="static/datetimepicker/js/bootstrap-datetimepicker.js"></script>
<script src="static/datetimepicker/js/bootstrap-datetimepicker.zh-CN.js"></script>

<link rel="stylesheet" href="static/bootstrap-table/bootstrap-table.min.css">
<script src="static/bootstrap-table/bootstrap-table.min.js"></script>


<!-- 窗口1 -->
<div class="panel panel-default">
    <div class="panel-heading">
        <h3 class="panel-title">Query Tool</h3>
    </div>

    <div class="panel-body">
        <form class="form-horizontal" id="query_tool_msg">
            <div class="form-group">
                <div class="col-sm-12">
                    <input type="text" class="form-control" required="required" placeholder="Server ID">
                </div>
            </div>

            <div class="form-group">
                <div class="col-sm-12">
                    <textarea style="resize: none;" class="form-control" rows="5" placeholder="SQL"></textarea>
                </div>
            </div>
            <div class="form-group">
                <div class="col-sm-offset-5">
                    <button type="submit" class="btn btn-primary"
                        style="padding-left: 30px; padding-right: 30px">Find</button>
                </div>
            </div>
        </form>
    </div>

    <div class="panel-foot" id="db_info_panel">
    </div>
</div>


<script class="text/javascript">

    $("#query_tool_msg").submit(function () {
        event.preventDefault();
        $("#db_info_panel").empty();
        $("#db_info_panel").append('<table id="db_info"></table>');

        var server_id = $("#query_tool_msg").find("input").val();
        var query_tool_msg = $("#query_tool_msg").find("textarea").val();
        $.ajax({
            type: "post",
            url: "/query_by_sql",
            data: { server_id: server_id, query_tool_msg: query_tool_msg },
            dataType: "json",
            success: function (msg) {
                toastr.options.positionClass = 'toast-top-center';
                if (msg.err) {
                    toastr.error(msg.err);
                    return;
                }
                toastr.success("Successful")
                $("#db_info").bootstrapTable({
                    toolbar: "#toolbar",
                    striped: true,
                    cache: false,
                    data: msg.info,
                    columns: msg.title_list,
                    pagination: true,
                    pageNumber: 1,
                    sidePagination: 'client',
                    // pageList: [5, 10, 20],
                    pageSize: 5,
                    height: 700
                });
            }
        });
    })
</script>