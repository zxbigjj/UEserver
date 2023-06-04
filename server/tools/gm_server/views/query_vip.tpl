% rebase('base.tpl', child='query_vip', sidemenu='other_mgr')
<link href="static/datetimepicker/css/bootstrap-datetimepicker.css" rel="stylesheet">
<script src="static/datetimepicker/js/bootstrap-datetimepicker.js"></script>
<script src="static/datetimepicker/js/bootstrap-datetimepicker.zh-CN.js"></script>

<link rel="stylesheet" href="static/bootstrap-table/bootstrap-table.min.css">
<script src="static/bootstrap-table/bootstrap-table.min.js"></script>


<!-- 窗口1 -->
<div class="panel panel-default">
    <div class="panel-heading">
        充值查询
    </div>

    <div class="panel-body">
        <form class="form-horizontal" id="query_vip">
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
                    <button id="query_charge_btn" type="button" class="btn btn-primary" onclick="query_charge();"
                        style="padding-left: 30px; padding-right: 30px">查询</button>
                </div>
            </div>
        </form>
    </div>

    <div class="panel-body">
        <table id="charge_info_table"></table>
    </div>
</div>

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


<!-- 控件2 -->
<script>
    function query_charge() {
        var server_id = $("#query_vip").find("#server").val();
        console.log(server_id);

        $.ajax({
            type: "post",
            url: "/query_charge_info",
            data: { server_id: server_id },
            success: function (msg) {
                toastr.options.positionClass = "toast-top-center";
                if (msg.err) { toastr.error(msg.err); return }
                console.log(msg);
                $("#charge_info_table").bootstrapTable({
                    striped: true,
                    cache: false,
                    customSearch: true,
                    pagination: true,
                    pageNumber: 1,
                    sidePagination: 'client',
                    pageList: [10, 20, 50],
                    data: msg.info.form,
                    columns: [{
                        field: "transaction_id",
                        title: "订单号",
                        width: 50,
                        widthUnit: "%"
                    }, {
                        field: "unit_price",
                        title: "金额",
                        width: 25,
                        widthUnit: "%"
                    }, {
                        field: "order_id",
                        title: "时间",
                        width: 25,
                        widthUnit: "%"
                    }]
                });

                alert("已充值总数：" + msg.info.sum[0].sum + " 平台币");
            }
        });
    }
</script>