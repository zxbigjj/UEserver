% rebase('base.tpl', child='role_mail', sidemenu='mail_mgr')
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
        <label for="server_id" class="col-sm-1 control-label">服务器ID:</label>
        <div class="col-sm-2">
          <input type="text" class="form-control" id="server_id">
        </div>
      </div>

      <div class="form-group">
        <label for="uid" class="col-sm-1 control-label">UID:</label>
        <div class="col-sm-2">
          <input type="text" class="form-control" id="uids">
        </div>
      </div>

      <div class="form-group">
        <label for="name" class="col-sm-1 control-label">角色名:</label>
        <div class="col-sm-2">
          <input type="text" class="form-control" id="name">
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

  $(document).ready(function () {
    $("#add_mail").submit(function () {
      event.preventDefault();
      var title = $("#title").val()
      var content = $("#content").val()
      var uids = $("#uids").val()
      var server_id = $("#server_id").val()
      var arr_uuids = JSON.stringify(skipEmptyElementForArray(uids.split('\n')))
      var item_list = JSON.stringify(itemListForArray())
      $.ajax({
        type: "POST",
        url: "/add_mail_role",
        data: {
          title: title,
          content: content,
          server_id: server_id,
          arr_uuids: arr_uuids,
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
  })
</script>