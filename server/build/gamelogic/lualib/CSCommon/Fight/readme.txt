发送战斗记录函数
send_event_func(event_type, ...)
参数具体信息
event_type : 事件类型

RoundStart : round_num
SpellStart : side, pos, spell_id, anger_diff
SpellHit : side, pos, hit_times, hp_diff, is_crit, is_miss, is_second_kill
SpellEnd : side, pos, spell_id
AngerChange : side, pos, anger_diff
AddBuff : side, pos, buff_id
TriggerBuff : side, pos, buff_id, hp_diff, add_state
RemoveBuff : side, pos, buff_id, remove_state
RoundEnd : round_num
GameEnd : is_win
Immune : side, pos, state

side  阵营
pos  位置
round_num  当前回合数
hp_diff   血量变化（负数表示受伤害，正数表示回血）
buff_id
add_state   增加buff附加状态
remove_state  移除buff附加状态
spell_id  释放技能id
anger_diff  怒气变化（负数表示消耗，正数表示增加）
is_second_kill 是否秒杀
----------------------------------------------------------------------
参数需求
fight_data = {   dict值
    is_pvp  是否是pvp，bool值
    victory_id  胜利条件ID，int值 （没有nil）
    seed  随机种子，int值
    own_fight_data = {    我方阵营数据，list
        [1] = {  第一个位置 （该位置没人，空表）
            unit_id
            score  战力
            spell_dict = {[spell_id] = spell_level}  主动技能
            buff_list = {{buff_id = , buff_level = }, ...}
            fight_attr_dict = {}  战斗属性
        }
        [2] = {  第二个位置
            ...
        }
        ...
    }
    enemy_fight_data = {  敌方阵营数据，list
        ...
    }
}

send_event_func  客户端事件回调函数