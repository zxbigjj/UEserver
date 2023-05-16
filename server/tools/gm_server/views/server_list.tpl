% rebase('base.tpl', child='server_list', sidemenu='player_mgr')
<link href="static/datetimepicker/css/bootstrap-datetimepicker.css" rel="stylesheet">
<script src="static/datetimepicker/js/bootstrap-datetimepicker.js"></script>
<script src="static/datetimepicker/js/bootstrap-datetimepicker.zh-CN.js"></script>

<link rel="stylesheet" href="static/bootstrap-table/bootstrap-table.min.css">
<script src="static/bootstrap-table/bootstrap-table.min.js"></script>


<!-- 窗口1 -->
<div class="panel panel-default">
    <div class="panel-heading">
        <h3 class="panel-title">服务器列表</h3>
    </div>
    <!-- <button type="button" class="btn btn-warning navbar-btn" style="padding-left: 30px; padding-right: 30px"
        onclick="add_game_server();">添加服务器</button>
    <div>
        <h4 class="col-sm-4">49.232.87.206</h4>
    </div>

    <div class="btn-group">
        <button type="button" class="btn btn-warning navbar-btn" style="padding-left: 30px; padding-right: 30px;"
            onclick="make_game_server_lua();">生成文件</button>
        <button id="start_server" type="button" class="btn btn-warning navbar-btn"
            style="padding-left: 30px; padding-right: 30px" onclick="start_selected_game_server();">开启</button>
    </div> -->

    <!-- <div class="panel-body">
        <form class="form-horizontal">
            <div class="from-group" id="lua_server_list"></div>
        </form>
    </div> -->

    <div class="panel-body">
        <table id="server_list_tb"></table>
    </div>
</div>


<!-- 窗口2 -->
<!-- <div class="modal fade" id="add_game_server_modal" data-backdrop tabindex="-1" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title">服务器信息</h4>
            </div>

            <div class="modal-body">
                <form class="form-horizontal" id="add_game_server_form">
                    <div class="form-group" id="name">
                        <input type="text" class="form-control" placeholder="name" required="required">
                    </div>

                    <div class="form-group" id="type">
                        <input type="text" class="form-control" placeholder="type" required="required">
                    </div>

                    <div class="form-group" id="server_id">
                        <input type="text" class="form-control" placeholder="server_id" required="required">
                    </div>

                    <div class="form-group" id="ip">
                        <input type="text" class="form-control" placeholder="ip" required="required">
                    </div>

                    <div class="form-group" id="area_id">
                        <input type="text" class="form-control" placeholder="area_id" required="required">
                    </div>

                    <div class="form-group" id="area_name">
                        <input type="text" class="form-control" placeholder="area_name" required="required">
                    </div>

                    <div class="form-group" id="open_time">
                        <input type="text" class="form-control form_date">
                    </div>

                    <div class="form-group" id="allow_login">
                        <input type="text" class="form-control" placeholder="allow_login" required="required">
                    </div>

                    <div class="form-group" id="enable_ssl">
                        <input type="text" class="form-control" placeholder="enable_ssl" required="required">
                    </div>

                    <div class="form-group" id="state">
                        <input type="text" class="form-control" placeholder="state" required="required">
                    </div>

                    <div class="form-group" id="recommend_status">
                        <input type="text" class="form-control" placeholder="recommend_status" required="required">
                    </div>

                    <div class="form-group" id="recommend_priority">
                        <input type="text" class="form-control" placeholder="recommend_priority" required="required">
                    </div>

                    <div class="form-group" id="cross_server_id">
                        <input type="text" class="form-control" placeholder="cross_server_id">
                    </div>

                    <div class="form-group">
                        <button type="submit" class="btn btn-primary col-sm-offset-4"
                            style="padding-left: 30px; padding-right: 30px">添加</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div> -->


<!-- 浮动窗口 -->
<!-- <div class="modal fade" id="show_log" tabindex="-1" role="dialog">
    <div class="modal-dialog" style="width:800px">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h3 class="modal-title">操作结果</h3>
            </div>
            <div id="log_area" class="modal-body">
            </div>
        </div>
    </div>
</div> -->


<!-- 时间组件初始化 -->
<script type="text/javascript">
    $(document).ready(function () {
        $('.form_date').datetimepicker({
            language: 'en-US',
            todayBtn: true,
            autoclose: true,
            format: "yyyy-mm-dd hh:mm:ss",
        });
    });
</script>

<script>
    $(document).ready(function () {
        $.ajax({
            type: "get",
            url: "/query_server_list",
            dataType: 'json',
            success: function (msg) {
                console.log(msg);
                $("#server_list_tb").bootstrapTable({
                    striped: true,
                    cache: false,
                    data: msg.info,
                    columns: [{
                        title: '服务器ID',
                        field: 'server_id',
                    }, {
                        title: '服务器名',
                        field: 'name',
                    }, {
                        title: '区名',
                        field: 'area_name',
                    }, {
                        title: '开启时间',
                        field: 'open_time',
                    }, {
                        title: 'IP',
                        field: 'ip',
                    }, {
                        title: '状态',
                        field: 'running_state',
                        formatter: function (value, row, index) {
                            if (value == 1) { return '开启' }
                            else { return '关闭' }
                        }
                    }, {
                        title: '在线人数',
                        field: 'role_online_num',
                    }, {
                        title: '注册人数',
                        field: 'role_total_num',
                    }],
                })
            }
        });
    });
</script>

<!-- <script>
    function add_game_server() {
        $('#add_game_server_modal').modal('show')
        $('#add_game_server_modal').unbind('submit')
        $('#add_game_server_form').submit(function () {
            event.preventDefault();
            var name = $('#name').find('input').val();
            var type = $('#type').find('input').val();
            var server_id = $('#server_id').find('input').val();
            var ip = $('#ip').find('input').val();
            var area_id = $('#area_id').find('input').val();
            var area_name = $('#area_name').find('input').val();
            var open_time = $('#open_time').find('input').val();
            var allow_login = $('#allow_login').find('input').val();
            var enable_ssl = $('#enable_ssl').find('input').val();
            var state = $('#state').find('input').val();
            var recommend_status = $('#recommend_status').find('input').val();
            var recommend_priority = $('#recommend_priority').find('input').val();
            var cross_server_id = $('#cross_server_id').find('input').val();

            $.ajax({
                url: "/add_in_server_list",
                type: "post",
                dataType: "json",
                data: {
                    name: name,
                    type: type,
                    server_id: server_id,
                    ip: ip,
                    area_id: area_id,
                    area_name: area_name,
                    open_time: open_time,
                    allow_login: allow_login,
                    enable_ssl: enable_ssl,
                    state: state,
                    recommend_status: recommend_status,
                    recommend_priority: recommend_priority,
                    cross_server_id: cross_server_id,
                },
                success: function (msg) {
                    toastr.options.positionClass = 'toast-top-center';
                    if (msg.err) {
                        toastr.error(msg.err);
                        return;
                    }
                    toastr.success("添加成功");
                    window.location.reload();
                }
            })
        })
    }

    function make_game_server_lua() {
        $.ajax({
            url: '/make_game_server_lua',
            type: 'get',
            success: function (msg) {
                toastr.options.positionClass = 'toast-top-center';
                if (msg.err) {
                    toastr.error(msg.err);
                    return;
                }
                toastr.success("生成成功");
                window.location.reload();
            }
        })
    }

    function start_selected_game_server() {
        var game_server_list = JSON.stringify($("#db_server_list").bootstrapTable("getSelections"));
        $.ajax({
            url: '/start_selected_server_list',
            type: 'post',
            dataType: 'json',
            data: { game_server_list: game_server_list, },
            success: function (msg) {
                toastr.options.positionClass = 'toast-top-center';
                if (msg.err) {
                    toastr.error(msg.err);
                    return;
                }
                // $('#show_log').modal('show')
                // $('#log_area').find('p').remove()
                // fetch_log(server_id)
                toastr.success("操作成功");
            }
        })
    }
</script> -->

<!-- <script>
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
</script> -->