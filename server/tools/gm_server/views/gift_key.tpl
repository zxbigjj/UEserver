% rebase('base.tpl', child='gift_key', sidemenu='other_mgr')
<link href="static/datetimepicker/css/bootstrap-datetimepicker.css" rel="stylesheet">
<script src="static/datetimepicker/js/bootstrap-datetimepicker.js"></script>
<script src="static/datetimepicker/js/bootstrap-datetimepicker.zh-CN.js"></script>



<div class="panel panel-default">
  <div class="panel-heading">添加礼包码</div>
  <div class="panel-body">
    <form class="form-horizontal" id="form_add_gift_key">
      
     <!-- <div class="form-group">
        <label for="group_name" class="col-sm-1 control-label">礼包前3位:</label>
        <div class="col-sm-2">
          <input type="text" class="form-control" id="group_name">
        </div>
      </div> -->
      <div class="form-group">
        <label for="total_use_count" class="col-sm-1 control-label">礼包码可使用次数:</label>
        <div class="col-sm-2">
          <input type="text" class="form-control" id="total_use_count">
        </div>
      </div>

      

      <div class="form-group">
        <label for="total_count" class="col-sm-1 control-label">礼包码数量:</label>
        <div class="col-sm-2">
          <input type="text" class="form-control" id="total_count">
        </div>
      </div>

       <div class="input-group date form_date form-control" id="add_gift_key_start_ts"
                            data-date="" data-date-format="yyyy/m/d hh:00" data-link-field="dtp_input1"
                            data-link-format="yyyy-mm-dd hh:00">
                            <input class="form-control" type="text" value="" placeholder="开始时间" readonly>
                            <span class="input-group-addon"><span class="glyphicon glyphicon-remove"></span></span>
                            <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
                        </div>
                        <div class="input-group date form_date form-control" id="add_gift_key_end_ts"
                            data-date="" data-date-format="yyyy/m/d hh:00" data-link-field="dtp_input1"
                            data-link-format="yyyy-mm-dd hh:00">
                            <input class="form-control" type="text" value="" placeholder="截止时间" readonly>
                            <span class="input-group-addon"><span class="glyphicon glyphicon-remove"></span></span>
                            <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
                        </div>
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
      <div class="form-group">
        <div class="col-sm-offset-3" >
          <button type="submit"  class="btn btn-primary" onclick="add_gift_key();"style="padding-left: 30px; padding-right: 30px ">添加</button>
          <button type="reset" class="btn btn-primary" style="padding-left: 30px; padding-right: 30px">重置</button>
        </div>
      </div>
      
    </form>
      <form class="form-horizontal" id="query_gift_key">
        <div class="form-group">
        <label for="gift_key" class="col-sm-1 control-label">礼包码:</label>
        <div class="col-sm-2">
          <input type="text" class="form-control" id="gift_key">
        </div>
        <div class="col-sm-offset-3">
          <button id="query_submit" type="submit" class="btn btn-primary"
            style="padding-left: 30px; padding-right: 30px">查询</button>
        </div>
        </div>
        </form>
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
            <tbody id="gift_key_result">

            </tbody>
        </table>
  </div>
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
<script type="text/javascript">

  function isNumber(value) {
    var patrn = /^(-)?\d+(\.\d+)?$/;
    if (patrn.exec(value) == null || value == "") {
      return false
    } else {
      return true
    }
  }

  function skipEmptyElementForArray(arr) {
    var ret = [];
    $.each(arr, function (i, v) {
      var data = $.trim(v);           //$.trim()函数来自jQuery  
      if ('' != data) {
        ret.push(data);
      }
    });
    return ret;
  }

  function itemListForArray() {
    var ret = [];
    for (var i = 1; i < 9; i++) {
      var item_id = $("#item_id_" + i).val()
      var count = $("#count_" + i).val()
      // var is_bind = $("#bind").find(":selected").attr("bind");

      if (isNumber(item_id) && isNumber(count)) {
        // ret.push({ "item_id": item_id, "count": count, "is_binding": is_bind })
        ret.push({ "item_id": item_id, "count": count })
      }
    }
    return ret
  }




    function add_gift_key() {
    $('#form_add_gift_key').unbind('submit');
    $("#form_add_gift_key").submit(function () {
      event.preventDefault();
      
      var total_use_count = $("#total_use_count").val()
      var total_count=$("#total_count").val()
      var gift_key_end_ts   = (Date.parse($('#add_gift_key_end_ts').data().date) / 1000).toString();
      var gift_key_start_ts = (Date.parse($('#add_gift_key_start_ts').data().date) / 1000).toString();
      console.log(gift_key_start_ts)
      var item_list = JSON.stringify(itemListForArray())
      $.ajax({
        type: "POST",
        url: "/add_gift_key",
        data: {
          total_use_count: total_use_count,
          total_count: total_count,
          start_ts: gift_key_start_ts,
          end_ts: gift_key_end_ts,
          item_list: item_list,
          // is_bind: is_bind
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
    }
  
</script>
<script type="text/javascript">
   

    //全局加载
    $(document).ready(function () {
        


        $("#query_gift_key").submit(function () {
            event.preventDefault();
            $("#gift_key_result").find("tr").remove();
            //var server_id = $("#server").find(":selected").attr("server_id");
            var gift_key=$("#gift_key").val()
            console.log(1)
            $.ajax({
                type: "POST",
                url: "/query_gift_key",
                data: {
                  gift_key: gift_key,
                  },
                dataType: 'json',
                success: function (msg) {
                    console.log(msg)    // Test
                    toastr.options.positionClass = 'toast-top-center';
                    if (msg.err) {
                        toastr.error(msg.err);
                        return;
                    }
                    
                    
                        var tr = "<tr>"
                        $.each(msg.info, function (key, val) {
                            if (key == "total_use_count") { tr += "<td>礼包码可使用次数: " + val + "</td>" }
                            if (key == "use_count") { tr += "<td>礼包码已使用次数: " + val + "</td>" }
                            if (key == "end_ts") { tr += "<td>结束时间:  " + new Date(val * 1000).format("yyyy-MM-dd EE HH:mm:ss") + "</td>" }
                            if (key == "start_ts") { tr += "<td>开始时间:  " + new Date(val * 1000).format("yyyy-MM-dd EE HH:mm:ss") + "</td>" }
                        })
                        tr += "</tr>"
                        console.log(tr);
                        $("#gift_key_result").append(tr);
                    
                }
            });
        })
    })
</script>