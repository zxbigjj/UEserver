% rebase('base.tpl', child='online_notify', sidemenu='notify_mgr')
<link href="static/datetimepicker/css/bootstrap-datetimepicker.css" rel="stylesheet">
<script src="static/datetimepicker/js/bootstrap-datetimepicker.js"></script>
<script src="static/datetimepicker/js/bootstrap-datetimepicker.zh-CN.js"></script>


<div class="panel panel-default">
    <div class="panel-heading">查询游戏内跑马灯公告</div>
    <div class="panel-body">
        <form class="form-horizontal" id="roll_notice">
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
                <div class="col-sm-offset-3">
                    <button id="query_submit" type="submit" class="btn btn-primary"
                        style="padding-left: 30px; padding-right: 30px">查询</button>
                </div>
            </div>
        </form>
    </div>
</div>


<div class="panel panel-default">
    <div class="panel-heading">
        <p>查询结果</p>
    </div>

    <div class="panel-body">
        <ul class="nav nav-pills">
            <button type="button" class="btn btn-warning navbar-btn" onclick="add_roll_notice();">添 加</button>
            <button type="button" class="btn btn-warning navbar-btn" onclick="edit_roll_notice();">修 改</button>
            <button type="button" class="btn btn-warning navbar-btn" onclick="delete_roll_notice();">删 除</button>
        </ul>


        <table class="table table-striped">
            <thead>
                <tr>
                    <th style="width: 30%"></th>
                    <th style="width: 20%"></th>
                    <th style="width: 20%"></th>
                    <th style="width: 15%"></th>
                    <th style="width: 15%"></th>
                </tr>
            </thead>
            <tbody id="roll_notice_result">

            </tbody>
        </table>
        </table>
    </div>
</div>


<!-- 窗口2 -->
<div class="modal fade" id="add_roll_notice" tabindex="-1" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h3 id="add_roll_noticeheader" class="modal-title">添加</h3>
            </div>
            <div class="modal-body">
                <form id="form_add_roll_notice" class="form-horizontal">
                    <div class="form-group">
                        <input type="text" id="inner_add_roll_notice_content" class="form-control" placeholder="添加内容">

                        <div class="input-group date form_date form-control" id="inner_add_roll_notice_start_ts"
                            data-date="" data-date-format="yyyy/m/d hh:00" data-link-field="dtp_input1"
                            data-link-format="yyyy-mm-dd hh:00">
                            <input class="form-control" type="text" value="" placeholder="开始时间" readonly>
                            <span class="input-group-addon"><span class="glyphicon glyphicon-remove"></span></span>
                            <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
                        </div>
                        <div class="input-group date form_date form-control" id="inner_add_roll_notice_end_ts"
                            data-date="" data-date-format="yyyy/m/d hh:00" data-link-field="dtp_input1"
                            data-link-format="yyyy-mm-dd hh:00">
                            <input class="form-control" type="text" value="" placeholder="截止时间" readonly>
                            <span class="input-group-addon"><span class="glyphicon glyphicon-remove"></span></span>
                            <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
                        </div>
                        <input type="text" id="inner_add_roll_notice_interval" class="form-control"
                            placeholder="间隔时间/秒">
                        <input type="hidden" id="dtp_input1" value="" /><br />
                    </div>
                    <button class="btn btn-lg btn-primary btn-block" type="submit"
                        style="width:120px;margin:auto">添加</button>
                </form>
            </div>
        </div>
    </div><!-- /.modal -->
</div>


<div class="modal fade" id="edit_roll_notice" tabindex="-1" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h3 id="edit_roll_notice_header" class="modal-title">更改</h3>
            </div>
            <div class="modal-body">
                <form id="form_edit_roll_notice" class="form-horizontal">
                    <div class="form-group">
                        <input type="text" id="inner_edit_roll_notice_id" class="form-control" placeholder="公告ID"
                            required>
                        <input type="text" id="inner_edit_roll_notice_content" class="form-control" placeholder="更改内容">
                        <div class="input-group date form_date form-control" id="inner_edit_roll_notice_start_ts"
                            data-date="" data-date-format="yyyy/m/d hh:00" data-link-field="dtp_input1"
                            data-link-format="yyyy-mm-dd hh:00">
                            <input class="form-control" type="text" value="" placeholder="开始时间" readonly>
                            <span class="input-group-addon"><span class="glyphicon glyphicon-remove"></span></span>
                            <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
                        </div>
                        <div class="input-group date form_date form-control" id="inner_edit_roll_notice_end_ts"
                            data-date="" data-date-format="yyyy/m/d hh:00" data-link-field="dtp_input1"
                            data-link-format="yyyy-mm-dd hh:00">
                            <input class="form-control" type="text" value="" placeholder="截止时间" readonly>
                            <span class="input-group-addon"><span class="glyphicon glyphicon-remove"></span></span>
                            <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
                        </div>
                        <input type="text" id="inner_edit_roll_notice_interval" class="form-control"
                            placeholder="间隔时间/秒">
                        <input type="hidden" id="dtp_input1" value="" /><br />
                    </div>
                    <button class="btn btn-lg btn-primary btn-block" type="submit"
                        style="width:120px;margin:auto">更改</button>
                </form>
            </div>
        </div>
    </div><!-- /.modal -->
</div>


<div class="modal fade" id="delete_roll_notice" tabindex="-1" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h3 id="delete_roll_notice_header" class="modal-title">删除</h3>
            </div>
            <div class="modal-body">
                <form id="form_delete_roll_notice" class="form-horizontal">
                    <div class="form-group">
                        <input type="text" id="inner_delete_roll_notice_id" class="form-control" placeholder="公告ID"
                            required>
                        <input type="hidden" id="dtp_input1" value="" /><br />
                    </div>
                    <button class="btn btn-lg btn-primary btn-block" type="submit"
                        style="width:120px;margin:auto">删除</button>
                </form>
            </div>
        </div>
    </div><!-- /.modal -->
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


<!-- 大区,服务器 -->
<script type="text/javascript">
    var zone_list;

    /********************大区,服务器部分********************/
    function on_zone_change() {
        $("#server").find("option").remove()
        var name = $("#zone").val()
        // console.log(zone_list) //测试
        $.each(zone_list, function (key, values) {
            var zone = values;
            if (zone.name == name) {
                var option = '<option server_id="' + zone.id + '">' + zone.id + "</option>"
                // console.log(zone.id,zone.name) //测试
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
                zone_list = msg.zone_list;
                $.each(zone_list, function (key, values) {
                    $("#zone").append("<option>" + values.name + "</option>");
                })
                on_zone_change();
            }
        });

        $("#zone").change(on_zone_change);


        $("#roll_notice").submit(function () {
            event.preventDefault();
            $("#roll_notice_result").find("tr").remove();

            var server_id = $("#server").find(":selected").attr("server_id");
            console.log(server_id)
            $("#roll_notice").addClass("hidden")
            $.ajax({
                type: "POST",
                url: "/query_roll_notice",
                data: { server_id: server_id },
                dataType: 'json',
                success: function (msg) {
                    console.log(msg)    // Test
                    toastr.options.positionClass = 'toast-top-center';
                    if (msg.err) {
                        toastr.error(msg.err);
                        return;
                    }
                    $("#roll_notice").removeClass("hidden")
                    for (var i = 0; i < msg.info.notice_list.length; i++) {
                        var tr = "<tr>"
                        $.each(msg.info.notice_list[i], function (key, val) {
                            if (key == "content") { tr += "<td>内容: " + val + "</td>" }
                            if (key == "end_ts") { tr += "<td>结束时间:  " + new Date(val * 1000).format("yyyy-MM-dd EE HH:mm:ss") + "</td>" }
                            if (key == "interval") { tr += "<td>间隔时间: " + val + "秒</td>" }
                            if (key == "notice_id") { tr += "<td>公告ID: " + val + "</td>" }
                            if (key == "start_ts") { tr += "<td>开始时间:  " + new Date(val * 1000).format("yyyy-MM-dd EE HH:mm:ss") + "</td>" }
                        })
                        tr += "</tr>"
                        console.log(tr);
                        $("#roll_notice_result").append(tr);
                    }
                }
            });
        })
    })
</script>


<!-- 控件 -->
<script type="text/javascript">
    function add_roll_notice() {
        var server_id = $("#server").find(":selected").attr("server_id");
        $('#add_roll_notice').modal('show')
        $('#form_add_roll_notice').unbind('submit');
        $('#form_add_roll_notice').submit(function () {
            event.preventDefault()
            var notice_content = $("#inner_add_roll_notice_content").val();
            var notice_end_ts = (Date.parse($('#inner_add_roll_notice_end_ts').data().date) / 1000).toString();
            var notice_start_ts = (Date.parse($('#inner_add_roll_notice_start_ts').data().date) / 1000).toString();
            var interval = $("#inner_add_roll_notice_interval").val();
            console.log(notice_start_ts, notice_end_ts)
            $.ajax({
                type: "POST",
                url: "/add_roll_notice",
                data: {
                    server_id: server_id,
                    content: notice_content,
                    start_ts: notice_start_ts,
                    end_ts: notice_end_ts,
                    interval: interval,
                },
                dataType: 'json',
                success: function (msg) {
                    console.log(msg)
                    toastr.options.positionClass = 'toast-top-center';
                    if (msg.err) {
                        toastr.error(msg.err);
                        return;
                    }
                    toastr.success("操作成功")
                    $("#query_submit").click();  // 点击
                    $('#form_add_roll_notice')[0].reset() //cal Dom's reset
                    $('#add_roll_notice').modal('hide')
                }
            });
        })
    }


    function edit_roll_notice() {
        var server_id = $("#server").find(":selected").attr("server_id");
        $('#edit_roll_notice').modal('show')
        $('#form_edit_roll_notice').unbind('submit');
        $('#form_edit_roll_notice').submit(function () {
            event.preventDefault()
            var notice_id = $("#inner_edit_roll_notice_id").val();
            var notice_content = $("#inner_edit_roll_notice_content").val();
            var notice_end_ts = Date.parse($('#inner_edit_roll_notice_end_ts').data().date).toString();
            var notice_start_ts = Date.parse($('#inner_edit_roll_notice_start_ts').data().date).toString();
            var interval = $("#inner_edit_roll_notice_interval").val();
            console.log(notice_id, notice_start_ts, notice_end_ts)
            $.ajax({
                type: "POST",
                url: "/edit_roll_notice",
                data: {
                    server_id: server_id,
                    notice_id: notice_id,
                    content: notice_content,
                    start_ts: notice_start_ts,
                    end_ts: notice_end_ts,
                    interval: interval,
                },
                dataType: 'json',
                success: function (msg) {
                    console.log(msg)
                    toastr.options.positionClass = 'toast-top-center';
                    if (msg.err) {
                        toastr.error(msg.err);
                        return;
                    }
                    toastr.success("操作成功")
                    $("#query_submit").click();  // 点击
                    $('#form_edit_roll_notice')[0].reset() //cal Dom's reset
                    $('#edit_roll_notice').modal('hide')
                }
            });
        })
    }


    function delete_roll_notice() {
        var server_id = $("#server").find(":selected").attr("server_id");

        $('#delete_roll_notice').modal('show')
        $('#form_delete_roll_notice').unbind('submit');
        $('#form_delete_roll_notice').submit(function () {
            event.preventDefault()
            var notice_id = $("#inner_delete_roll_notice_id").val();
            console.log(notice_id)
            $.ajax({
                type: "POST",
                url: "/delete_roll_notice",
                data: {
                    server_id: server_id,
                    notice_id: notice_id,
                },
                dataType: 'json',
                success: function (msg) {
                    console.log(msg)
                    toastr.options.positionClass = 'toast-top-center';
                    if (msg.err) {
                        toastr.error(msg.err);
                        return;
                    }
                    toastr.success("操作成功")
                    $("#query_submit").click();  // 点击
                    $('#form_delete_roll_notice')[0].reset() //cal Dom's reset
                    $('#delete_roll_notice').modal('hide')
                }
            });
        })

    }

</script>