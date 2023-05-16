% rebase('base.tpl', child='version', sidemenu='player_mgr')
<link href="static/datetimepicker/css/bootstrap-datetimepicker.css" rel="stylesheet">
<script src="static/datetimepicker/js/bootstrap-datetimepicker.js"></script>
<script src="static/datetimepicker/js/bootstrap-datetimepicker.zh-CN.js"></script>


<!-- 窗口1 -->
<div class="panel panel-default">
    <div class="panel-heading">
        <h3 class="panel-title">版本控制</h3>
    </div>
    <div class="panel-body">
        <form class="form-horizontal" role="form" id="version_ctl">
            <div class="form-group">
                <legend>Android</legend>
            </div>

            <div class="form-group">
                <p class="col-sm-2">URL：</p>
                <div class="col-sm-10">
                    <input type="text" name="" id="android_url" class="form-control">
                </div>
            </div>

            <div class="form-group">
                <p class="col-sm-2">版本号：</p>
                <div class="col-sm-10">
                    <input type="text" name="" id="android_version" maxlength="32" class="form-control">
                </div>
            </div>

            <div class="form-group">
                <legend>IOS</legend>
            </div>

            <div class="form-group">
                <p class="col-sm-2">URL：</p>
                <div class="col-sm-10">
                    <input type="text" name="" id="ios_url" class="form-control">
                </div>
            </div>

            <div class="form-group">
                <p class="col-sm-2">版本号：</p>
                <div class="col-sm-10">
                    <input type="text" name="" id="ios_version" maxlength="32" class="form-control">
                </div>
            </div>

            <div class="form-group">
                <legend></legend>
            </div>

            <div class="form-group">
                <p class="col-sm-2">是否强制更新：</p>
                <div class="col-sm-10">
                    <select name="" id="forced_update" class="form-control" onchange="forced_update_onchange();">
                        <option value="0">否</option>
                        <option value="1">是</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <div class="col-sm-10 col-sm-offset-2">
                    <button type="button" class="btn btn-primary" onclick="update_version();">更新</button>
                </div>
            </div>
        </form>
    </div>
</div>


<!-- 窗口2 -->
<div class="modal fade" id="context_model" tabindex="-1" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title">通知信息</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal">
                    <div class="form-group">
                        <div class="col-sm-12">
                            <textarea name="" id="context" rows="10" class="form-control"></textarea>
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-sm-10 offset-3">
                            <button type="button" class="btn btn-primary" onclick="context_model_onclick();">确定</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>


<!-- 控件 -->
<script>
    $(document).ready(function () {
        $.ajax({
            type: 'GET',
            url: '/query_version',
            success: function (msg) {
                console.log(msg)
                $('#android_url').val(msg.android.url);
                $('#android_version').val(msg.android.version);
                $('#ios_url').val(msg.ios.url);
                $('#ios_version').val(msg.ios.version);
                $('#forced_update').val(msg.android.state);
                $('#context_model').find('textarea').val(msg.android.context);
            }
        })
    })

    function update_version() {
        var android_url = $('#android_url').val();
        var android_version = $('#android_version').val();
        var ios_url = $('#ios_url').val();
        var ios_version = $('#ios_version').val();
        var context = $('#context_model').find('textarea').val();
        var state = $('#forced_update').find(':selected').val();

        $.ajax({
            type: 'POST',
            url: '/update_version',
            data: {
                android_url: android_url, android_version: android_version,
                ios_url: ios_url, ios_version: ios_version,
                state: state, context: context
            },
            dataType: 'JSON',
            success: function (msg) {
                toastr.options.positionClass = 'toast-top-center';
                if (msg.info) {
                    toastr.success(msg.info);
                } else {
                    toastr.error(msg.err);
                }
            }
        })
    }

    function forced_update_onchange() {
        var is_forced_update = $('#forced_update').find(':selected').val();

        if (is_forced_update == '0') {
            $('#context_model').find('textarea').val('');
        } else {
            $('#context_model').modal('show');
        }
    }

    function context_model_onclick() {
        $('#context_model').modal('hide');
    }
</script>