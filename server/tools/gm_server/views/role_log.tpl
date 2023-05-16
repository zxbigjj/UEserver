% rebase('base.tpl', child='role_log', sidemenu='')
<h1>欢迎</h1>
<h4 id="date"></h4>

<script>
    $.document.ready(function () {
        $("#date").html(new Date(1646661600000 * 1000).format("yyyy-MM-dd EE HH:mm:ss"));
    })

</script>