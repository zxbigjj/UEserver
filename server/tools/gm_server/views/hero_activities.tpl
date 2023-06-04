% rebase('base.tpl', child='hero_activities', sidemenu='other_mgr')
<link href="static/datetimepicker/css/bootstrap-datetimepicker.css" rel="stylesheet">
<script src="static/datetimepicker/js/bootstrap-datetimepicker.js"></script>
<script src="static/datetimepicker/js/bootstrap-datetimepicker.zh-CN.js"></script>

<link rel="stylesheet" href="static/bootstrap-table/bootstrap-table.min.css">
<script src="static/bootstrap-table/bootstrap-table.min.js"></script>


<!-- 窗口1 -->
<div class="panel panel-default">
    <div class="panel-heading">
        <h3 class="panel-title">
            Hero Activities
        </h3>
    </div>

    <div id="toolbar" class="btn-group">
        <button id="btn_add" type="button" class="btn btn-default" onclick="add_hero_activities_onclick();">
            <span class="glyphicon glyphicon-plus" aria-hidden="true"></span>Add
        </button>
    </div>
    <table id="hero_activities_info_tb"></table>
</div>


<!-- 窗口2 -->
<div class="modal fade" id="add_hero_activities_modal" data-backdrop tabindex="-1" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title">Add Hero Activities</h4>
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
                        <div class="col-sm-9" >
                            <select class="form-control" id="server_id">
                                
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <p class="col-sm-2">Title</p>
                        <div class="col-sm-10 ">
                            <input type="text" class="form-control" id="activity_name_fir" maxlength="12">
                        </div>
                    </div>

                    <div class="form-group">
                        <p class="col-sm-2">Subhead</p>
                        <div class="col-sm-10 ">
                            <input type="text" class="form-control" id="activity_name_sec" maxlength="12">
                        </div>
                    </div>

                    <div class="form-group">
                        <p class="col-sm-2">Price</p>
                        <div class="col-sm-10 " id="price">
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
                        <p class="col-sm-2">Discount</p>
                        <div class="col-sm-10 ">
                            <input type="text" class="form-control" id="discount">
                        </div>
                    </div>

                    <div class="form-group">
                        <p class="col-sm-2">Back Image</p>
                        <div class="col-sm-10 ">
                            <input type="text" class="form-control" id="icon">
                        </div>
                    </div>

                    <div class="form-group">
                        <p class="col-sm-2">Unit ID</p>
                        <div class="col-sm-10 ">
                            <input type="text" class="form-control" id="hero_id">
                        </div>
                    </div>

                    <div class="form-group">
                        <p class="col-sm-2">Lover</p>
                        <div class="col-sm-5">
                            <p class="col-sm-2">Left</p>
                            <input id="hero_left_id" type="text" class="form-control" value="-1">
                        </div>
                        <div class="col-sm-5">
                            <p class="col-sm-2">Right</p>
                            <input id="hero_right_id" type="text" class="form-control" value="-1">
                        </div>
                    </div>

                    <div class="form-group">
                        <p class="col-sm-2">Refresh Interval</p>
                        <div class="col-sm-10 ">
                            <input type="text" class="form-control" id="refresh_interval" placeholder="Minute">
                        </div>
                    </div>
                </form>
            </div>

            <div class="modal-footer">
                <form class="form-horizontal" id="add_hero_activities">
                    <div class="form-group">
                        <button type="button" class="btn btn-default" onclick="add_rewards('#add_hero_activities');">
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
                            Hero Activities</button>
                    </div>
                </form>
            </div>
        </div>
    </div><!-- /.modal -->
</div>

<div class="modal fade" id="edit_hero_activities_modal" data-backdrop tabindex="-1" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title">Edit Hero Activities</h4>
            </div>

            <div class="modal-body">
                <form class="form-horizontal">
                    <div class="form-group">
                        <p class="col-sm-2">Goods_Name</p>
                        <div class="col-sm-10">
                            <input type="text" class="form-control" id="goods_name" maxlength="16">
                        </div>
                    </div>
                    <div class="form-group">
                        <p class="col-sm-2">Server</p>
                        <div class="col-sm-10 ">
                            <input type="text" class="form-control" id="server_id">
                        </div>
                    </div>

                    <div class="form-group">
                        <p class="col-sm-2">Title</p>
                        <div class="col-sm-10 ">
                            <input type="text" class="form-control" id="activity_name_fir" maxlength="12">
                        </div>
                    </div>

                    <div class="form-group">
                        <p class="col-sm-2">Subhead</p>
                        <div class="col-sm-10 ">
                            <input type="text" class="form-control" id="activity_name_sec" maxlength="12">
                        </div>
                    </div>

                    <div class="form-group">
                        <p class="col-sm-2">Price</p>
                        <div class="col-sm-10 " id="price">
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
                        <p class="col-sm-2">Discount</p>
                        <div class="col-sm-10 ">
                            <input type="text" class="form-control" id="discount">
                        </div>
                    </div>

                    <div class="form-group">
                        <p class="col-sm-2">Back Image</p>
                        <div class="col-sm-10 ">
                            <input type="text" class="form-control" id="icon">
                        </div>
                    </div>

                    <div class="form-group">
                        <p class="col-sm-2">Unit ID</p>
                        <div class="col-sm-10 ">
                            <input type="text" class="form-control" id="hero_id">
                        </div>
                    </div>

                    <div class="form-group">
                        <p class="col-sm-2">Lover</p>
                        <div class="col-sm-5">
                            <p class="col-sm-2">Left</p>
                            <input id="hero_left_id" type="text" class="form-control" value="-1">
                        </div>
                        <div class="col-sm-5">
                            <p class="col-sm-2">Right</p>
                            <input id="hero_right_id" type="text" class="form-control" value="-1">
                        </div>
                    </div>

                    <div class="form-group">
                        <p class="col-sm-2">Refresh Interval</p>
                        <div class="col-sm-10 ">
                            <input type="text" class="form-control" id="refresh_interval" placeholder="Minute">
                        </div>
                    </div>
                </form>
            </div>

            <div class="modal-footer">
                <form class="form-horizontal" id="edit_hero_activities">
                    <div class="form-group">
                        <button type="button" class="btn btn-default" onclick="add_rewards('#edit_hero_activities');">
                            Add Rewards</button>
                    </div>
                    <div class="form-group" id="reward_list">

                    </div>

                    <div class="form-group">
                        <button class="btn btn-lg btn-primary btn-block" type="submit">
                            Hero Activities</button>
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
            // '<button id="activate" type="button" class="btn btn-default" style="width:90px;margin:auto">Activate</button>',
            '<button id="delete" type="button" class="btn btn-default" style="width:90px;margin:auto">Delete</button>',
            '<button id="edit" type="button" class="btn btn-default" style="width:90px;margin:auto">Edit</button>',
        ].join('');
    }

    window.operateEvents = {
        'click #delete': function (e, value, row, index) {
            $.ajax({
                url: "/del_hero_activities",
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
            $("#edit_hero_activities_modal").find("#goods_name").val(row.goods_name);
            $("#edit_hero_activities_modal").find("#server_id").val(row.server_id);
            $("#edit_hero_activities_modal").find("#icon").val(row.icon);
            $("#edit_hero_activities_modal").find("#refresh_interval").val(row.refresh_interval);
            $("#edit_hero_activities_modal").find("#hero_id").val(row.hero_id);
            $("#edit_hero_activities_modal").find("#hero_left_id").val(row.hero_left_id);
            $("#edit_hero_activities_modal").find("#hero_right_id").val(row.hero_right_id);
            $("#edit_hero_activities_modal").find("#activity_name_fir").val(row.activity_name_fir);
            $("#edit_hero_activities_modal").find("#activity_name_sec").val(row.activity_name_sec);
            $("#edit_hero_activities_modal").find("#price").find("select").val(row.price);
            $("#edit_hero_activities_modal").find("#discount").val(row.discount);
            set_rewards(row.item_list);

            $('#edit_hero_activities_modal').modal('show')
            $('#edit_hero_activities_modal').unbind('submit')
            $("#edit_hero_activities").submit(function () {
                event.preventDefault();
                var goods_name = $("#edit_hero_activities_modal").find("#goods_name").val();
                var server_id = $("#edit_hero_activities_modal").find("#server_id").val();
                var reward = JSON.stringify(get_reward_list("#edit_hero_activities_modal"));
                var price = $("#edit_hero_activities_modal").find("#price").find(":selected").html();
                var discount = $("#edit_hero_activities_modal").find("#discount").val();
                var icon = $("#edit_hero_activities_modal").find("#icon").val();
                var refresh_interval = $("#edit_hero_activities_modal").find("#refresh_interval").val();
                var hero_id = $("#edit_hero_activities_modal").find("#hero_id").val();
                var hero_left_id = $("#edit_hero_activities_modal").find("#hero_left_id").val();
                var hero_right_id = $("#edit_hero_activities_modal").find("#hero_right_id").val();
                var activity_name_fir = $("#edit_hero_activities_modal").find("#activity_name_fir").val();
                var activity_name_sec = $("#edit_hero_activities_modal").find("#activity_name_sec").val();

                $("#edit_hero_activities").find("button[type='submit']").prop("disabled", true);
                $.ajax({
                    type: "post",
                    url: "/update_hero_activities",
                    data: {
                        goods_name:goods_name,
                        id: row.id,
                        server_id: server_id,
                        price: price, discount: discount,
                        hero_id: hero_id, reward: reward, icon: icon,
                        hero_left_id: hero_left_id, hero_right_id: hero_right_id,
                        refresh_interval: refresh_interval,
                        activity_name_fir: activity_name_fir,
                        activity_name_sec: activity_name_sec,
                    },
                    dataType: "json",
                    success: function (msg) {
                        toastr.options.positionClass = 'toast-top-center';
                        if (msg.err) {
                            toastr.error(msg.err);
                            $("#edit_hero_activities").find("button[type='submit']").prop("disabled", false);
                        } else {
                            window.location.reload();
                        }
                    }
                });
            })

            $('#edit_hero_activities_modal').on('hide.bs.modal', function () {
                window.location.reload();
                // $("#edit_hero_activities").find("#reward_list").find("div").remove();
            })
        }
    };

    $(document).ready(function () {
        $.ajax({
            type: "POST",
            url: "/query_hero_activities",
            dataType: 'json',
            success: function (msg) {
                console.log(msg)
                $("#hero_activities_info_tb").bootstrapTable({
                    toolbar: "#toolbar",
                    striped: true,
                    cache: false,
                    data: msg.info,
                    columns: [
                        {
                            field: 'goods_name',
                            title: 'Goods_Name',
                        },
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
                    },
                    // {
                    //     field: 'face_time',
                    //     title: 'Face<br>Time',
                    // }, 
                    {
                        field: 'hero_id',
                        title: 'Hero<br>ID',
                    }, {
                        field: 'hero_left_id',
                        title: 'Hero<br>Left',
                    }, {
                        field: 'hero_right_id',
                        title: 'Hero<br>Right',
                    },
                    // {
                    //     field: 'hero_type',
                    //     title: 'Lover<br>Type',
                    //     formatter: function (value, row, index) {
                    //         if (value == 0) { return "video" } else if (value == 1) { return "hero" }
                    //     }
                    // },
                    {
                        field: 'end_ts',
                        title: 'Refresh<br>Time',
                        formatter: function (value, row, index) {
                            return new Date(value * 1000).format("yy-MM-dd<br>HH:mm");
                        }
                    }, {
                        field: 'refresh_interval',
                        title: 'Refresh<br>Interval',
                    },
                    // {
                    //     field: 'status',
                    //     title: 'Status'
                    // }, 
                    {
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
        console.log(reward_info)
        for (var index = 0; index < reward_info.length; index++) {
            var info = '<div name="item_group"><div class="col-sm-6"><input type="text" class="form-control" name="id" value=' + reward_info[index].item_id + '></div ><div class="col-sm-6"><input type="text" class="form-control" name="count" value=' + reward_info[index].count + '></div></div>'
            $("#edit_hero_activities").find("#reward_list").append(info);
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

    function add_hero_activities_onclick() {
        $('#add_hero_activities_modal').modal('show')
        $('#add_hero_activities_modal').unbind('submit')
        $("#add_hero_activities").submit(function () {
            event.preventDefault()
            var server_id = $("#add_hero_activities_modal").find("#server_id").val();
            var reward = JSON.stringify(get_reward_list("#add_hero_activities_modal"));
            var price = $("#add_hero_activities_modal").find("#price").find(":selected").html();
            var discount = $("#add_hero_activities_modal").find("#discount").val();
            var icon = $("#add_hero_activities_modal").find("#icon").val();
            var refresh_interval = $("#add_hero_activities_modal").find("#refresh_interval").val();
            var hero_id = $("#add_hero_activities_modal").find("#hero_id").val();
            var hero_left_id = $("#add_hero_activities_modal").find("#hero_left_id").val();
            var hero_right_id = $("#add_hero_activities_modal").find("#hero_right_id").val();
            var activity_name_fir = $("#add_hero_activities_modal").find("#activity_name_fir").val();
            var activity_name_sec = $("#add_hero_activities_modal").find("#activity_name_sec").val();

            $("#add_hero_activities").find("button[type='submit']").prop("disabled", true);
            $.ajax({
                type: "post",
                url: "/add_hero_activities",
                data: {
                    server_id: server_id,
                    price: price, discount: discount,
                    hero_id: hero_id, reward: reward, icon: icon,
                    hero_left_id: hero_left_id, hero_right_id: hero_right_id,
                    refresh_interval: refresh_interval,
                    activity_name_fir: activity_name_fir,
                    activity_name_sec: activity_name_sec,
                },
                dataType: "json",
                success: function (msg) {
                    toastr.options.positionClass = 'toast-top-center';
                    if (msg.err) {
                        toastr.error(msg.err);
                        $("#add_hero_activities").find("button[type='submit']").prop("disabled", false);
                    } else {
                        window.location.reload();
                    }
                }
            });
        })
    }
</script>