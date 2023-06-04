% rebase('base.tpl', child='sys_mail', sidemenu='mail_mgr')
<link href="static/datetimepicker/css/bootstrap-datetimepicker.css" rel="stylesheet">
<script src="static/datetimepicker/js/bootstrap-datetimepicker.js"></script>
<script src="static/datetimepicker/js/bootstrap-datetimepicker.zh-CN.js"></script>


<div class="panel panel-default">
  <div class="panel-heading">添加邮件</div>
  <div class="panel-body">
    <form class="form-horizontal" id="add_mail">
      <div class="form-group">
        <label for="title" class="col-sm-1 control-label">标题:</label>
        <div class="col-sm-2">
          <input type="text" class="form-control" id="title">
        </div>
      </div>

      <div class="form-group">
        <label for="content" class="col-sm-1 control-label">内容:</label>
        <div class="col-sm-2">
          <input type="text" class="form-control" id="content">
        </div>
      </div>


      <!-- 道具 -->
      <div class="form-group">
        <!-- % i=1 -->
        % for i in range(1,5):
        <label for="item_id_{{i+1}}" class="col-sm-1 control-label">道具{{i}}:</label>
        <div class="col-sm-2">
          <input type="text" class="form-control" id="item_id_{{i}}">
        </div>
        <label for="count_{{i}}" class="col-sm-1 control-label">数量{{i}}:</label>
        <div class="col-sm-2">
          <input type="text" class="form-control" id="count_{{i}}">
        </div>
        % end
      </div>


      <!-- 大区 -->
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


      <!-- 补偿开始时间 -->
      <div class="form-group">
        <label for="begin_time" class="col-sm-1 control-label">补偿开始时间</label>
        <div class="col-sm-2">
          <div class="input-group date form_date form-control" id="sys_mail_begin_time" data-date=""
            data-date-format="yyyy/m/d hh:00" data-link-field="dtp_input1" data-link-format="yyyy-mm-dd hh:00">
            <input class="form-control" size="100" type="text" value="" placeholder="精确到小时" readonly>
            <span class="input-group-addon"><span class="glyphicon glyphicon-remove"></span></span>
            <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
          </div>
        </div>
        <label for="end_time" class="col-sm-1 control-label">补偿截止时间</label>
        <div class="col-sm-2">
          <div class="input-group date form_date form-control" id="sys_mail_end_time" data-date=""
            data-date-format="yyyy/m/d hh:00" data-link-field="dtp_input1" data-link-format="yyyy-mm-dd hh:00">
            <input class="form-control" size="100" type="text" value="" placeholder="精确到小时" readonly>
            <span class="input-group-addon"><span class="glyphicon glyphicon-remove"></span></span>
            <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
          </div>
        </div>
      </div>


      <!-- 等级限制 -->
      <div class="form-group">
        <label for="level" class="col-sm-1 control-label">最低等级</label>
        <div class="col-sm-2">
          <input type="text" class="form-control" id="min_level">
        </div>
      </div>

      <div class="form-group">
        <label for="level" class="col-sm-1 control-label">最高等级</label>
        <div class="col-sm-2">
          <input type="text" class="form-control" id="max_level">
        </div>
      </div>


      <!-- 是否全平台 -->
      <div class="form-group">
        <label for="platform" class="col-sm-1 control-label">全平台</label>
        <div class="col-sm-2">
          <label><input name="is_all_channel" type="radio" value="True" />是</label>
          <br />
          <label><input name="is_all_channel" type="radio" value="False" />否</label>
        </div>
      </div>


      <div class="form-group">
        <label for="platform" class="col-sm-1 control-label">平台</label>
        <div class="col-sm-2">
          <label><input name="channel" type="radio" value="android" />安卓</label>
          <br />
          <label><input name="channel" type="radio" value="ios" />IOS</label>
        </div>
      </div>


      <div class="form-group">
        <div class="col-sm-offset-3">
          <button type="submit" class="btn btn-primary" style="padding-left: 30px; padding-right: 30px">添加</button>
          <button type="reset" class="btn btn-primary" style="padding-left: 30px; padding-right: 30px">重置</button>
        </div>
      </div>
    </form>
  </div>
</div>



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
<!-- 查询角色 -->
<script type="text/javascript">
  var zone_list;

  /********************大区,服务器部分********************/
  function on_zone_change() {
    $("#server").find("option").remove()
    var area_name = $("#zone").val()
    $.each(zone_list, function (key, values) {
      
      var zone = values;
      console.log(values.server_id)
      if (zone.area_name == area_name) {
        var option = '<option server_id="' + zone.server_id + '">' + zone.server_id + "</option>"
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
        console.log(msg)
        zone_list=msg.info
        $.each(msg.info, function (key, values) {
          if ( values.running_state) {
          $("#zone").append("<option>" + values.area_name + "</option>");
          }
        })
        
        on_zone_change();
      }
    });
  })

$("#zone").change(on_zone_change);

</script>

</script>
<script type="text/javascript">
  var zone_list;


  

  function isNumber(value) {
    var patrn = /^(-)?\d+(\.\d+)?$/;
    if (patrn.exec(value) == null || value == "") {
      return false
    } else {
      return true
    }
  }

  function itemListForArray() {
    var ret = [];
    for (var i = 1; i < 9; i++) {
      var item_id = $("#item_id_" + i).val()
      var count = $("#count_" + i).val()
      if (isNumber(item_id) && isNumber(count)) {
        ret.push({ "item_id": item_id, "count": count })
      }
    }
    return ret
  }

  function get_server_id() {
    var server_id = $("#server").val().replace(/[^0-9]/ig, "")
    return server_id
  }

  

    /***************** 大区,服务器部分 END *****************/

    $("#add_mail").submit(function () {
      // 参数获取
      event.preventDefault();
      var title = $("#title").val()
      var content = $("#content").val()
      var is_all_channel = $('input:radio[name="is_all_channel"]:checked').val()  // err
      var server_id = get_server_id()
      var item_list = JSON.stringify(itemListForArray())
      var channel = $('input:radio[name="channel"]:checked').val()  // err

      var sys_mail_begin_time_stamp = Date.parse($('#sys_mail_begin_time').data().date).toString();
      var sys_mail_begin_time = sys_mail_begin_time_stamp.substr(0, sys_mail_begin_time_stamp.length - 3);

      if (sys_mail_begin_time == null || sys_mail_begin_time == "") {
        toastr.options.positionClass = 'toast-top-center';
        toastr.error("请选择补偿开始时间");
        return;
      }

      var sys_mail_end_time_stamp = Date.parse($('#sys_mail_end_time').data().date).toString();
      var sys_mail_end_time = sys_mail_end_time_stamp.substr(0, sys_mail_end_time_stamp.length - 3);

      console.log(sys_mail_end_time)

      if (sys_mail_end_time == null || sys_mail_end_time == "") {
        toastr.options.positionClass = 'toast-top-center';
        toastr.error("请选择补偿截止时间");
        return;
      }

      $.ajax({
        type: "POST",
        url: "/add_mail_sys",

        data: {
          title: title,
          content: content,
          server_id: server_id,
          item_list: item_list,
          channel: channel,
          is_all_channel: is_all_channel,
          sys_mail_begin_time: sys_mail_begin_time,
          sys_mail_end_time: sys_mail_end_time,
        },

        dataType: 'json',
        success: function (msg) {
          toastr.options.positionClass = 'toast-top-center';
          if (msg.err) {
            toastr.error(msg.err);
            return;
          }
          toastr.success("操作成功")
        }
      })
    })

</script>