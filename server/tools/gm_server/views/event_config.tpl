% rebase('base.tpl', child='event_config', sidemenu='other_mgr')
<link href="static/datetimepicker/css/bootstrap-datetimepicker.css" rel="stylesheet">
<script src="static/datetimepicker/js/bootstrap-datetimepicker.js"></script>
<script src="static/datetimepicker/js/bootstrap-datetimepicker.zh-CN.js"></script>


<!-- 窗口1 -->
<div class="panel panel-default" id="world_list">
    <div class="panel-heading">
        <h3 class="panel-title">World List</h3>
    </div>
    <div class="panel-body">
        <form class="form-inline" id="world_list_form">
            <div class="checkbox col-sm-2">
                <label><input type="checkbox" server_id="55">测试服: 55</label>
            </div>
            <div class="checkbox col-sm-2">
                <label><input type="checkbox" server_id="68">测试服: 68</label>
            </div>
        </form>
    </div>
</div>


<div class="panel panel-default" id="event_basic_info">
    <div class="panel-heading">
        <h3 class="panel-title">Basic Info</h3>
    </div>
    <div class="panel-body">
        <form class="form-horizontal" id="event_info">
            <div class="form-group">
                <label for="" class="col-sm-3 control-label">Start Time:</label>
                <div class='col-sm-6 input-group date form_date'>
                    <input type='text' class="form-control" id="start_time" />
                    <span class="input-group-addon">
                        <span class="glyphicon glyphicon-calendar"></span>
                    </span>
                </div>
            </div>

            <div class="form-group">
                <label for="" class="col-sm-3 control-label">End Time:</label>
                <div class='col-sm-6 input-group date form_date'>
                    <input type='text' class="form-control" id="end_time" />
                    <span class="input-group-addon">
                        <span class="glyphicon glyphicon-calendar"></span>
                    </span>
                </div>
            </div>

            <div class="form-group">
                <label for="" class="col-sm-3 control-label">Notify Start Time:</label>
                <div class='col-sm-6 input-group date form_date'>
                    <input type='text' class="form-control" id="notify_start_time" />
                    <span class="input-group-addon">
                        <span class="glyphicon glyphicon-time"></span>
                    </span>
                </div>
            </div>

            <div class="form-group">
                <label for="" class="col-sm-3 control-label">Reward End Time:</label>
                <div class='col-sm-6 input-group date form_date'>
                    <input type='text' class="form-control" id="reward_end_time" />
                    <span class="input-group-addon">
                        <span class="glyphicon glyphicon-time"></span>
                    </span>
                </div>
            </div>

            <div class="form-group">
                <label for="priority" class="col-sm-3 control-label">Priority:</label>
                <div class="col-sm-6" id="priority">
                    <select class="form-control required">
                        <option>P1</option>
                        <option>P2</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label for="event_status" class="col-sm-3 control-label">Event Status:</label>
                <div class="col-sm-6" id="event_status">
                    <select class="form-control required">
                        <option>P1</option>
                        <option>P2</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label for="" class="col-sm-3 control-label">Auto Reward:</label>
                <div class="col-sm-6">
                    <label class="col-sm-2"><input name="auto_reward" type="radio" value="True">Yes</label>
                    <label class="col-sm-2"><input name="auto_reward" type="radio" value="False">No</label>
                </div>
            </div>

            <div class="form-group">
                <label for="" class="col-sm-3 control-label">Alliance Change:</label>
                <div class="col-sm-6">
                    <label class="col-sm-2"><input name="alliance_change" type="radio" value="True">Yes</label>
                    <label class="col-sm-2"><input name="alliance_change" type="radio" value="False">No</label>
                </div>
            </div>

            <div class="form-group">
                <label for="" class="col-sm-3 control-label">Event Type:</label>
                <div class="col-sm-6" id="event_type">
                    <select class="form-control" onchange="event_type_onchange()">
                        <option>please select...</option>
                        <option>World Boss</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label for="event_icon" class="col-sm-3 control-label">Event Icon:</label>
                <div class="col-sm-6" id="event_icon">
                    <select class="form-control required">
                        <option>P1</option>
                        <option>P2</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label for="" class="col-sm-3 control-label">Cross World:</label>
                <div class="col-sm-6">
                    <label class="col-sm-2"><input name="cross_world" type="radio" value="False">No</label>
                    <label class="col-sm-2"><input name="cross_world" type="radio" value="True">Yes</label>
                </div>
            </div>

            <div class="form-group">
                <div class="col-sm-offset-3">
                    <button type="submit" class="btn btn-primary"
                        style="padding-left: 30px; padding-right: 30px">Submit</button>
                </div>
            </div>
        </form>
    </div>
</div>


<!-- 窗口2 -->
<div class="modal fade" id="event_type_modal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title">Event Details</h4>
            </div>

            <div class="modal-body">
                <form id="" class="form-horizontal">
                    <div class="form-group">
                        <div class="col-sm-12 " id="add_rank_reward_input">
                            <input type="text" class="form-control" placeholder="example: xxx - xxx; item id; number">
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-sm-1">
                            <button type="button" class="btn btn-primary" onclick="add_rank_reward()">Add Rank
                                Reward</button>
                        </div>
                    </div>
                </form>
            </div>

            <div class="modal-footer">
                <form class="form-horizontal">
                    <!-- <div class="form-group">
                        <strong class="col-sm-3">Gained or Killed:</strong>
                        <div class="col-sm-9 control-label">
                            <p class="col-sm-2"><input name="gained_or_killed" type="radio" value="1">Might Gained</p>
                            <p class="col-sm-2"><input name="gained_or_killed" type="radio" value="2">Troop Killed</p>
                            <p class="col-sm-2"><input name="gained_or_killed" type="radio" value="3">Defense Troop
                                Killed</p>
                        </div>
                    </div> -->

                    <div class="form-group">
                        <strong class="col-sm-3">Individual or Alliance:</strong>
                        <div class="col-sm-9 control-label">
                            <p class="col-sm-2"><input name="individual_or_alliance" type="radio"
                                    value="True">Individual</p>
                            <p class="col-sm-2"><input name="individual_or_alliance" type="radio" value="False">Alliance
                            </p>
                        </div>
                    </div>

                    <!-- <div class="form-group">
                        <strong class="col-sm-3">Glory Divided to Members:</strong>
                        <div class="col-sm-9 control-label">
                            <p class="col-sm-2"><input name="glory_divided_to_members" type="radio" value="True">No</p>
                            <p class="col-sm-2"><input name="glory_divided_to_members" type="radio" value="False">Off
                            </p>
                        </div>
                    </div> -->

                    <!-- <div class="form-group">
                        <strong class="col-sm-3">Only prize members who contribute:</strong>
                        <div class="col-sm-9 control-label">
                            <p class="col-sm-2"><input name="only_prize_members_who_contribute" type="radio"
                                    value="True">No</p>
                            <p class="col-sm-2"><input name="only_prize_members_who_contribute" type="radio"
                                    value="False">Off</p>
                        </div>
                    </div> -->

                    <!-- <div class="form-group">
                        <strong class="col-sm-3">Troop Kill Level Differences:</strong>
                        <div class="col-sm-9">
                            <input id="troop_kill_level_differences" class="form-control" type="text">
                        </div>
                    </div> -->
                </form>
            </div>
        </div>
    </div><!-- /.modal -->
</div>


<!-- 时间控件 -->
<script type="text/javascript">
    $(document).ready(function () {
        $('.form_date').datetimepicker({
            language: 'en-US',
            todayBtn: true,
        });
    });
</script>


<script type="text/javascript">
    var zone_list;
    $(document).ready(function () {
        $.ajax({
            type: "POST",
            url: "/query_zone",
            dataType: 'json',
            success: function (msg) {
                // 急需补充
                zone_list = msg.zone_list;
                $.each(zone_list, function (key, values) {
                    var world = values;
                    $("#world_list_form").append();

                })
            }
        });

        $("#event_info").submit(function () {
            event.preventDefault();

            var server_id_list = [];
            $("#world_list").find("input[type=checkbox]:checked").each(function () {
                server_id_list.push($(this).attr("server_id"));
            })

            var start_time = Date.parse($('#start_time').val()) / 1000;
            var end_time = Date.parse($('#end_time').val()) / 1000;
            var notify_start_time = Date.parse($('#notify_start_time').val()) / 1000;
            var reward_end_time = Date.parse($('#reward_end_time').val()) / 1000;

            var event_icon = $("#event_icon").find(":selected").html();
            var event_type = $("#event_type").find(":selected").html();
            var event_status = $("#event_status").find(":selected").html();
            var priority = $("#priority").find(":selected").html();

            var cross_world = $("input[name='cross_world']:checked").val();
            var alliance_change = $("input[name='alliance_change']:checked").val();
            var auto_reward = $("input[name='auto_reward']:checked").val();

            $.ajax({
                type: "POST",
                url: "/add_event",
                data: {
                    server_id_list: server_id_list,
                    start_time: start_time, end_time: end_time, notify_start_time: notify_start_time, reward_end_time: reward_end_time,
                    event_icon: event_icon, event_type: event_type, event_status: event_status, priority: priority,
                    cross_world: cross_world, alliance_change: alliance_change, auto_reward: auto_reward,
                },
                dataType: 'json',
                success: function (msg) {
                    toastr.options.positionClass = 'toast-top-center';
                    if (msg.err) {
                        toastr.error(msg.err);
                        return;
                    }
                    toastr.success("Successful")
                }
            });


        })

    })
</script>


<script type="text/javascript">
    function event_type_onchange() {
        $('#event_type_modal').modal('show');
    }

    function add_rank_reward() {
        info = '<input type="text" class="form-control" placeholder="example: xxx - xxx; item id; number">'
        $("#add_rank_reward_input").append(info);
    }
</script>