[all:vars]
    ansible_user=haojisheng
    zc_root=/home/haojisheng/hd

# 所有主机
[all_host]
{%- for host in all_host %}
    h_{{host.ip}} ansible_host={{host.ssh_ip}}
{%- endfor %} 

[cluster_router]
    {%- set conf = all_server.singleton_dict.cluster_router %}
    h_cluster_router ansible_host={{conf.ssh_ip}} server_id={{conf.server_id}} config=s{{conf.server_id}}_cluster_router

[world]
    {%- set conf = all_server.singleton_dict.world %}
    h_world ansible_host={{conf.ssh_ip}} server_id={{conf.server_id}} config=s{{conf.server_id}}_world

[gm_router]
    {%- set conf = all_server.singleton_dict.gm_router %}
    h_gm_router ansible_host={{conf.ssh_ip}} server_id={{conf.server_id}} config=s{{conf.server_id}}_gm_router

[login]
{%- for conf in all_server.login_list %}
    h_login_{{conf.server_id}} ansible_host={{conf.ssh_ip}} server_id={{conf.server_id}} config=s{{conf.server_id}}_login
{%- endfor %}

{% for conf in all_server.game_list %}
[game_{{conf.server_id}}]
    h_game_{{conf.server_id}} ansible_host={{conf.ssh_ip}} server_id={{conf.server_id}} config=s{{conf.server_id}}_game
    h_dynasty_{{conf.server_id}} ansible_host={{conf.ssh_ip}} server_id={{conf.server_id}} config=s{{conf.server_id}}_dynasty
    h_chat_{{conf.server_id}} ansible_host={{conf.ssh_ip}} server_id={{conf.server_id}} config=s{{conf.server_id}}_chat 
{% endfor %}

{% for conf in all_server.cross_list %}
[cross_{{conf.server_id}}]
    h_cross_{{conf.server_id}} ansible_host={{conf.ssh_ip}} server_id={{conf.server_id}} config=s{{conf.server_id}}_cross
{% endfor %}



