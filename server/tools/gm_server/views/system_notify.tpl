% rebase('base.tpl', child='system_notify', sidemenu='notify_mgr')
<link href="static/datetimepicker/css/bootstrap-datetimepicker.css" rel="stylesheet">
<script src="static/datetimepicker/js/bootstrap-datetimepicker.js"></script>
<script src="static/datetimepicker/js/bootstrap-datetimepicker.zh-CN.js"></script>
<div class="panel panel-default">
    <div class="panel-heading">查询公告</div>
    <div class="panel-body">
        <form class="form-horizontal" id="system_notice">
            <div class="form-group">
                <div class="col-sm-offset-3">
                    <button id="query_submit" type="submit" class="btn btn-primary" style="padding-left: 30px; padding-right: 30px">查询</button>
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
            <button type="button" class="btn btn-warning navbar-btn" onclick="add_system_notice();">添 加</button>
            <button type="button" class="btn btn-warning navbar-btn" onclick="edit_system_notice();">修 改</button>
            <button type="button" class="btn btn-warning navbar-btn" onclick="delete_system_notice();">删 除</button>
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
            <tbody id="system_notice_result">

            </tbody>
        </table>
        
    </div>
</div>


<!-- 窗口2 -->
<div class="modal fade" id="add_system_notice" tabindex="-1" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h3 id="add_system_noticeheader" class="modal-title">添加</h3>
            </div>
            <div class="modal-body">
                <form id="form_add_system_notice" class="form-horizontal">
                    <div class="form-group-lg">
                        <input type="text" id="inner_add_system_notice_title" class="form-control" placeholder="添加标题">
                        <textarea class="form-control" rows="3" id="inner_add_system_notice_content" placeholder="添加内容"></textarea>
                        
                        
                        <select class="form-control" id="inner_add_system_notice_state" placeholder="添加状态">
                            <option>HOT</option>
                            <option>NEW</option>
                        </select>
                       
                        <div class="input-group date form_date form-control" id="inner_add_system_notice_start_ts"
                            data-date="" data-date-format="yyyy/m/d hh:00" data-link-field="dtp_input1"
                            data-link-format="yyyy-mm-dd hh:00">
                            <input class="form-control" type="text" value="" placeholder="开始时间" readonly>
                            <span class="input-group-addon"><span class="glyphicon glyphicon-remove"></span></span>
                            <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
                        </div>
                        <div class="input-group date form_date form-control" id="inner_add_system_notice_end_ts"
                            data-date="" data-date-format="yyyy/m/d hh:00" data-link-field="dtp_input1"
                            data-link-format="yyyy-mm-dd hh:00">
                            <input class="form-control" type="text" value="" placeholder="截止时间" readonly>
                            <span class="input-group-addon"><span class="glyphicon glyphicon-remove"></span></span>
                            <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
                        </div>
                        
                    </div>
                    <button class="btn btn-lg btn-primary btn-block" type="submit"
                        style="width:120px;margin:auto">添加</button>
                </form>
            </div>
        </div>
    </div><!-- /.modal -->
</div>


<div class="modal fade" id="edit_system_notice" tabindex="-1" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h3 id="edit_system_notice_header" class="modal-title">更改</h3>
            </div>
            <div class="modal-body">
                <form id="form_edit_system_notice" class="form-horizontal">
                    <div class="form-group">
                        <input type="text" id="inner_edit_system_notice_id" class="form-control" placeholder="公告ID"
                            required>
                        <input type="text" id="inner_edit_system_notice_title" class="form-control" placeholder="更改标题">
                        <textarea class="form-control" rows="3" id="inner_edit_system_notice_content" placeholder="添加内容"></textarea>
                        
                        
                        <select class="form-control" id="inner_edit_system_notice_state" placeholder="添加状态">
                            <option>HOT</option>
                            <option>NEW</option>
                        </select>
                        <div class="input-group date form_date form-control" id="inner_edit_system_notice_start_ts"
                            data-date="" data-date-format="yyyy/m/d hh:00" data-link-field="dtp_input1"
                            data-link-format="yyyy-mm-dd hh:00">
                            <input class="form-control" type="text" value="" placeholder="开始时间" readonly>
                            <span class="input-group-addon"><span class="glyphicon glyphicon-remove"></span></span>
                            <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
                        </div>
                        <div class="input-group date form_date form-control" id="inner_edit_system_notice_end_ts"
                            data-date="" data-date-format="yyyy/m/d hh:00" data-link-field="dtp_input1"
                            data-link-format="yyyy-mm-dd hh:00">
                            <input class="form-control" type="text" value="" placeholder="截止时间" readonly>
                            <span class="input-group-addon"><span class="glyphicon glyphicon-remove"></span></span>
                            <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
                        </div>
                       
                        <input type="hidden" id="dtp_input1" value="" /><br />
                    </div>
                    <button class="btn btn-lg btn-primary btn-block" type="submit"
                        style="width:120px;margin:auto">更改</button>
                </form>
            </div>
        </div>
    </div><!-- /.modal -->
</div>


<div class="modal fade" id="delete_system_notice" tabindex="-1" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h3 id="delete_system_notice_header" class="modal-title">删除</h3>
            </div>
            <div class="modal-body">
                <form id="form_delete_system_notice" class="form-horizontal">
                    <div class="form-group">
                        <input type="text" id="inner_delete_system_notice_id" class="form-control" placeholder="公告ID"
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
   

    //全局加载
    $(document).ready(function () {
        


        $("#system_notice").submit(function () {
            event.preventDefault();
            $("#system_notice_result").find("tr").remove();

            //var server_id = $("#server").find(":selected").attr("server_id");
            console.log(1)
            $("#system_notice").addClass("hidden")
            $.ajax({
                type: "POST",
                url: "/query_system_notice",
                data: {  },
                dataType: 'json',
                success: function (msg) {
                    console.log(msg)    // Test
                    toastr.options.positionClass = 'toast-top-center';
                    if (msg.err) {
                        toastr.error(msg.err);
                        return;
                    }
                    $("#system_notice").removeClass("hidden")
                    for (var i = 0; i < msg.info.length; i++) {
                        var tr = "<tr>"
                        $.each(msg.info[i], function (key, val) {
                            if (key == "title") { tr += "<td>标题: " + val + "</td>" }
                            if (key == "content") { tr += "<td>内容: " + val + "</td>" }
                            if (key == "state") { tr += "<td>状态: " + val + "</td>" }
                            if (key == "end_ts") { tr += "<td>结束时间:  " + new Date(val * 1000).format("yyyy-MM-dd EE HH:mm:ss") + "</td>" }
                            //if (key == "interval") { tr += "<td>间隔时间: " + val + "秒</td>" }
                            if (key == "notice_id") { tr += "<td>公告ID: " + val + "</td>" }
                            if (key == "start_ts") { tr += "<td>开始时间:  " + new Date(val * 1000).format("yyyy-MM-dd EE HH:mm:ss") + "</td>" }
                        })
                        tr += "</tr>"
                        console.log(tr);
                        $("#system_notice_result").append(tr);
                    }
                }
            });
        })
    })
</script>


<!-- 控件 -->
<script type="text/javascript">
    function add_system_notice() {
        $('#add_system_notice').modal('show')
        $('#form_add_system_notice').unbind('submit');
        $('#form_add_system_notice').submit(function () {
            event.preventDefault()
            var notice_title = $("#inner_add_system_notice_title").val();
            var notice_content = $("#inner_add_system_notice_content").val();
            var notice_state = $("#inner_add_system_notice_state").val();
            var notice_end_ts = (Date.parse($('#inner_add_system_notice_end_ts').data().date) / 1000).toString();
            var notice_start_ts = (Date.parse($('#inner_add_system_notice_start_ts').data().date) / 1000).toString();
            console.log(notice_title,notice_content,notice_state)
            $.ajax({
                type: "POST",
                url: "/add_system_notice",
                data: {                   
                    title:notice_title,
                    content: notice_content,
                    start_ts: notice_start_ts,
                    end_ts: notice_end_ts,
                    state:notice_state,
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
                    $('#form_add_system_notice')[0].reset() //cal Dom's reset
                    $('#add_system_notice').modal('hide')
                }
            });
        })
    }


    function edit_system_notice() {
        $('#edit_system_notice').modal('show')
        $('#form_edit_system_notice').unbind('submit');
        $('#form_edit_system_notice').submit(function () {
            event.preventDefault()
            var notice_id = $("#inner_edit_system_notice_id").val();
            var notice_title = $("#inner_edit_system_notice_title").val();
            var notice_content = $("#inner_edit_system_notice_content").val();
            var notice_state = $("#inner_edit_system_notice_state").val();
            var notice_end_ts = Date.parse($('#inner_edit_system_notice_end_ts').data().date).toString();
            var notice_start_ts = Date.parse($('#inner_edit_system_notice_start_ts').data().date).toString();
            
            
            $.ajax({
                type: "POST",
                url: "/edit_system_notice",
                data: {
                    notice_id: notice_id,
                    title:notice_title,
                    content: notice_content,
                    state: notice_state,
                    start_ts: notice_start_ts,
                    end_ts: notice_end_ts,
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
                    $('#form_edit_system_notice')[0].reset() //cal Dom's reset
                    $('#edit_system_notice').modal('hide')
                }
            });
        })
    }


    function delete_system_notice() {
        $('#delete_system_notice').modal('show')
        $('#form_delete_system_notice').unbind('submit');
        $('#form_delete_system_notice').submit(function () {
            event.preventDefault()
            var notice_id = $("#inner_delete_system_notice_id").val();
            console.log(notice_id)
            $.ajax({
                type: "POST",
                url: "/delete_system_notice",
                data: {
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
                    $('#form_delete_system_notice')[0].reset() //cal Dom's reset
                    $('#delete_system_notice').modal('hide')
                }
            });
        })

    }

</script>