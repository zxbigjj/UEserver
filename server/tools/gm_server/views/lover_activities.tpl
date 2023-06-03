% rebase('base.tpl', child='lover_activities', sidemenu='other_mgr')
<link href="static/datetimepicker/css/bootstrap-datetimepicker.css" rel="stylesheet">
<script src="static/datetimepicker/js/bootstrap-datetimepicker.js"></script>
<script src="static/datetimepicker/js/bootstrap-datetimepicker.zh-CN.js"></script>

<link rel="stylesheet" href="static/bootstrap-table/bootstrap-table.min.css">
<script src="static/bootstrap-table/bootstrap-table.min.js"></script>


<!-- 窗口1 -->
<div class="panel panel-default">
    <div class="panel-heading">
        <h3 class="panel-title">
            Lover Activities
        </h3>
    </div>

    <div id="toolbar" class="btn-group">
        <button id="btn_add" type="button" class="btn btn-default" onclick="add_lover_activities_onclick();">
            <span class="glyphicon glyphicon-plus" aria-hidden="true"></span>Add
        </button>
    </div>

    <table id="lover_activities_info_tb"></table>
</div>


<!-- 窗口2 -->
<div class="modal fade" id="add_lover_activities_modal" data-backdrop tabindex="-1" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title">Add Lover Activity</h4>
            </div>

            <div class="modal-body">
                <form class="form-horizontal">
                    <div class="form-group">
                        <p class="col-sm-3">Goods_Name</p>
                        <div class="col-sm-9">
                            <input type="text" class="form-control" id="goods_name" maxlength="16">
                        </div>
                    </div>

                    <div class="form-group" >
                        <p class="col-sm-3">Server</p>
                        <div class="col-sm-9" id="lover_type">
                            <select class="form-control" id="server_id">
                                
                            </select>
                        </div>
                    </div>


                    <div class="form-group">
                        <p class="col-sm-3">Title</p>
                        <div class="col-sm-9">
                            <input type="text" class="form-control" id="activity_name_fir" maxlength="16">
                        </div>
                    </div>

                    <div class="form-group">
                        <p class="col-sm-3">Subhead</p>
                        <div class="col-sm-9">
                            <input type="text" class="form-control" id="activity_name_sec" maxlength="16">
                        </div>
                    </div>

                    <div class="form-group">
                        <p class="col-sm-3">Price</p>
                        <div class="col-sm-9" id="price">
                            <select class="form-control">
                                <option value="38">38</option>
                                <option value="68">68</option>
                                <option value="98">98</option>
                                <option value="128">128</option>
                                <option value="328">328</option>
                                <option value="648">648</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <p class="col-sm-3">Discount</p>
                        <div class="col-sm-9">
                            <input type="text" class="form-control" id="discount">
                        </div>
                    </div>

                    <div class="form-group">
                        <p class="col-sm-3">Back Image</p>
                        <div class="col-sm-9">
                            <input type="text" class="form-control" id="icon">
                        </div>
                    </div>

                    <div class="form-group" id="lover_id_form_div">
                        <p class="col-sm-3">Unit ID</p>
                        <div class="col-sm-9">
                            <input type="text" class="form-control" id="lover_id" required="required">
                        </div>
                    </div>

                    <div class="form-group" id="lover_fashion_form_div">
                        <p class="col-sm-3">Fashion<br>(情人时装)</p>
                        <div class="col-sm-9">
                            <input type="text" class="form-control" id="lover_fashion">
                        </div>
                    </div>

                    <div class="form-group" id="lover_piece_form_div">
                        <p class="col-sm-3">Piece<br>(情人碎片)</p>
                        <div class="col-sm-9">
                            <input type="text" class="form-control" id="lover_piece">
                        </div>
                    </div>

                    <div class="form-group" id="lover_type_form_div">
                        <p class="col-sm-3">Lover Type</p>
                        <div class="col-sm-9" id="lover_type">
                            <select class="form-control" onchange="lover_type_on_change('#add_lover_activities_modal')">
                                <option value="1">lover</option>
                                <option value="0">video</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group" id="face_time_form_div">
                        <p class="col-sm-3">Face Time</p>
                        <div class="col-sm-9" id="face_time">
                            <p class="col-sm-4"><input type="radio" name="face_time" value="60019">occlude_1</p>
                            <p class="col-sm-4"><input type="radio" name="face_time" value="60020">occlude_2</p>
                            <p class="col-sm-4"><input type="radio" name="face_time" value="60021">occlude_3</p>
                        </div>
                    </div>

                    <div class="form-group">
                        <p class="col-sm-3">Refresh Interval</p>
                        <div class="col-sm-9">
                            <input type="text" class="form-control" id="refresh_interval" placeholder="Minute">
                        </div>
                    </div>
                </form>
            </div>

            <div class="modal-footer">
                <form class="form-horizontal" id="add_lover_activities">
                    <div class="form-group">
                        <button type="button" class="btn btn-default" onclick="add_rewards('#add_lover_activities');">
                            Add Rewards</button>
                    </div>
                    <div class="form-group" id="reward_list">
                        <div name="item_group">
                            <div class="col-sm-6">
                                <input type="text" class="form-control" placeholder="ID" name="id">
                            </div>
                            <div class="col-sm-6">
                                <input type="text" class="form-control" placeholder="Count" name="count">
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <button class="btn btn-lg btn-primary btn-block" type="submit">
                            Lover Activities</button>
                    </div>
                </form>
            </div>
        </div>
    </div><!-- /.modal -->
</div>




<!-- 时间组件初始化 -->
<script type="text/javascript">
    $(document).ready(function () {
        $('.form_date').datetimepicker({
            language: 'en-US',
            todayBtn: true,
        });
    });
</script>

<!-- 表格组件 -->
<script type="text/javascript">
    
    function addFunctionAlty(value, row, index) {
        return [
            '<button id="delete" type="button" class="btn btn-default" style="width:90px;margin:auto">Delete</button>',
            '<button id="edit" type="button" class="btn btn-default" style="width:90px;margin:auto">Edit</button>',
        ].join('');
    }

    window.operateEvents = {
        'click #delete': function (e, value, row, index) {
            $.ajax({
                url: "/del_lover_activities",
                type: "post",
                data: { id: row.id, server_id: row.server_id },
                success: function (msg) {
                    toastr.options.positionClass = 'toast-top-center';
                    if (msg.err) {
                        toastr.error(msg.err);
                    } else {
                        window.location.reload();
                    }
                }
            });
        },
        'click #edit': function (e, value, row, index) {
            $("#edit_lover_activities_modal").find("#server_id").val(row.server_id);
            $("#edit_lover_activities_modal").find("#lover_id").val(row.lover_id);
            $("#edit_lover_activities_modal").find("#lover_piece").val(row.lover_piece);
            $("#edit_lover_activities_modal").find("#lover_fashion").val(row.lover_fashion);
            $("#edit_lover_activities_modal").find("#lover_type").find("select").val(row.lover_type);
            if (row.lover_type == 0) { $("#edit_lover_activities_modal").find("#face_time_form_div").hide(); }
            if (row.lover_type == 0) { $("#edit_lover_activities_modal").find("#lover_piece_form_div").hide(); }
            if (row.lover_type == 0) { $("#edit_lover_activities_modal").find("#lover_fashion_form_div").hide(); }
            $("#edit_lover_activities_modal").find("#activity_name_fir").val(row.activity_name_fir);
            $("#edit_lover_activities_modal").find("#activity_name_sec").val(row.activity_name_sec);
            $("#edit_lover_activities_modal").find("#refresh_interval").val(row.refresh_interval);
            $("#edit_lover_activities_modal").find("#price").find("select").val(row.price);
            $("#edit_lover_activities_modal").find("#discount").val(row.discount);
            $("#edit_lover_activities_modal").find("#icon").val(row.icon);
            set_rewards(row.item_list);
            switch (row.face_time) {
                case "60019":
                    $("#edit_lover_activities_modal").find("#face_time").find("input:radio[value='60019']").prop("checked", true)
                    break;
                case "60020":
                    $("#edit_lover_activities_modal").find("#face_time").find("input:radio[value='60020']").prop("checked", true)
                    break;
                case "60021":
                    $("#edit_lover_activities_modal").find("#face_time").find("input:radio[value='60021']").prop("checked", true)
                    break;
                default:
                    break;
            }

            $('#edit_lover_activities_modal').modal('show')
            $('#edit_lover_activities_modal').unbind('submit')
            $("#edit_lover_activities").submit(function () {
                event.preventDefault();
                var server_id = $("#edit_lover_activities_modal").find("#server_id").val();
                var reward = JSON.stringify(get_reward_list("#edit_lover_activities_modal"));
                var price = $("#edit_lover_activities_modal").find("#price").find(":selected").html();
                var discount = $("#edit_lover_activities_modal").find("#discount").val();
                var icon = $("#edit_lover_activities_modal").find("#icon").val();
                var refresh_interval = $("#edit_lover_activities_modal").find("#refresh_interval").val();
                var lover_id = $("#edit_lover_activities_modal").find("#lover_id").val();
                var lover_piece = $("#edit_lover_activities_modal").find("#lover_piece").val();
                var lover_fashion = $("#edit_lover_activities_modal").find("#lover_fashion").val();
                var lover_type = $("#edit_lover_activities_modal").find("#lover_type").find(":selected").attr("value");
                var activity_name_fir = $("#edit_lover_activities_modal").find("#activity_name_fir").val();
                var activity_name_sec = $("#edit_lover_activities_modal").find("#activity_name_sec").val();
                var face_time = $("#edit_lover_activities_modal").find("input:radio[name='face_time']:checked").val();
                if (face_time == null) { face_time = "-1" }

                $("#edit_lover_activities").find("button[type='submit']").prop("disabled", true);
                $.ajax({
                    type: "post",
                    url: "/update_lover_activities",
                    data: {
                        id: row.id,
                        server_id: server_id,
                        refresh_interval: refresh_interval,
                        lover_type: lover_type, lover_piece: lover_piece,
                        lover_id: lover_id, lover_fashion: lover_fashion,
                        icon: icon, face_time: face_time,
                        price: price, discount: discount, reward: reward,
                        activity_name_fir: activity_name_fir, activity_name_sec: activity_name_sec,
                    },
                    dataType: "json",
                    success: function (msg) {
                        toastr.options.positionClass = 'toast-top-center';
                        if (msg.err) {
                            toastr.error(msg.err);
                            $("#edit_lover_activities").find("button[type='submit']").prop("disabled", false);
                        } else {
                            window.location.reload();
                        }
                    }
                });
            })

            $('#edit_lover_activities_modal').on('hide.bs.modal', function () {
                window.location.reload();
            })
        }
    };
    
    $(document).ready(function () {
        $.ajax({
            type: "POST",
            url: "/query_lover_activities",
            dataType: 'json',
            success: function (msg) {
                console.log(msg)
                $("#lover_activities_info_tb").bootstrapTable({
                    toolbar: "#toolbar",
                    striped: true,
                    cache: false,
                    data: msg.info,
                    columns: [
                        {
                            field: 'id',
                            title: 'ID',
                        }, {
                            field: 'activity_name_fir',
                            title: 'Title',
                            width: 8,
                            widthUnit: "%"
                        }, {
                            field: 'activity_name_sec',
                            title: 'Subhead',
                            width: 8,
                            widthUnit: "%"
                        }, {
                            field: 'server_id',
                            title: 'Server',
                        }, {
                            field: 'item_list',
                            title: 'Reward',
                            width: 180,
                            formatter: function (value, row, index) {
                                return "<pre>" + JSON.stringify(value, null, 1) + "</pre>"
                            }
                        }, {
                            field: 'price',
                            title: 'Price   ',
                            formatter: function (value, row, index) {
                                return value.toString()
                            }
                        }, {
                            field: 'discount',
                            title: 'Discount',
                        }, {
                            field: 'icon',
                            title: 'Back<br>Image',
                        }, {
                            field: 'face_time',
                            title: 'Face<br>Time',
                        }, {
                            field: 'lover_id',
                            title: 'Unit<br>ID',
                        }, {
                            field: 'lover_fashion',
                            title: 'Fashion',
                        }, {
                            field: 'lover_piece',
                            title: 'Piece',
                        }, {
                            field: 'lover_type',
                            title: 'Lover<br>Type',
                            formatter: function (value, row, index) {
                                if (value == 0) { return "video" } else if (value == 1) { return "lover" }
                            }
                        }, {
                            field: 'end_ts',
                            title: 'Refresh<br>Time',
                            formatter: function (value, row, index) {
                                return new Date(value * 1000).format("yy-MM-dd<br>HH:mm");
                            }
                        }, {
                            field: 'refresh_interval',
                            title: 'Refresh<br>Interval',
                        }, {
                            field: 'operate',
                            title: 'Action',
                            width: 90,
                            events: operateEvents,
                            formatter: addFunctionAlty
                        }]
                });
            }
        });
    });
</script>

<!-- 其他控制组件 -->
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
    function set_rewards(reward_info) {
        for (var index = 0; index < reward_info.length; index++) {
            var info = '<div name="item_group"><div class="col-sm-6"><input type="text" class="form-control" name="id" value=' + reward_info[index].item_id + '></div ><div class="col-sm-6"><input type="text" class="form-control" name="count" value=' + reward_info[index].count + '></div></div>'
            $("#edit_lover_activities").find("#reward_list").append(info);
        }
    }

    function add_rewards(path) {
        var info = '<div name="item_group"><div class="col-sm-6"><input type="text" class="form-control" placeholder="ID" name="id"></div ><div class="col-sm-6"><input type="text" class="form-control" placeholder="Count" name="count"></div></div>'
        $(path).find("#reward_list").append(info);
    }

    function get_reward_list(path) {
        var reward_lsit = $(path).find("#reward_list").find("div[name='item_group']");
        var result = {};
        $.each(reward_lsit, function (key, value) {
            var item_name = $(value).find("input[name='id']").val();
            var item_count = $(value).find("input[name='count']").val();
            result[item_name] = item_count;
        });
        return result;
    }

    function add_lover_activities_onclick() {
        $('#add_lover_activities_modal').modal('show')
        $('#add_lover_activities_modal').unbind('submit')
        $("#add_lover_activities").submit(function () {
            event.preventDefault()
            var goods_name = $("#add_lover_activities_modal").find("#goods_name").val();
            var server_id = $("#add_lover_activities_modal").find("#server_id").val();
            var reward = JSON.stringify(get_reward_list("#add_lover_activities_modal"));
            var price = $("#add_lover_activities_modal").find("#price").find(":selected").html();
            var discount = $("#add_lover_activities_modal").find("#discount").val();
            var icon = $("#add_lover_activities_modal").find("#icon").val();
            var refresh_interval = $("#add_lover_activities_modal").find("#refresh_interval").val();
            var lover_id = $("#add_lover_activities_modal").find("#lover_id").val();
            var lover_piece = $("#add_lover_activities_modal").find("#lover_piece").val();
            var lover_fashion = $("#add_lover_activities_modal").find("#lover_fashion").val();
            var lover_type = $("#add_lover_activities_modal").find("#lover_type").find(":selected").attr("value");
            var activity_name_fir = $("#add_lover_activities_modal").find("#activity_name_fir").val();
            var activity_name_sec = $("#add_lover_activities_modal").find("#activity_name_sec").val();
            var face_time = $("#add_lover_activities_modal").find("input:radio[name='face_time']:checked").val();
            if (face_time == null) { face_time = "-1" }

            $("#add_lover_activities").find("button[type='submit']").prop("disabled", true);
            $.ajax({
                type: "post",
                url: "/add_lover_activities",
                data: {
                    server_id: server_id,
                    refresh_interval: refresh_interval,
                    lover_type: lover_type, lover_piece: lover_piece,
                    lover_id: lover_id, lover_fashion: lover_fashion,
                    icon: icon, face_time: face_time,
                    price: price, discount: discount, reward: reward,
                    activity_name_fir: activity_name_fir, activity_name_sec: activity_name_sec,
                },
                dataType: "json",
                success: function (msg) {
                    toastr.options.positionClass = 'toast-top-center';
                    if (msg.err) {
                        toastr.error(msg.err);
                        $("#add_lover_activities").find("button[type='submit']").prop("disabled", false);
                    } else {
                        window.location.reload();
                    }
                }
            });
        })
    }

    function lover_type_on_change(pos) {
        var lover_type = $(pos).find("#lover_type").find(":selected").attr("value");
        console.log(lover_type)
        if (lover_type == '0') {
            $(pos).find("#face_time_form_div").hide();
            $(pos).find("#lover_piece_form_div").hide();
            $(pos).find("#lover_fashion_form_div").hide();

            $(pos).find("#face_time").find("input:radio[name='face_time']:checked").prop("checked", false);
            $(pos).find("#lover_piece").val(-1);
            $(pos).find("#lover_fashion").val(-1);

            $(pos).find("#lover_id_form_div").find("p").html('Unit ID (情人写真表)');
        } else if (lover_type == '1') {
            $(pos).find("#face_time_form_div").show();
            $(pos).find("#lover_piece_form_div").show();
            $(pos).find("#lover_fashion_form_div").show();

            $(pos).find("#lover_id_form_div").find("p").html('Unit ID');
        }
    }
    
 


</script>