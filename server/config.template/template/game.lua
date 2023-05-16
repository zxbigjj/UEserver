root = "./"
thread = 8
logger = nil
harbor = 0
start = "game_launcher"

gamedb = 'hd_game{{server_id}}'
login_port = {{login_port}}
ssl_login_port = {{ssl_login_port}}
-- login并发优化
LOGIN_MAX_CONNECTION       = 102400
LOGIN_CONCURRENCY     = 500

{% include "_common.lua" %}