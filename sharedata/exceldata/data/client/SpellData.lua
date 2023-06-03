return {
    [ 11101101 ] = {
        [ "id" ] = 11101101,
        [ "ch_key" ] = "裁决",
        [ "name" ] = "裁决",
        [ "desc" ] = "对敌方怒气最高的3个敌人造成65%伤害，20%概率减少2点怒气",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 2,
        [ "spell_hurt_pct" ] = 65,
        [ "hurt_grow_rate" ] = 0,
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.2,
    },
    [ 11101102 ] = {
        [ "id" ] = 11101102,
        [ "ch_key" ] = "静电打击",
        [ "name" ] = "静电打击",
        [ "icon" ] = 511305214,
        [ "desc" ] = "对敌方怒气最高的3个敌人造成175%伤害$destiny，50%概率减少2点怒气，我方全体闪避提高10%，持续2回合。",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 2,
        [ "spell_hurt_pct" ] = 175,
        [ "hurt_grow_rate" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000049,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 3,
        },
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.5,
    },
    [ 11101103 ] = {
        [ "id" ] = 11101103,
        [ "ch_key" ] = "过载脉冲",
        [ "name" ] = "过载脉冲",
        [ "icon" ] = 511305208,
        [ "desc" ] = "对敌方怒气最高的3个敌人造成227%伤害$destiny，80%概率减少2点怒气，我方全体闪避提高15%，持续2回合。【与$unit共同出战可触发，由科尔特发动】",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 11011,
        [ "spell_unit_list" ] = {
            [ 1 ] = 11043,
        },
        [ "first_spell_hero" ] = 11011,
        [ "second_spell_hero" ] = 11041,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 7 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 2,
        [ "spell_hurt_pct" ] = 227,
        [ "hurt_grow_rate" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000046,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 3,
        },
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.8,
    },
    [ 11101104 ] = {
        [ "id" ] = 11101104,
        [ "ch_key" ] = "超·过载脉冲",
        [ "name" ] = "超·过载脉冲",
        [ "icon" ] = 511305208,
        [ "desc" ] = "对敌方怒气最高的3个敌人造成245%伤害$destiny，减少2点怒气，我方全体闪避提高20%，持续2回合。【与$unit共同出战可触发，由科尔特发动】",
        [ "spell_type" ] = 4,
        [ "super_spell_id" ] = 11101104,
        [ "spell_unit" ] = 11011,
        [ "spell_unit_list" ] = {
            [ 1 ] = 11043,
        },
        [ "first_spell_hero" ] = 11011,
        [ "second_spell_hero" ] = 11041,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 7 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 2,
        [ "spell_hurt_pct" ] = 245,
        [ "hurt_grow_rate" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000075,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 3,
        },
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 1,
    },
    [ 11101201 ] = {
        [ "id" ] = 11101201,
        [ "ch_key" ] = "镭击",
        [ "name" ] = "镭击",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 9,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11101202 ] = {
        [ "id" ] = 11101202,
        [ "ch_key" ] = "电能冲击",
        [ "name" ] = "电能冲击",
        [ "icon" ] = 51101202,
        [ "desc" ] = "对前排敌人造成152%伤害$destiny，本次攻击的暴击率上升40%",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.1,
            },
        },
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "crit",
                [ "attr_value" ] = 0.4,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 152,
        [ "hurt_grow_rate" ] = 3,
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.4,
        },
    },
    [ 11102201 ] = {
        [ "id" ] = 11102201,
        [ "ch_key" ] = "劲矢",
        [ "name" ] = "劲矢",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11102202 ] = {
        [ "id" ] = 11102202,
        [ "ch_key" ] = "猎杀本能",
        [ "name" ] = "猎杀本能",
        [ "icon" ] = 511106116,
        [ "desc" ] = "对前排敌人造成152%伤害，20%概率降低敌人攻击30%，持续2回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 152,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000064,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.2,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
    [ 11103101 ] = {
        [ "id" ] = 11103101,
        [ "ch_key" ] = "凶星",
        [ "name" ] = "凶星",
        [ "desc" ] = "对一列敌人造成80%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.2,
            },
        },
        [ "attack_type" ] = 3,
        [ "spell_hurt_pct" ] = 80,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11103102 ] = {
        [ "id" ] = 11103102,
        [ "ch_key" ] = "军火仲裁",
        [ "name" ] = "军火仲裁",
        [ "icon" ] = 51103102,
        [ "desc" ] = "对所有敌人造成111%伤害$destiny，自身的闪避率提高30%，持续2回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 111,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000011,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
        },
    },
    [ 11103103 ] = {
        [ "id" ] = 11103103,
        [ "ch_key" ] = "枪林刃雨",
        [ "name" ] = "枪林刃雨",
        [ "icon" ] = 51103103,
        [ "desc" ] = "对所有敌人造成144%伤害$destiny，自身的伤害提高40%，闪避率提高40%，持续2回合【与$unit共同出战可触发，由代号：六发动】",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 11031,
        [ "spell_unit_list" ] = {
            [ 1 ] = 11051,
        },
        [ "first_spell_hero" ] = 11031,
        [ "second_spell_hero" ] = 11051,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 7 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 8 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 9 ] = {
                [ "hurt_rate" ] = 0.2,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 144,
        [ "hurt_grow_rate" ] = 4,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000013,
            [ 2 ] = 20000012,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 3,
            [ 2 ] = 1,
        },
    },
    [ 11103201 ] = {
        [ "id" ] = 11103201,
        [ "ch_key" ] = "压制",
        [ "name" ] = "压制",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11103202 ] = {
        [ "id" ] = 11103202,
        [ "ch_key" ] = "烈焰回声",
        [ "name" ] = "烈焰回声",
        [ "icon" ] = 51103203,
        [ "desc" ] = "对单个敌人造成300%伤害$destiny，75%概率造成眩晕",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.4,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 300,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.75,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
    [ 11104201 ] = {
        [ "id" ] = 11104201,
        [ "ch_key" ] = "痛殴",
        [ "name" ] = "痛殴",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11104202 ] = {
        [ "id" ] = 11104202,
        [ "ch_key" ] = "亿吨重拳",
        [ "name" ] = "亿吨重拳",
        [ "icon" ] = 51104202,
        [ "desc" ] = "对前排敌人造成152%伤害$destiny，自身受到伤害降低55%，持续2回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 152,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000009,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
        },
    },
    [ 11104203 ] = {
        [ "id" ] = 11104203,
        [ "ch_key" ] = "狂乱蹂躏",
        [ "name" ] = "狂乱蹂躏",
        [ "icon" ] = 51104203,
        [ "desc" ] = "对后排敌人造成185%伤害$destiny，自身受到伤害降低55%，我方全体头目抗暴率+30%，持续2回合【与$unit共同出战可触发，由亨利发动】",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 11042,
        [ "spell_unit_list" ] = {
            [ 1 ] = 11032,
        },
        [ "first_spell_hero" ] = 11042,
        [ "second_spell_hero" ] = 11032,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.4,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "attack_type" ] = 5,
        [ "spell_hurt_pct" ] = 185,
        [ "hurt_grow_rate" ] = 4,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000009,
            [ 2 ] = 20000010,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 3,
        },
    },
    [ 11104311 ] = {
        [ "id" ] = 11104311,
        [ "ch_key" ] = "血疗",
        [ "name" ] = "血疗",
        [ "desc" ] = "治疗全体友军（48%+150）",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 2,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "attack_type" ] = 1,
        [ "fixed_hurt" ] = 150,
        [ "spell_hurt_pct" ] = 48,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11104312 ] = {
        [ "id" ] = 11104312,
        [ "ch_key" ] = "愈合激素",
        [ "name" ] = "愈合激素",
        [ "icon" ] = 511305220,
        [ "desc" ] = "治疗全体友军（116%+250），80%概率清除（抵抗1级清除）我方所有不利状态，本次治疗的暴击率提升10%",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 2,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "crit",
                [ "attr_value" ] = 0.1,
            },
        },
        [ "attack_type" ] = 1,
        [ "fixed_hurt" ] = 250,
        [ "spell_hurt_pct" ] = 116,
        [ "hurt_grow_rate" ] = 2,
        [ "buff_clear_level" ] = 1,
        [ "buff_clear_ratio" ] = 0.8,
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.1,
        },
    },
    [ 11105101 ] = {
        [ "id" ] = 11105101,
        [ "ch_key" ] = "刃返",
        [ "name" ] = "刃返",
        [ "desc" ] = "对前排敌人造成70%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 1,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.4,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.3,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 70,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11105102 ] = {
        [ "id" ] = 11105102,
        [ "ch_key" ] = "秘·居合",
        [ "name" ] = "秘·居合",
        [ "icon" ] = 51105102,
        [ "desc" ] = "对前排敌人造成159%伤害$destiny，19%概率造成眩晕",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.4,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.1,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 159,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.19,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
    [ 11105103 ] = {
        [ "id" ] = 11105103,
        [ "ch_key" ] = "刃返1",
        [ "name" ] = "刃返1",
        [ "desc" ] = "对前排敌人造成70%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 1,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 70,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11105104 ] = {
        [ "id" ] = 11105104,
        [ "ch_key" ] = "秘·居合1",
        [ "name" ] = "秘·居合1",
        [ "icon" ] = 51105102,
        [ "desc" ] = "对前排敌人造成159%伤害$destiny，19%概率造成眩晕",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 159,
        [ "hurt_grow_rate" ] = 3,
        [ "is_second_kill" ] = true,
    },
    [ 11105201 ] = {
        [ "id" ] = 11105201,
        [ "ch_key" ] = "猛踢",
        [ "name" ] = "猛踢",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11105202 ] = {
        [ "id" ] = 11105202,
        [ "ch_key" ] = "致命律动",
        [ "name" ] = "致命律动",
        [ "icon" ] = 51105202,
        [ "desc" ] = "对前排敌人造成152%伤害$destiny",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 152,
        [ "hurt_grow_rate" ] = 3,
    },
    [ 11105203 ] = {
        [ "id" ] = 11105203,
        [ "ch_key" ] = "末路逆袭",
        [ "name" ] = "末路逆袭",
        [ "icon" ] = 511106118,
        [ "desc" ] = "对前排敌人造成197%伤害$destiny，我方全体头目的闪避率提高15%，持续2回合【与$unit共同出战可触发，由贝蒂发动】",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 11052,
        [ "spell_unit_list" ] = {
            [ 1 ] = 14051,
        },
        [ "first_spell_hero" ] = 11052,
        [ "second_spell_hero" ] = 14051,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 197,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000046,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 3,
        },
    },
    [ 11106101 ] = {
        [ "id" ] = 11106101,
        [ "ch_key" ] = "侵扰",
        [ "name" ] = "侵扰",
        [ "desc" ] = "对单个敌人造成100%伤害，20%概率减少1怒气",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 6,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
        [ "reduce_anger" ] = 1,
        [ "reduce_anger_level" ] = 1,
        [ "reduce_anger_ratio" ] = 0.2,
    },
    [ 11106102 ] = {
        [ "id" ] = 11106102,
        [ "ch_key" ] = "贯穿之矢",
        [ "name" ] = "贯穿之矢",
        [ "icon" ] = 511106109,
        [ "desc" ] = "对一列敌人造成232%伤害$destiny，减少1点怒气",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 3,
        [ "spell_hurt_pct" ] = 232,
        [ "hurt_grow_rate" ] = 3,
        [ "reduce_anger" ] = 1,
        [ "reduce_anger_level" ] = 1,
        [ "reduce_anger_ratio" ] = 1,
    },
    [ 11106201 ] = {
        [ "id" ] = 11106201,
        [ "ch_key" ] = "暴怒",
        [ "name" ] = "暴怒",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 9,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11106202 ] = {
        [ "id" ] = 11106202,
        [ "ch_key" ] = "终极爆弹",
        [ "name" ] = "终极爆弹",
        [ "icon" ] = 511305210,
        [ "desc" ] = "对一列敌人造成221%伤害$destiny，50%概率降低敌人防御60%，持续1回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 3,
        [ "spell_hurt_pct" ] = 221,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000008,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.5,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
    [ 11106203 ] = {
        [ "id" ] = 11106203,
        [ "ch_key" ] = "火力全开",
        [ "name" ] = "火力全开",
        [ "icon" ] = 51106203,
        [ "desc" ] = "对前排敌人造成197%伤害$destiny，本次攻击的暴击率和命中率上升65%【与$unit共同出战可触发，由阿尔法发动】",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 11062,
        [ "spell_unit_list" ] = {
            [ 1 ] = 11012,
        },
        [ "first_spell_hero" ] = 11062,
        [ "second_spell_hero" ] = 11012,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 7 ] = {
                [ "hurt_rate" ] = 0.7,
            },
        },
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "crit",
                [ "attr_value" ] = 0.65,
            },
            [ 2 ] = {
                [ "attr_name" ] = "hit",
                [ "attr_value" ] = 0.65,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 197,
        [ "hurt_grow_rate" ] = 4,
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.65,
            [ "hit" ] = 0.65,
        },
    },
    [ 11106204 ] = {
        [ "id" ] = 11106204,
        [ "ch_key" ] = "火力全开1",
        [ "name" ] = "火力全开1",
        [ "icon" ] = 511305210,
        [ "desc" ] = "暂无",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
        [ "is_second_kill" ] = true,
    },
    [ 11106205 ] = {
        [ "id" ] = 11106205,
        [ "ch_key" ] = "超·火力全开2",
        [ "name" ] = "超·火力全开2",
        [ "icon" ] = 51106203,
        [ "desc" ] = "对前排敌人造成197%伤害$destiny，本次攻击的暴击率和命中率上升65%【与$unit共同出战可触发，由阿尔法发动】",
        [ "spell_type" ] = 4,
        [ "super_spell_id" ] = 11106205,
        [ "spell_unit" ] = 11062,
        [ "spell_unit_list" ] = {
            [ 1 ] = 11012,
        },
        [ "first_spell_hero" ] = 11062,
        [ "second_spell_hero" ] = 11012,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 7 ] = {
                [ "hurt_rate" ] = 0.7,
            },
        },
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "crit",
                [ "attr_value" ] = 0.65,
            },
            [ 2 ] = {
                [ "attr_name" ] = "hit",
                [ "attr_value" ] = 0.65,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 197,
        [ "hurt_grow_rate" ] = 4,
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.65,
            [ "hit" ] = 0.65,
        },
    },
    [ 11106206 ] = {
        [ "id" ] = 11106206,
        [ "ch_key" ] = "暴怒1",
        [ "name" ] = "暴怒1",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 1,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 9,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11110211 ] = {
        [ "id" ] = 11110211,
        [ "ch_key" ] = "暴走",
        [ "name" ] = "暴走",
        [ "desc" ] = "对所有敌人造成40%伤害，本次攻击命中率和暴击率额外提升30%",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "crit",
                [ "attr_value" ] = 0.3,
            },
            [ 2 ] = {
                [ "attr_name" ] = "hit",
                [ "attr_value" ] = 0.3,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 40,
        [ "hurt_grow_rate" ] = 0,
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.3,
            [ "hit" ] = 0.3,
        },
    },
    [ 11110212 ] = {
        [ "id" ] = 11110212,
        [ "ch_key" ] = "裂地重锤",
        [ "name" ] = "裂地重锤",
        [ "icon" ] = 511110112,
        [ "desc" ] = "对所有敌人造成115%伤害$destiny，10%概率造成眩晕，本次攻击命中率和暴击率额外提升30%",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "crit",
                [ "attr_value" ] = 0.3,
            },
            [ 2 ] = {
                [ "attr_name" ] = "hit",
                [ "attr_value" ] = 0.3,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 115,
        [ "hurt_grow_rate" ] = 2,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.3,
            [ "hit" ] = 0.3,
        },
    },
    [ 11110213 ] = {
        [ "id" ] = 11110213,
        [ "ch_key" ] = "区域肃清",
        [ "name" ] = "区域肃清",
        [ "icon" ] = 511305219,
        [ "desc" ] = "对所有敌人造成149%伤害$destiny，15%概率造成眩晕，本次攻击命中率和暴击率额外提升50%【与$unit共同出战可触发，由亚当触发】",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 11021,
        [ "spell_unit_list" ] = {
            [ 1 ] = 11061,
        },
        [ "first_spell_hero" ] = 11021,
        [ "second_spell_hero" ] = 11061,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.6,
            },
        },
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "crit",
                [ "attr_value" ] = 0.5,
            },
            [ 2 ] = {
                [ "attr_name" ] = "hit",
                [ "attr_value" ] = 0.5,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 149,
        [ "hurt_grow_rate" ] = 2,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.15,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.5,
            [ "hit" ] = 0.5,
        },
    },
    [ 11110214 ] = {
        [ "id" ] = 11110214,
        [ "ch_key" ] = "超·区域肃清",
        [ "name" ] = "超·区域肃清",
        [ "icon" ] = 511305219,
        [ "desc" ] = "对所有敌人造成161%伤害$destiny，20%概率造成眩晕，本次攻击必命中和必暴击率【与$unit共同出战可触发，由亚当触发】",
        [ "spell_type" ] = 4,
        [ "super_spell_id" ] = 11110214,
        [ "spell_unit" ] = 11021,
        [ "spell_unit_list" ] = {
            [ 1 ] = 11061,
        },
        [ "first_spell_hero" ] = 11021,
        [ "second_spell_hero" ] = 11061,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.6,
            },
        },
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "crit",
                [ "attr_value" ] = 1,
            },
            [ 2 ] = {
                [ "attr_name" ] = "hit",
                [ "attr_value" ] = 1,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 161,
        [ "hurt_grow_rate" ] = 2,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.2,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 1,
            [ "hit" ] = 1,
        },
    },
    [ 11110215 ] = {
        [ "id" ] = 11110215,
        [ "ch_key" ] = "暴走1",
        [ "name" ] = "暴走1",
        [ "desc" ] = "对所有敌人造成40%伤害，本次攻击命中率和暴击率额外提升30%",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 1,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "crit",
                [ "attr_value" ] = 0.3,
            },
            [ 2 ] = {
                [ "attr_name" ] = "hit",
                [ "attr_value" ] = 0.3,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 40,
        [ "hurt_grow_rate" ] = 0,
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.3,
            [ "hit" ] = 0.3,
        },
    },
    [ 11110216 ] = {
        [ "id" ] = 11110216,
        [ "ch_key" ] = "裂地重锤1",
        [ "name" ] = "裂地重锤1",
        [ "icon" ] = 511110112,
        [ "desc" ] = "对所有敌人造成115%伤害$destiny，10%概率造成眩晕，本次攻击命中率和暴击率额外提升30%",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "crit",
                [ "attr_value" ] = 0.3,
            },
            [ 2 ] = {
                [ "attr_name" ] = "hit",
                [ "attr_value" ] = 0.3,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 115,
        [ "hurt_grow_rate" ] = 2,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "is_second_kill" ] = true,
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.3,
            [ "hit" ] = 0.3,
        },
    },
    [ 11140121 ] = {
        [ "id" ] = 11140121,
        [ "ch_key" ] = "低语",
        [ "name" ] = "低语",
        [ "desc" ] = "对后排单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 6,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11140122 ] = {
        [ "id" ] = 11140122,
        [ "ch_key" ] = "死亡通牒",
        [ "name" ] = "死亡通牒",
        [ "icon" ] = 51140122,
        [ "desc" ] = "对后排敌人造成152%伤害$destiny，50%概率减少1点怒气",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.3,
            },
        },
        [ "attack_type" ] = 5,
        [ "spell_hurt_pct" ] = 152,
        [ "hurt_grow_rate" ] = 3,
        [ "reduce_anger" ] = 1,
        [ "reduce_anger_level" ] = 1,
        [ "reduce_anger_ratio" ] = 0.5,
    },
    [ 11140123 ] = {
        [ "id" ] = 11140123,
        [ "ch_key" ] = "死亡通牒1",
        [ "name" ] = "死亡通牒1",
        [ "icon" ] = 51140122,
        [ "desc" ] = "对后排敌人造成197%伤害$destiny，70%概率减少1点怒气，降低敌人攻击20%，持续2回合【与$unit共同出战可触发，由米娅触发】",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 14012,
        [ "spell_unit_list" ] = {
            [ 1 ] = 11022,
        },
        [ "first_spell_hero" ] = 14022,
        [ "second_spell_hero" ] = 11022,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 5,
        [ "spell_hurt_pct" ] = 197,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000063,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "reduce_anger" ] = 1,
        [ "reduce_anger_level" ] = 1,
        [ "reduce_anger_ratio" ] = 0.7,
    },
    [ 11140511 ] = {
        [ "id" ] = 11140511,
        [ "ch_key" ] = "急救",
        [ "name" ] = "急救",
        [ "desc" ] = "治疗生命最少的1个友军（94%+100）",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 2,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 11,
        [ "fixed_hurt" ] = 100,
        [ "spell_hurt_pct" ] = 94,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11140512 ] = {
        [ "id" ] = 11140512,
        [ "ch_key" ] = "治愈之风",
        [ "name" ] = "治愈之风",
        [ "icon" ] = 51140512,
        [ "desc" ] = "治疗全体友军（110%+200）$destiny",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 2,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 1,
        [ "fixed_hurt" ] = 200,
        [ "spell_hurt_pct" ] = 110,
        [ "hurt_grow_rate" ] = 2,
    },
    [ 11201101 ] = {
        [ "id" ] = 11201101,
        [ "ch_key" ] = "挥击",
        [ "name" ] = "挥击",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11201102 ] = {
        [ "id" ] = 11201102,
        [ "ch_key" ] = "怒火链枷",
        [ "name" ] = "怒火链枷",
        [ "icon" ] = 511305217,
        [ "desc" ] = "对一列敌人造成221%伤害$destiny，自身无敌一回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 7 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 8 ] = {
                [ "hurt_rate" ] = 0.65,
            },
        },
        [ "attack_type" ] = 3,
        [ "spell_hurt_pct" ] = 221,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000002,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
        },
    },
    [ 11201103 ] = {
        [ "id" ] = 11201103,
        [ "ch_key" ] = "残忍无情",
        [ "name" ] = "残忍无情",
        [ "icon" ] = 511201103,
        [ "desc" ] = "对一列敌人造成287%伤害$destiny，自身无敌一回合，本次攻击暴击率和命中率提升70%",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 12011,
        [ "spell_unit_list" ] = {
            [ 1 ] = 12032,
        },
        [ "first_spell_hero" ] = 12011,
        [ "second_spell_hero" ] = 12032,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 7 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 8 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 9 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 10 ] = {
                [ "hurt_rate" ] = 0.25,
            },
        },
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "crit",
                [ "attr_value" ] = 0.7,
            },
            [ 2 ] = {
                [ "attr_name" ] = "hit",
                [ "attr_value" ] = 0.7,
            },
        },
        [ "attack_type" ] = 3,
        [ "spell_hurt_pct" ] = 287,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000002,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
        },
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.7,
            [ "hit" ] = 0.7,
        },
    },
    [ 11201201 ] = {
        [ "id" ] = 11201201,
        [ "ch_key" ] = "重锤",
        [ "name" ] = "重锤",
        [ "desc" ] = "对前排敌人造成70%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 152,
        [ "hurt_grow_rate" ] = 3,
    },
    [ 11201202 ] = {
        [ "id" ] = 11201202,
        [ "ch_key" ] = "大地震颤",
        [ "name" ] = "大地震颤",
        [ "icon" ] = 511201202,
        [ "desc" ] = "对前排敌人造成159%伤害$destiny，20%概率造成眩晕，造成流血效果（30%），持续2回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 159,
        [ "hurt_grow_rate" ] = 4,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
            [ 2 ] = 20000061,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.2,
            [ 2 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
            [ 2 ] = 2,
        },
    },
    [ 11202101 ] = {
        [ "id" ] = 11202101,
        [ "ch_key" ] = "烈弹",
        [ "name" ] = "烈弹",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11202102 ] = {
        [ "id" ] = 11202102,
        [ "ch_key" ] = "最终弹幕",
        [ "name" ] = "最终弹幕",
        [ "icon" ] = 511106137,
        [ "desc" ] = "对前排敌人造成152%伤害$destiny，敌人造成的伤害降低10%，持续2回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 7 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 8 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 9 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 10 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 11 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 12 ] = {
                [ "hurt_rate" ] = 0.1,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 152,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000027,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
    [ 11202311 ] = {
        [ "id" ] = 11202311,
        [ "ch_key" ] = "挽救",
        [ "name" ] = "挽救",
        [ "desc" ] = "治疗生命最少的1个友军（102%+150）",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 2,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 11,
        [ "fixed_hurt" ] = 150,
        [ "spell_hurt_pct" ] = 102,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11202312 ] = {
        [ "id" ] = 11202312,
        [ "ch_key" ] = "战场急救",
        [ "name" ] = "战场急救",
        [ "icon" ] = 511106135,
        [ "desc" ] = "治疗全体友军（116%+250）$destiny，我方随机1个头目增加2点怒气",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 2,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 1,
        [ "fixed_hurt" ] = 250,
        [ "spell_hurt_pct" ] = 116,
        [ "hurt_grow_rate" ] = 2,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000028,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 5,
        },
    },
    [ 11203101 ] = {
        [ "id" ] = 11203101,
        [ "ch_key" ] = "重击",
        [ "name" ] = "重击",
        [ "desc" ] = "对所有敌人造成40%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 40,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11203102 ] = {
        [ "id" ] = 11203102,
        [ "ch_key" ] = "所向披靡",
        [ "name" ] = "所向披靡",
        [ "icon" ] = 511106128,
        [ "desc" ] = "对所有敌人造成111%伤害$destiny，敌人受到伤害提升12%，持续2回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 115,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000059,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
    [ 11203103 ] = {
        [ "id" ] = 11203103,
        [ "ch_key" ] = "狂乱锤击",
        [ "name" ] = "狂乱锤击",
        [ "icon" ] = 511305232,
        [ "desc" ] = "对所有敌人造成144%伤害$destiny，30%概率减少2点怒气，敌人受到伤害提升18%，持续2回合【与$unit共同出战可触发，由艾伦发动】",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 12031,
        [ "spell_unit_list" ] = {
            [ 1 ] = 12012,
        },
        [ "first_spell_hero" ] = 12031,
        [ "second_spell_hero" ] = 12012,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 144,
        [ "hurt_grow_rate" ] = 4,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000062,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.3,
    },
    [ 11203104 ] = {
        [ "id" ] = 11203104,
        [ "ch_key" ] = "狂乱锤击1",
        [ "name" ] = "狂乱锤击1",
        [ "desc" ] = "对所有敌人造成144%伤害$destiny，30%概率减少2点怒气，敌人受到伤害提升18%，持续2回合【与$unit共同出战可触发，由艾伦发动】",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 144,
        [ "hurt_grow_rate" ] = 4,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000062,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.3,
    },
    [ 11203201 ] = {
        [ "id" ] = 11203201,
        [ "ch_key" ] = "突刺",
        [ "name" ] = "突刺",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11203202 ] = {
        [ "id" ] = 11203202,
        [ "ch_key" ] = "野蛮打击",
        [ "name" ] = "野蛮打击",
        [ "icon" ] = 511305228,
        [ "desc" ] = "对前排敌人造成152%伤害$destiny，本次攻击的命中率和暴击率上升40%",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "crit",
                [ "attr_value" ] = 0.4,
            },
            [ 2 ] = {
                [ "attr_name" ] = "hit",
                [ "attr_value" ] = 0.4,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 152,
        [ "hurt_grow_rate" ] = 3,
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.4,
            [ "hit" ] = 0.4,
        },
    },
    [ 11204101 ] = {
        [ "id" ] = 11204101,
        [ "ch_key" ] = "精准",
        [ "name" ] = "精准",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.2,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11204102 ] = {
        [ "id" ] = 11204102,
        [ "ch_key" ] = "疾风骤雨",
        [ "name" ] = "疾风骤雨",
        [ "icon" ] = 511204102,
        [ "desc" ] = "对单个敌人造成300%伤害$destiny，40%概率造成眩晕",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 7 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 8 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 9 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 10 ] = {
                [ "hurt_rate" ] = 0.1,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 300,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.4,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
    [ 11204103 ] = {
        [ "id" ] = 11204103,
        [ "ch_key" ] = "死亡艺术",
        [ "name" ] = "死亡艺术",
        [ "icon" ] = 511106127,
        [ "desc" ] = "对单个敌人造成390%伤害$destiny，100%概率造成眩晕，20%概率自身增加4点怒气【与$unit共同出战可触发，由蝎子发动】",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 12041,
        [ "spell_unit_list" ] = {
            [ 1 ] = 12052,
        },
        [ "first_spell_hero" ] = 12041,
        [ "second_spell_hero" ] = 12052,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 7 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 8 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 9 ] = {
                [ "hurt_rate" ] = 0.2,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 390,
        [ "hurt_grow_rate" ] = 4,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
            [ 2 ] = 20000048,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 0.2,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
            [ 2 ] = 1,
        },
    },
    [ 11204104 ] = {
        [ "id" ] = 11204104,
        [ "ch_key" ] = "死亡艺术1",
        [ "name" ] = "死亡艺术1",
        [ "icon" ] = 511204102,
        [ "desc" ] = "对单个敌人造成390%伤害$destiny，100%概率造成眩晕，20%概率自身增加4点怒气【与$unit共同出战可触发，由蝎子发动】",
        [ "spell_type" ] = 2,
        [ "super_spell_id" ] = 11204104,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 390,
        [ "hurt_grow_rate" ] = 4,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
            [ 2 ] = 20000048,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 0.2,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
            [ 2 ] = 1,
        },
        [ "is_second_kill" ] = true,
    },
    [ 11204105 ] = {
        [ "id" ] = 11204105,
        [ "ch_key" ] = "精准1",
        [ "name" ] = "精准1",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 1,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.2,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11204201 ] = {
        [ "id" ] = 11204201,
        [ "ch_key" ] = "抹杀",
        [ "name" ] = "抹杀",
        [ "desc" ] = "对后排单体造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 6,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11204202 ] = {
        [ "id" ] = 11204202,
        [ "ch_key" ] = "阴影袭杀",
        [ "name" ] = "阴影袭杀",
        [ "icon" ] = 511106134,
        [ "desc" ] = "对后排单个敌人造成315%伤害$destiny，80%减少4点怒气，自身受到伤害降低55%，持续2回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 7 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 8 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 9 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 10 ] = {
                [ "hurt_rate" ] = 0.1,
            },
        },
        [ "attack_type" ] = 6,
        [ "spell_hurt_pct" ] = 315,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000009,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
        },
        [ "reduce_anger" ] = 4,
        [ "reduce_anger_level" ] = 4,
        [ "reduce_anger_ratio" ] = 0.8,
    },
    [ 11205111 ] = {
        [ "id" ] = 11205111,
        [ "ch_key" ] = "电击",
        [ "name" ] = "电击",
        [ "desc" ] = "对所有敌人造成40%伤害，10%概率减少2点怒气",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 40,
        [ "hurt_grow_rate" ] = 0,
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.1,
    },
    [ 11205112 ] = {
        [ "id" ] = 11205112,
        [ "ch_key" ] = "磁电链接",
        [ "name" ] = "磁电链接",
        [ "icon" ] = 511205112,
        [ "desc" ] = "对所有敌人造成115%伤害$destiny，25%概率减少2点怒气，我方随机2个头目伤害提高20%，持续2回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.2,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 115,
        [ "hurt_grow_rate" ] = 2,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000029,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 6,
        },
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.25,
    },
    [ 11205113 ] = {
        [ "id" ] = 11205113,
        [ "ch_key" ] = "失控电荷",
        [ "name" ] = "失控电荷",
        [ "icon" ] = 511305223,
        [ "desc" ] = "对所有敌人造成149%伤害$destiny，40%概率减少2点怒气，我方全体头目伤害和命中率提高20%，持续2回合【与$unit共同出战可触发，由朱可夫发动】",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 12051,
        [ "spell_unit_list" ] = {
            [ 1 ] = 12023,
        },
        [ "first_spell_hero" ] = 12051,
        [ "second_spell_hero" ] = 12022,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.06,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.06,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.06,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.4,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.21,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.21,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 149,
        [ "hurt_grow_rate" ] = 2,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000018,
            [ 2 ] = 20000019,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 3,
            [ 2 ] = 3,
        },
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.4,
    },
    [ 11205114 ] = {
        [ "id" ] = 11205114,
        [ "ch_key" ] = "超·失控电荷",
        [ "name" ] = "超·失控电荷",
        [ "icon" ] = 511305223,
        [ "desc" ] = "对所有敌人造成161%伤害$destiny，50%概率减少2点怒气，我方全体头目伤害和命中率提高30%，持续2回合【与$unit共同出战可触发，由朱可夫发动】",
        [ "spell_type" ] = 4,
        [ "super_spell_id" ] = 11205114,
        [ "spell_unit" ] = 12051,
        [ "spell_unit_list" ] = {
            [ 1 ] = 12023,
        },
        [ "first_spell_hero" ] = 12051,
        [ "second_spell_hero" ] = 12022,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.06,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.06,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.06,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.4,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.21,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.21,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 161,
        [ "hurt_grow_rate" ] = 2,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000070,
            [ 2 ] = 20000071,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 3,
            [ 2 ] = 3,
        },
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.5,
    },
    [ 11205201 ] = {
        [ "id" ] = 11205201,
        [ "ch_key" ] = "击弦",
        [ "name" ] = "击弦",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11205202 ] = {
        [ "id" ] = 11205202,
        [ "ch_key" ] = "致命和弦",
        [ "name" ] = "致命和弦",
        [ "icon" ] = 511305230,
        [ "desc" ] = "对前排敌人造成152%伤害$destiny，18%概率造成眩晕",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 152,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.18,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
    [ 11206101 ] = {
        [ "id" ] = 11206101,
        [ "ch_key" ] = "锯鲨",
        [ "name" ] = "锯鲨",
        [ "desc" ] = "对所有敌人造成40%伤害，敌人受到的伤害增加5%，持续2回合",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 40,
        [ "hurt_grow_rate" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000055,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
    [ 11206102 ] = {
        [ "id" ] = 11206102,
        [ "ch_key" ] = "锯鲨风暴",
        [ "name" ] = "锯鲨风暴",
        [ "icon" ] = 511305215,
        [ "desc" ] = "对所有敌人造成115%伤害$destiny，5%概率造成眩晕，敌人受到的伤害增加10%，持续2回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.7,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 115,
        [ "hurt_grow_rate" ] = 2,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000056,
            [ 2 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 0.05,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
            [ 2 ] = 2,
        },
    },
    [ 11206103 ] = {
        [ "id" ] = 11206103,
        [ "ch_key" ] = "残虐猛击",
        [ "name" ] = "残虐猛击",
        [ "icon" ] = 511206103,
        [ "desc" ] = "对所有敌人造成149%伤害$destiny，15%概率造成眩晕，敌人受到的伤害增加15%，持续2回合【与$unit共同出战可触发，由剃刀发动】",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 12061,
        [ "spell_unit_list" ] = {
            [ 1 ] = 12042,
        },
        [ "first_spell_hero" ] = 12061,
        [ "second_spell_hero" ] = 12042,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 149,
        [ "hurt_grow_rate" ] = 2,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000057,
            [ 2 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 0.15,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
            [ 2 ] = 2,
        },
    },
    [ 11206104 ] = {
        [ "id" ] = 11206104,
        [ "ch_key" ] = "超·残虐猛击",
        [ "name" ] = "超·残虐猛击",
        [ "icon" ] = 511206103,
        [ "desc" ] = "对所有敌人造成161%伤害$destiny，20%概率造成眩晕，敌人受到的伤害增加20%，持续2回合【与$unit共同出战可触发，由剃刀发动】",
        [ "spell_type" ] = 4,
        [ "super_spell_id" ] = 11206104,
        [ "spell_unit" ] = 12061,
        [ "spell_unit_list" ] = {
            [ 1 ] = 12042,
        },
        [ "first_spell_hero" ] = 12061,
        [ "second_spell_hero" ] = 12042,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 161,
        [ "hurt_grow_rate" ] = 2,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000069,
            [ 2 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 0.2,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
            [ 2 ] = 2,
        },
    },
    [ 11206201 ] = {
        [ "id" ] = 11206201,
        [ "ch_key" ] = "处决",
        [ "name" ] = "处决",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11206202 ] = {
        [ "id" ] = 11206202,
        [ "ch_key" ] = "剑影重重",
        [ "name" ] = "剑影重重",
        [ "icon" ] = 511305213,
        [ "desc" ] = "对前排敌人造成152%伤害$destiny，我方随即2个头目防御提高30%，持续2回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 152,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000020,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 6,
        },
    },
    [ 11206203 ] = {
        [ "id" ] = 11206203,
        [ "ch_key" ] = "英伦杀机",
        [ "name" ] = "英伦杀机",
        [ "icon" ] = 511305229,
        [ "desc" ] = "对前排敌人造成197%伤害$destiny，本次攻击的暴击率和命中率上升65%【与$unit共同出战可触发，由阿尔法发动】",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 12062,
        [ "spell_unit_list" ] = {
            [ 1 ] = 12021,
        },
        [ "first_spell_hero" ] = 12062,
        [ "second_spell_hero" ] = 12021,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "crit",
                [ "attr_value" ] = 0.65,
            },
            [ 2 ] = {
                [ "attr_name" ] = "hit",
                [ "attr_value" ] = 0.65,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 197,
        [ "hurt_grow_rate" ] = 4,
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.65,
            [ "hit" ] = 0.65,
        },
    },
    [ 11206204 ] = {
        [ "id" ] = 11206204,
        [ "ch_key" ] = "英伦杀机1",
        [ "name" ] = "英伦杀机1",
        [ "desc" ] = "对前排敌人造成197%伤害$destiny，本次攻击的暴击率和命中率上升65%【与$unit共同出战可触发，由阿尔法发动】",
        [ "spell_type" ] = 4,
        [ "super_spell_id" ] = 11206204,
        [ "spell_unit" ] = 12062,
        [ "spell_unit_list" ] = {
            [ 1 ] = 12021,
        },
        [ "first_spell_hero" ] = 12062,
        [ "second_spell_hero" ] = 12021,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "crit",
                [ "attr_value" ] = 0.65,
            },
            [ 2 ] = {
                [ "attr_name" ] = "hit",
                [ "attr_value" ] = 0.65,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 197,
        [ "hurt_grow_rate" ] = 4,
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.65,
            [ "hit" ] = 0.65,
        },
    },
    [ 11301101 ] = {
        [ "id" ] = 11301101,
        [ "ch_key" ] = "诸刃",
        [ "name" ] = "诸刃",
        [ "desc" ] = "对一列敌人造成80%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "attack_type" ] = 3,
        [ "spell_hurt_pct" ] = 80,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11301102 ] = {
        [ "id" ] = 11301102,
        [ "ch_key" ] = "忍法·鹰落",
        [ "name" ] = "忍法·鹰落",
        [ "icon" ] = 511305221,
        [ "desc" ] = "对一列敌人造成221%伤害$destiny，50%概率恢复自身2点怒气",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "attack_type" ] = 3,
        [ "spell_hurt_pct" ] = 221,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000028,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.5,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
        },
    },
    [ 11301103 ] = {
        [ "id" ] = 11301103,
        [ "ch_key" ] = "最佳战略",
        [ "name" ] = "最佳战略",
        [ "icon" ] = 511305231,
        [ "desc" ] = "对一列敌人造成287%伤害$destiny，50%概率恢复自身4点怒气，敌人的攻击力降低20%，持续2回合",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 13011,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13031,
        },
        [ "first_spell_hero" ] = 13011,
        [ "second_spell_hero" ] = 13031,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.09,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.11,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.12,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.06,
            },
            [ 7 ] = {
                [ "hurt_rate" ] = 0.03,
            },
            [ 8 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 9 ] = {
                [ "hurt_rate" ] = 0.16,
            },
            [ 10 ] = {
                [ "hurt_rate" ] = 0.02,
            },
            [ 11 ] = {
                [ "hurt_rate" ] = 0.04,
            },
            [ 12 ] = {
                [ "hurt_rate" ] = 0.04,
            },
        },
        [ "attack_type" ] = 3,
        [ "spell_hurt_pct" ] = 221,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000048,
            [ 2 ] = 20000063,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.5,
            [ 2 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 2,
        },
    },
    [ 11301104 ] = {
        [ "id" ] = 11301104,
        [ "ch_key" ] = "最佳战略1",
        [ "name" ] = "最佳战略1",
        [ "desc" ] = "对一列敌人造成287%伤害$destiny，50%概率恢复自身4点怒气，敌人的攻击力降低20%，持续2回合",
        [ "spell_type" ] = 4,
        [ "super_spell_id" ] = 11301104,
        [ "spell_unit" ] = 13011,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13031,
        },
        [ "first_spell_hero" ] = 13011,
        [ "second_spell_hero" ] = 13031,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.09,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.11,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.12,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.06,
            },
            [ 7 ] = {
                [ "hurt_rate" ] = 0.03,
            },
            [ 8 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 9 ] = {
                [ "hurt_rate" ] = 0.16,
            },
            [ 10 ] = {
                [ "hurt_rate" ] = 0.02,
            },
            [ 11 ] = {
                [ "hurt_rate" ] = 0.04,
            },
            [ 12 ] = {
                [ "hurt_rate" ] = 0.04,
            },
        },
        [ "attack_type" ] = 3,
        [ "spell_hurt_pct" ] = 221,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000048,
            [ 2 ] = 20000063,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.5,
            [ 2 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 2,
        },
    },
    [ 11301201 ] = {
        [ "id" ] = 11301201,
        [ "ch_key" ] = "落刃",
        [ "name" ] = "落刃",
        [ "desc" ] = "对所有敌人造成40%伤害，50%概率恢复自身2点怒气。",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 40,
        [ "hurt_grow_rate" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000028,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.5,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
        },
    },
    [ 11301202 ] = {
        [ "id" ] = 11301202,
        [ "ch_key" ] = "一字皆杀",
        [ "name" ] = "一字皆杀",
        [ "icon" ] = 511106133,
        [ "desc" ] = "对所有敌人造成115%伤害$destiny，50%概率恢复自身4点怒气，自身伤害提高25%，持续2回合。",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 115,
        [ "hurt_grow_rate" ] = 4,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000048,
            [ 2 ] = 20000053,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.5,
            [ 2 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
    },
    [ 11301203 ] = {
        [ "id" ] = 11301203,
        [ "ch_key" ] = "向死而生",
        [ "name" ] = "向死而生",
        [ "icon" ] = 511305226,
        [ "desc" ] = "对所有敌人造成149%伤害$destiny，50%概率恢复自身4点怒气，自身伤害提高30%，持续2回合。【与$unit共同出战可发动，由龙王发动】",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 13012,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13043,
        },
        [ "first_spell_hero" ] = 13012,
        [ "second_spell_hero" ] = 13032,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.12,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.06,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.18,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.06,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 7 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 8 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 9 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 10 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 11 ] = {
                [ "hurt_rate" ] = 0.1,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 149,
        [ "hurt_grow_rate" ] = 4,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000048,
            [ 2 ] = 20000054,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.5,
            [ 2 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
    },
    [ 11301204 ] = {
        [ "id" ] = 11301204,
        [ "ch_key" ] = "超·向死而生",
        [ "name" ] = "超·向死而生",
        [ "icon" ] = 511305226,
        [ "desc" ] = "对所有敌人造成161%伤害$destiny，恢复自身4点怒气，自身伤害提高50%，同时免疫（1级抵御）所有减益状态，持续2回合，此技能有50%的额外命中率和暴击率。【与$unit共同出战可发动，由龙王发动】",
        [ "spell_type" ] = 4,
        [ "super_spell_id" ] = 11301204,
        [ "spell_unit" ] = 13012,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13043,
        },
        [ "first_spell_hero" ] = 13012,
        [ "second_spell_hero" ] = 13032,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.3,
            },
        },
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "crit",
                [ "attr_value" ] = 0.5,
            },
            [ 2 ] = {
                [ "attr_name" ] = "hit",
                [ "attr_value" ] = 0.5,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 161,
        [ "hurt_grow_rate" ] = 4,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000048,
            [ 2 ] = 20000054,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
        [ "buff_clear_level" ] = 1,
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.5,
            [ "hit" ] = 0.5,
        },
    },
    [ 11302101 ] = {
        [ "id" ] = 11302101,
        [ "ch_key" ] = "怒龙",
        [ "name" ] = "怒龙",
        [ "desc" ] = "对后排单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 6,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11302102 ] = {
        [ "id" ] = 11302102,
        [ "ch_key" ] = "精武之怒",
        [ "name" ] = "精武之怒",
        [ "icon" ] = 511106111,
        [ "desc" ] = "对后排敌人造成152%伤害$destiny",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 5,
        [ "spell_hurt_pct" ] = 152,
        [ "hurt_grow_rate" ] = 3,
    },
    [ 11302201 ] = {
        [ "id" ] = 11302201,
        [ "ch_key" ] = "扇舞",
        [ "name" ] = "扇舞",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.7,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11302202 ] = {
        [ "id" ] = 11302202,
        [ "ch_key" ] = "飞扇连击",
        [ "name" ] = "飞扇连击",
        [ "icon" ] = 511305206,
        [ "desc" ] = "对一列敌人造成221%伤害$destiny，我方随机2个头目的攻击提高20%，持续2回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.25,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.25,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.25,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.25,
            },
        },
        [ "attack_type" ] = 3,
        [ "spell_hurt_pct" ] = 221,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000066,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 6,
        },
    },
    [ 11302203 ] = {
        [ "id" ] = 11302203,
        [ "ch_key" ] = "刚柔并济",
        [ "name" ] = "刚柔并济",
        [ "icon" ] = 511305207,
        [ "desc" ] = "对一列敌人造成287%伤害$destiny，我方随机2个头目的攻击提高30%，持续2回合",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 13022,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13021,
        },
        [ "first_spell_hero" ] = 13022,
        [ "second_spell_hero" ] = 13021,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 7 ] = {
                [ "hurt_rate" ] = 0.3,
            },
        },
        [ "attack_type" ] = 3,
        [ "spell_hurt_pct" ] = 287,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000067,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 6,
        },
    },
    [ 11302204 ] = {
        [ "id" ] = 11302204,
        [ "ch_key" ] = "刚柔并济1",
        [ "name" ] = "刚柔并济1",
        [ "desc" ] = "对一列敌人造成287%伤害$destiny，我方随机2个头目的攻击提高30%，持续2回合",
        [ "spell_type" ] = 4,
        [ "super_spell_id" ] = 11302204,
        [ "spell_unit" ] = 13022,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13021,
        },
        [ "first_spell_hero" ] = 13022,
        [ "second_spell_hero" ] = 13021,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 7 ] = {
                [ "hurt_rate" ] = 0.3,
            },
        },
        [ "attack_type" ] = 3,
        [ "spell_hurt_pct" ] = 287,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000067,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 6,
        },
    },
    [ 11303101 ] = {
        [ "id" ] = 11303101,
        [ "ch_key" ] = "破裂",
        [ "name" ] = "破裂",
        [ "desc" ] = "对敌人及其相邻位置造成60%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 10,
        [ "spell_hurt_pct" ] = 60,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11303102 ] = {
        [ "id" ] = 11303102,
        [ "ch_key" ] = "飞弹轰击",
        [ "name" ] = "飞弹轰击",
        [ "icon" ] = 51303102,
        [ "desc" ] = "对敌人及其相邻位置造成140%伤害$destiny，造成灼烧效果（35%），持续2回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 140,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000068,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "reduce_anger" ] = 1,
        [ "reduce_anger_level" ] = 1,
        [ "reduce_anger_ratio" ] = 0.5,
    },
    [ 11303103 ] = {
        [ "id" ] = 11303103,
        [ "ch_key" ] = "破裂1",
        [ "name" ] = "破裂1",
        [ "desc" ] = "对敌人及其相邻位置造成60%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 1,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 60,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11303104 ] = {
        [ "id" ] = 11303104,
        [ "ch_key" ] = "飞弹轰击1",
        [ "name" ] = "飞弹轰击1",
        [ "icon" ] = 51303102,
        [ "desc" ] = "对敌人及其相邻位置造成140%伤害$destiny，造成灼烧效果（35%），持续2回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 140,
        [ "hurt_grow_rate" ] = 3,
        [ "reduce_anger" ] = 1,
        [ "reduce_anger_level" ] = 1,
        [ "reduce_anger_ratio" ] = 0.5,
        [ "is_second_kill" ] = true,
    },
    [ 11304101 ] = {
        [ "id" ] = 11304101,
        [ "ch_key" ] = "践踏",
        [ "name" ] = "践踏",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.8,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11304102 ] = {
        [ "id" ] = 11304102,
        [ "ch_key" ] = "断筋折骨",
        [ "name" ] = "断筋折骨",
        [ "icon" ] = 511106104,
        [ "desc" ] = "对单个敌人造成300%伤害$destiny，40%概率造成眩晕",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 300,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.4,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
    [ 11304201 ] = {
        [ "id" ] = 11304201,
        [ "ch_key" ] = "杀戒",
        [ "name" ] = "杀戒",
        [ "desc" ] = "对后排单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 6,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11304202 ] = {
        [ "id" ] = 11304202,
        [ "ch_key" ] = "怒目金刚",
        [ "name" ] = "怒目金刚",
        [ "icon" ] = 511305218,
        [ "desc" ] = "对后排敌人造成152%伤害$destiny，40%概率减少2点怒气",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 5,
        [ "spell_hurt_pct" ] = 152,
        [ "hurt_grow_rate" ] = 3,
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.4,
    },
    [ 11304203 ] = {
        [ "id" ] = 11304203,
        [ "ch_key" ] = "横冲直撞",
        [ "name" ] = "横冲直撞",
        [ "icon" ] = 511305209,
        [ "desc" ] = "对后排敌人造成206%伤害$destiny，60%概率减少2点怒气",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 13042,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13061,
        },
        [ "first_spell_hero" ] = 13042,
        [ "second_spell_hero" ] = 13061,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 5,
        [ "spell_hurt_pct" ] = 206,
        [ "hurt_grow_rate" ] = 3,
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.6,
    },
    [ 11304204 ] = {
        [ "id" ] = 11304204,
        [ "ch_key" ] = "横冲直撞1",
        [ "name" ] = "横冲直撞1",
        [ "desc" ] = "对后排敌人造成206%伤害$destiny，60%概率减少2点怒气",
        [ "spell_type" ] = 4,
        [ "super_spell_id" ] = 11304204,
        [ "spell_unit" ] = 13042,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13061,
        },
        [ "first_spell_hero" ] = 13042,
        [ "second_spell_hero" ] = 13061,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 5,
        [ "spell_hurt_pct" ] = 206,
        [ "hurt_grow_rate" ] = 3,
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.6,
    },
    [ 11304311 ] = {
        [ "id" ] = 11304311,
        [ "ch_key" ] = "愈合",
        [ "name" ] = "愈合",
        [ "desc" ] = "治疗生命最少的1个友军（102%+150）",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 2,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 11,
        [ "fixed_hurt" ] = 150,
        [ "spell_hurt_pct" ] = 102,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11304312 ] = {
        [ "id" ] = 11304312,
        [ "ch_key" ] = "复苏药剂",
        [ "name" ] = "复苏药剂",
        [ "icon" ] = 511106107,
        [ "desc" ] = "治疗全体友军（116%+250）$destiny，每回合恢复生命（50%)，持续2回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 2,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.1,
            },
        },
        [ "attack_type" ] = 1,
        [ "fixed_hurt" ] = 250,
        [ "spell_hurt_pct" ] = 116,
        [ "hurt_grow_rate" ] = 2,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000026,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 3,
        },
    },
    [ 11305101 ] = {
        [ "id" ] = 11305101,
        [ "ch_key" ] = "割裂",
        [ "name" ] = "割裂",
        [ "desc" ] = "对后排单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.55,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.15,
            },
        },
        [ "attack_type" ] = 6,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11305102 ] = {
        [ "id" ] = 11305102,
        [ "ch_key" ] = "利刃冲击",
        [ "name" ] = "利刃冲击",
        [ "icon" ] = 511106115,
        [ "desc" ] = "对后排单个敌人造成300%伤害$destiny，15%概率减少3点怒气",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 6,
        [ "spell_hurt_pct" ] = 300,
        [ "hurt_grow_rate" ] = 3,
        [ "reduce_anger" ] = 3,
        [ "reduce_anger_level" ] = 3,
        [ "reduce_anger_ratio" ] = 0.15,
    },
    [ 11305201 ] = {
        [ "id" ] = 11305201,
        [ "ch_key" ] = "引爆",
        [ "name" ] = "引爆",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11305202 ] = {
        [ "id" ] = 11305202,
        [ "ch_key" ] = "毒瓶投掷",
        [ "name" ] = "毒瓶投掷",
        [ "icon" ] = 511305202,
        [ "desc" ] = "对全部敌人造成106%伤害$destiny，50%概率造成中毒效果（15%)，持续2回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.4,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.3,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 106,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000007,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.5,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
    [ 11305203 ] = {
        [ "id" ] = 11305203,
        [ "ch_key" ] = "毁灭狂欢",
        [ "name" ] = "毁灭狂欢",
        [ "icon" ] = 511305211,
        [ "desc" ] = "对全部敌人造成137%伤害$destiny，造成中毒效果（20%），持续2回合，本次攻击的命中率上升50%【与$unit共同出战可触发，由蜘蛛发动】",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 13052,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13051,
        },
        [ "first_spell_hero" ] = 13052,
        [ "second_spell_hero" ] = 13051,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 137,
        [ "hurt_grow_rate" ] = 4,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000045,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
    [ 11305204 ] = {
        [ "id" ] = 11305204,
        [ "ch_key" ] = "1",
        [ "name" ] = "1",
        [ "desc" ] = "对全部敌人造成137%伤害$destiny，造成中毒效果（20%），持续2回合，本次攻击的命中率上升50%【与$unit共同出战可触发，由蜘蛛发动】",
        [ "spell_type" ] = 3,
        [ "super_spell_id" ] = 11305204,
        [ "spell_unit" ] = 13052,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13051,
        },
        [ "first_spell_hero" ] = 13052,
        [ "second_spell_hero" ] = 13051,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 137,
        [ "hurt_grow_rate" ] = 4,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000045,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
    [ 11305311 ] = {
        [ "id" ] = 11305311,
        [ "ch_key" ] = "爆裂",
        [ "name" ] = "爆裂",
        [ "desc" ] = "对前排敌人造成70%伤害，20%概率减少2点怒气",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 70,
        [ "hurt_grow_rate" ] = 0,
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.2,
    },
    [ 11305312 ] = {
        [ "id" ] = 11305312,
        [ "ch_key" ] = "地狱烈焰",
        [ "name" ] = "地狱烈焰",
        [ "icon" ] = 511305312,
        [ "desc" ] = "对前排敌人造成165%伤害$destiny，50%概率减少2点怒气，15%概率造成眩晕",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.2,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 165,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.15,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.5,
    },
    [ 11305313 ] = {
        [ "id" ] = 11305313,
        [ "ch_key" ] = "索命幽魂",
        [ "name" ] = "索命幽魂",
        [ "icon" ] = 511305224,
        [ "desc" ] = "对前排敌人造成214%伤害$destiny，80%概率减少2点怒气，25%概率造成眩晕【与$unit共同出战可触发，由收割者发动】",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 13053,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13041,
        },
        [ "first_spell_hero" ] = 13062,
        [ "second_spell_hero" ] = 13041,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.4,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 214,
        [ "hurt_grow_rate" ] = 4,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.25,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.8,
    },
    [ 11305314 ] = {
        [ "id" ] = 11305314,
        [ "ch_key" ] = "超·索命幽魂",
        [ "name" ] = "超·索命幽魂",
        [ "icon" ] = 511305224,
        [ "desc" ] = "对前排敌人造成231%伤害$destiny，减少2点怒气，35%概率造成眩晕【与$unit共同出战可触发，由收割者发动】",
        [ "spell_type" ] = 4,
        [ "super_spell_id" ] = 11305314,
        [ "spell_unit" ] = 13053,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13041,
        },
        [ "first_spell_hero" ] = 13062,
        [ "second_spell_hero" ] = 13041,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.4,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 231,
        [ "hurt_grow_rate" ] = 4,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.35,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 1,
    },
    [ 11306101 ] = {
        [ "id" ] = 11306101,
        [ "ch_key" ] = "碎颅",
        [ "name" ] = "碎颅",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11306102 ] = {
        [ "id" ] = 11306102,
        [ "ch_key" ] = "恶徒进击",
        [ "name" ] = "恶徒进击",
        [ "icon" ] = 511305203,
        [ "desc" ] = "对前排敌人造成152%伤害$destiny，降低敌人攻击15%，持续2回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 152,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000060,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
    [ 11350011 ] = {
        [ "id" ] = 11350011,
        [ "ch_key" ] = "汤姆普攻",
        [ "name" ] = "汤姆普攻",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11350012 ] = {
        [ "id" ] = 11350012,
        [ "ch_key" ] = "无情扫荡",
        [ "name" ] = "无情扫荡",
        [ "icon" ] = 511350012,
        [ "desc" ] = "对后排敌人造成152%伤害$destiny，50%概率减少1点怒气",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.2,
            },
        },
        [ "attack_type" ] = 5,
        [ "spell_hurt_pct" ] = 152,
        [ "hurt_grow_rate" ] = 0,
        [ "reduce_anger" ] = 1,
        [ "reduce_anger_level" ] = 1,
        [ "reduce_anger_ratio" ] = 0.5,
    },
    [ 11350013 ] = {
        [ "id" ] = 11350013,
        [ "ch_key" ] = "无情扫荡1",
        [ "name" ] = "无情扫荡1",
        [ "icon" ] = 511350012,
        [ "desc" ] = "对后排敌人造成152%伤害$destiny，50%概率减少1点怒气",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.2,
            },
        },
        [ "attack_type" ] = 5,
        [ "spell_hurt_pct" ] = 152,
        [ "hurt_grow_rate" ] = 0,
        [ "reduce_anger" ] = 1,
        [ "reduce_anger_level" ] = 1,
        [ "reduce_anger_ratio" ] = 0.5,
        [ "is_second_kill" ] = true,
    },
    [ 11350014 ] = {
        [ "id" ] = 11350014,
        [ "ch_key" ] = "汤姆普攻1",
        [ "name" ] = "汤姆普攻1",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 1,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11350021 ] = {
        [ "id" ] = 11350021,
        [ "ch_key" ] = "亚伯普攻",
        [ "name" ] = "亚伯普攻",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11350022 ] = {
        [ "id" ] = 11350022,
        [ "ch_key" ] = "喋血街头",
        [ "name" ] = "喋血街头",
        [ "icon" ] = 511350022,
        [ "desc" ] = "对前排敌人造成139%伤害$destiny，自身的防御提高30%，持续2回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 139,
        [ "hurt_grow_rate" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000020,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
        },
    },
    [ 11350023 ] = {
        [ "id" ] = 11350023,
        [ "ch_key" ] = "喋血街头1",
        [ "name" ] = "喋血街头1",
        [ "icon" ] = 511350022,
        [ "desc" ] = "对前排敌人造成139%伤害$destiny，自身的防御提高30%，持续2回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 139,
        [ "hurt_grow_rate" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000020,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
        },
        [ "is_second_kill" ] = true,
    },
    [ 11350024 ] = {
        [ "id" ] = 11350024,
        [ "ch_key" ] = "亚伯普攻1",
        [ "name" ] = "亚伯普攻1",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 1,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11401101 ] = {
        [ "id" ] = 11401101,
        [ "ch_key" ] = "WD-突袭",
        [ "name" ] = "WD-突袭",
        [ "desc" ] = "对后排敌人造成60%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 5,
        [ "spell_hurt_pct" ] = 60,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11401102 ] = {
        [ "id" ] = 11401102,
        [ "ch_key" ] = "WD-歼灭",
        [ "name" ] = "WD-歼灭",
        [ "icon" ] = 51401102,
        [ "desc" ] = "对后排敌人造成152%$destiny，敌人受到伤害+25%，持续2回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 5,
        [ "spell_hurt_pct" ] = 152,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000014,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
    [ 11402101 ] = {
        [ "id" ] = 11402101,
        [ "ch_key" ] = "钩锁",
        [ "name" ] = "钩锁",
        [ "desc" ] = "对一列敌人造成80%伤害，我方随机2个头目伤害加成与伤害减免提高10%，持续2回合",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 7 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 8 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 9 ] = {
                [ "hurt_rate" ] = 0.2,
            },
        },
        [ "attack_type" ] = 3,
        [ "spell_hurt_pct" ] = 80,
        [ "hurt_grow_rate" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000050,
            [ 2 ] = 20000051,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 6,
            [ 2 ] = 6,
        },
    },
    [ 11402102 ] = {
        [ "id" ] = 11402102,
        [ "ch_key" ] = "血腥咆哮",
        [ "name" ] = "血腥咆哮",
        [ "icon" ] = 511305227,
        [ "desc" ] = "对一列敌人造成240%伤害$destiny，清除（一级清除）对方所有增益状态，我方随机2个头目伤害加成与伤害减免提高10%，持续2回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 3,
        [ "spell_hurt_pct" ] = 240,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000050,
            [ 2 ] = 20000051,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 6,
            [ 2 ] = 6,
        },
        [ "buff_clear_level" ] = 1,
        [ "buff_clear_ratio" ] = 1,
    },
    [ 11402103 ] = {
        [ "id" ] = 11402103,
        [ "ch_key" ] = "屠戮盛宴",
        [ "name" ] = "屠戮盛宴",
        [ "icon" ] = 511305225,
        [ "desc" ] = "对一列敌人造成312%伤害$destiny，清除（一级清除）对方所有增益状态，我方全体头目伤害加成与伤害减免提高10%，持续2回合【与$unit共同出战可触发，由链锯触发】",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 14021,
        [ "spell_unit_list" ] = {
            [ 1 ] = 14042,
        },
        [ "first_spell_hero" ] = 14021,
        [ "second_spell_hero" ] = 14042,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 3,
        [ "spell_hurt_pct" ] = 312,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000050,
            [ 2 ] = 20000051,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 3,
            [ 2 ] = 3,
        },
        [ "buff_clear_level" ] = 1,
        [ "buff_clear_ratio" ] = 1,
    },
    [ 11402104 ] = {
        [ "id" ] = 11402104,
        [ "ch_key" ] = "超·屠戮盛宴",
        [ "name" ] = "超·屠戮盛宴",
        [ "icon" ] = 511305225,
        [ "desc" ] = "对一列敌人造成336%伤害$destiny，清除（一级清除）对方所有增益状态，我方全体头目伤害加成与伤害减免提高15%，持续2回合【与$unit共同出战可触发，由链锯触发】",
        [ "spell_type" ] = 4,
        [ "super_spell_id" ] = 11402104,
        [ "spell_unit" ] = 14021,
        [ "spell_unit_list" ] = {
            [ 1 ] = 14042,
        },
        [ "first_spell_hero" ] = 14021,
        [ "second_spell_hero" ] = 14042,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 3,
        [ "spell_hurt_pct" ] = 336,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000073,
            [ 2 ] = 20000074,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 3,
            [ 2 ] = 3,
        },
        [ "buff_clear_level" ] = 1,
        [ "buff_clear_ratio" ] = 1,
    },
    [ 11402201 ] = {
        [ "id" ] = 11402201,
        [ "ch_key" ] = "弹雨",
        [ "name" ] = "弹雨",
        [ "desc" ] = "对后排敌人造成70%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.2,
            },
        },
        [ "attack_type" ] = 5,
        [ "spell_hurt_pct" ] = 70,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11402202 ] = {
        [ "id" ] = 11402202,
        [ "ch_key" ] = "狂热火力",
        [ "name" ] = "狂热火力",
        [ "icon" ] = 511106114,
        [ "desc" ] = "对后排敌人造成159%伤害$destiny，本次攻击的命中率和暴击率上升30%",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "crit",
                [ "attr_value" ] = 0.3,
            },
            [ 2 ] = {
                [ "attr_name" ] = "hit",
                [ "attr_value" ] = 0.3,
            },
        },
        [ "attack_type" ] = 5,
        [ "spell_hurt_pct" ] = 159,
        [ "hurt_grow_rate" ] = 3,
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.3,
            [ "hit" ] = 0.3,
        },
    },
    [ 11402203 ] = {
        [ "id" ] = 11402203,
        [ "ch_key" ] = "攻势如潮",
        [ "name" ] = "攻势如潮",
        [ "icon" ] = 511106108,
        [ "desc" ] = "全部敌人造成144%伤害$destiny，50%概率减少1点怒气，本次攻击的命中率和暴击率上升70%【与$unit共同出战可触发，由晨星发动】",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 14022,
        [ "spell_unit_list" ] = {
            [ 1 ] = 14032,
        },
        [ "first_spell_hero" ] = 14012,
        [ "second_spell_hero" ] = 14032,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "crit",
                [ "attr_value" ] = 0.7,
            },
            [ 2 ] = {
                [ "attr_name" ] = "hit",
                [ "attr_value" ] = 0.7,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 144,
        [ "hurt_grow_rate" ] = 4,
        [ "reduce_anger" ] = 1,
        [ "reduce_anger_level" ] = 1,
        [ "reduce_anger_ratio" ] = 0.5,
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.7,
            [ "hit" ] = 0.7,
        },
    },
    [ 11403101 ] = {
        [ "id" ] = 11403101,
        [ "ch_key" ] = "飞踢",
        [ "name" ] = "飞踢",
        [ "desc" ] = "对前排敌人造成70%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 7 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 8 ] = {
                [ "hurt_rate" ] = 0.2,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 70,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11403102 ] = {
        [ "id" ] = 11403102,
        [ "ch_key" ] = "回旋猛踢",
        [ "name" ] = "回旋猛踢",
        [ "icon" ] = 511305212,
        [ "desc" ] = "对前排敌人造成159%伤害，我方随机一名头目增加2点怒气",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.6,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 159,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000028,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 5,
        },
    },
    [ 11403103 ] = {
        [ "id" ] = 11403103,
        [ "ch_key" ] = "战斗潮流",
        [ "name" ] = "战斗潮流",
        [ "icon" ] = 511305233,
        [ "desc" ] = "对前排敌人造成206%伤害$destiny，我方随机2个武将增加2点怒气【与$unit共同出战可触发，由韩朴仁触发】",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 14031,
        [ "spell_unit_list" ] = {
            [ 1 ] = 14011,
        },
        [ "first_spell_hero" ] = 14031,
        [ "second_spell_hero" ] = 14011,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 7 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 8 ] = {
                [ "hurt_rate" ] = 0.2,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 206,
        [ "hurt_grow_rate" ] = 4,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000028,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 6,
        },
    },
    [ 11403104 ] = {
        [ "id" ] = 11403104,
        [ "ch_key" ] = "战斗潮流1",
        [ "name" ] = "战斗潮流1",
        [ "desc" ] = "对前排敌人造成206%伤害$destiny，我方随机2个武将增加2点怒气【与$unit共同出战可触发，由韩朴仁触发】",
        [ "spell_type" ] = 4,
        [ "super_spell_id" ] = 11403104,
        [ "spell_unit" ] = 14031,
        [ "spell_unit_list" ] = {
            [ 1 ] = 14011,
        },
        [ "first_spell_hero" ] = 14031,
        [ "second_spell_hero" ] = 14011,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.05,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 7 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 8 ] = {
                [ "hurt_rate" ] = 0.2,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 206,
        [ "hurt_grow_rate" ] = 4,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000028,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 6,
        },
    },
    [ 11403201 ] = {
        [ "id" ] = 11403201,
        [ "ch_key" ] = "鞭挞",
        [ "name" ] = "鞭挞",
        [ "desc" ] = "对前排敌人造成70%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 70,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11403202 ] = {
        [ "id" ] = 11403202,
        [ "ch_key" ] = "鞭刃乱舞",
        [ "name" ] = "鞭刃乱舞",
        [ "icon" ] = 511403202,
        [ "desc" ] = "对所有敌人造成111%伤害$destiny，本次攻击的暴击率上升40%，敌人受到的伤害提高10%，持续2回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "crit",
                [ "attr_value" ] = 0.4,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 111,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000056,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.4,
        },
    },
    [ 11404101 ] = {
        [ "id" ] = 11404101,
        [ "ch_key" ] = "收割",
        [ "name" ] = "收割",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11404102 ] = {
        [ "id" ] = 11404102,
        [ "ch_key" ] = "利刃狂涛",
        [ "name" ] = "利刃狂涛",
        [ "icon" ] = 511305216,
        [ "desc" ] = "对前排敌人造成152%伤害$destiny，18%概率造成眩晕",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.17,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.16,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.18,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.14,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.2,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 152,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.18,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
    [ 11404103 ] = {
        [ "id" ] = 11404103,
        [ "ch_key" ] = "恶徒怒火",
        [ "name" ] = "恶徒怒火",
        [ "icon" ] = 511305205,
        [ "desc" ] = "对前排敌人造成192%伤害$destiny，32%概率造成眩晕【与$unit共同出战可触发，由比尔发动】",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 14041,
        [ "spell_unit_list" ] = {
            [ 1 ] = 14062,
        },
        [ "first_spell_hero" ] = 14041,
        [ "second_spell_hero" ] = 14062,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.17,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.16,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.18,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.14,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.2,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 192,
        [ "hurt_grow_rate" ] = 4,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.32,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
    [ 11404104 ] = {
        [ "id" ] = 11404104,
        [ "ch_key" ] = "恶徒怒火1",
        [ "name" ] = "恶徒怒火1",
        [ "desc" ] = "对前排敌人造成192%伤害$destiny，32%概率造成眩晕【与$unit共同出战可触发，由比尔发动】",
        [ "spell_type" ] = 4,
        [ "super_spell_id" ] = 11404104,
        [ "spell_unit" ] = 14041,
        [ "spell_unit_list" ] = {
            [ 1 ] = 14062,
        },
        [ "first_spell_hero" ] = 14041,
        [ "second_spell_hero" ] = 14062,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.17,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.16,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.18,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.14,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.2,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 192,
        [ "hurt_grow_rate" ] = 4,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.32,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
    [ 11404201 ] = {
        [ "id" ] = 11404201,
        [ "ch_key" ] = "绞杀",
        [ "name" ] = "绞杀",
        [ "desc" ] = "对一列敌人造成80%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "attack_type" ] = 3,
        [ "spell_hurt_pct" ] = 80,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11404202 ] = {
        [ "id" ] = 11404202,
        [ "ch_key" ] = "血口獠牙",
        [ "name" ] = "血口獠牙",
        [ "icon" ] = 51404202,
        [ "desc" ] = "对一列敌人造成232%伤害$destiny，35%概率造成眩晕",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "attack_type" ] = 3,
        [ "spell_hurt_pct" ] = 232,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.35,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
    [ 11405201 ] = {
        [ "id" ] = 11405201,
        [ "ch_key" ] = "治疗",
        [ "name" ] = "治疗",
        [ "desc" ] = "治疗生命最少的1个友军（102%+150）",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 2,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 11,
        [ "fixed_hurt" ] = 150,
        [ "spell_hurt_pct" ] = 102,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11405202 ] = {
        [ "id" ] = 11405202,
        [ "ch_key" ] = "生化试剂",
        [ "name" ] = "生化试剂",
        [ "icon" ] = 511305234,
        [ "desc" ] = "治疗全体友军（116%+250）$destiny，对生命低于60%的友军额外治疗（50%）",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 2,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.6,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.2,
            },
        },
        [ "attack_type" ] = 12,
        [ "fixed_hurt" ] = 250,
        [ "spell_hurt_pct" ] = 116,
        [ "hurt_grow_rate" ] = 2,
        [ "cure_param" ] = {
            [ 1 ] = 60,
            [ 2 ] = 50,
        },
    },
    [ 11406101 ] = {
        [ "id" ] = 11406101,
        [ "ch_key" ] = "焚灭",
        [ "name" ] = "焚灭",
        [ "desc" ] = "对所有敌人造成40%伤害，造成灼烧效果【40%】",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.7,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 40,
        [ "hurt_grow_rate" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000001,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
    [ 11406102 ] = {
        [ "id" ] = 11406102,
        [ "ch_key" ] = "炎浪侵袭",
        [ "name" ] = "炎浪侵袭",
        [ "icon" ] = 51406102,
        [ "desc" ] = "对所有敌人造成115%伤害$destiny，造成灼烧效果【60%】，持续2回合，5%造成眩晕，本次攻击的命中率+30%",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.1,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.3,
            },
        },
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "hit",
                [ "attr_value" ] = 0.3,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 115,
        [ "hurt_grow_rate" ] = 4,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000015,
            [ 2 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 0.05,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
            [ 2 ] = 2,
        },
        [ "modify_attr_dict" ] = {
            [ "hit" ] = 0.3,
        },
    },
    [ 11406103 ] = {
        [ "id" ] = 11406103,
        [ "ch_key" ] = "焦热地狱",
        [ "name" ] = "焦热地狱",
        [ "icon" ] = 511106120,
        [ "desc" ] = "对所有敌人造成149%伤害$destiny，造成灼烧效果【100%】，持续2回合，15%造成眩晕，本次攻击的命中率+30%【与$unit共同出战可触发，由赫里奥发动】",
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 14061,
        [ "spell_unit_list" ] = {
            [ 1 ] = 14052,
        },
        [ "first_spell_hero" ] = 14061,
        [ "second_spell_hero" ] = 14052,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 7 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 8 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 9 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 10 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 11 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 12 ] = {
                [ "hurt_rate" ] = 0.12,
            },
        },
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "hit",
                [ "attr_value" ] = 0.3,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 149,
        [ "hurt_grow_rate" ] = 4,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000047,
            [ 2 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 0.15,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
            [ 2 ] = 2,
        },
        [ "modify_attr_dict" ] = {
            [ "hit" ] = 0.3,
        },
    },
    [ 11406104 ] = {
        [ "id" ] = 11406104,
        [ "ch_key" ] = "超·焦热地狱",
        [ "name" ] = "超·焦热地狱",
        [ "icon" ] = 511106120,
        [ "desc" ] = "对所有敌人造成161%伤害$destiny，造成不可被清除（抵抗1级清除）的灼烧效果（120%），持续2回合，20%造成眩晕，本次攻击的命中率+30%【与$unit共同出战可触发，由赫里奥发动】",
        [ "spell_type" ] = 4,
        [ "super_spell_id" ] = 11406104,
        [ "spell_unit" ] = 14061,
        [ "spell_unit_list" ] = {
            [ 1 ] = 14052,
        },
        [ "first_spell_hero" ] = 14061,
        [ "second_spell_hero" ] = 14052,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 6 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 7 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 8 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 9 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 10 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 11 ] = {
                [ "hurt_rate" ] = 0.08,
            },
            [ 12 ] = {
                [ "hurt_rate" ] = 0.12,
            },
        },
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "hit",
                [ "attr_value" ] = 0.3,
            },
        },
        [ "attack_type" ] = 1,
        [ "spell_hurt_pct" ] = 161,
        [ "hurt_grow_rate" ] = 4,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000072,
            [ 2 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 0.2,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
            [ 2 ] = 2,
        },
        [ "modify_attr_dict" ] = {
            [ "hit" ] = 0.3,
        },
    },
    [ 11406201 ] = {
        [ "id" ] = 11406201,
        [ "ch_key" ] = "撕裂",
        [ "name" ] = "撕裂",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11406202 ] = {
        [ "id" ] = 11406202,
        [ "ch_key" ] = "虐杀快感",
        [ "name" ] = "虐杀快感",
        [ "icon" ] = 511106119,
        [ "desc" ] = "对前排敌人造成152%伤害$destiny，50%概率降低敌人防御60%，持续1回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "attack_type" ] = 4,
        [ "spell_hurt_pct" ] = 152,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000008,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.5,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
    [ 11500401 ] = {
        [ "id" ] = 11500401,
        [ "ch_key" ] = "瑞克单射",
        [ "name" ] = "瑞克单射",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11500402 ] = {
        [ "id" ] = 11500402,
        [ "ch_key" ] = "毁灭射击",
        [ "name" ] = "毁灭射击",
        [ "icon" ] = 51500402,
        [ "desc" ] = "对后排敌人造成152%伤害$destiny，我方全体头目抗暴率提高40%，持续2回合",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 5,
        [ "spell_hurt_pct" ] = 152,
        [ "hurt_grow_rate" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000017,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 3,
        },
    },
    [ 11500501 ] = {
        [ "id" ] = 11500501,
        [ "ch_key" ] = "斧击",
        [ "name" ] = "斧击",
        [ "desc" ] = "这是英雄技能7",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 6,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 11500502 ] = {
        [ "id" ] = 11500502,
        [ "ch_key" ] = "回旋斧",
        [ "name" ] = "回旋斧",
        [ "icon" ] = 51500502,
        [ "desc" ] = "16%眩晕",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "attack_type" ] = 3,
        [ "spell_hurt_pct" ] = 221,
        [ "hurt_grow_rate" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.16,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
    [ 13500301 ] = {
        [ "id" ] = 13500301,
        [ "ch_key" ] = "宫崎普攻",
        [ "name" ] = "宫崎普攻",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 13500302 ] = {
        [ "id" ] = 13500302,
        [ "ch_key" ] = "棒球猛袭",
        [ "name" ] = "棒球猛袭",
        [ "icon" ] = 513500302,
        [ "desc" ] = "对后排敌人造成132%伤害$destiny",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 5,
        [ "spell_hurt_pct" ] = 132,
        [ "hurt_grow_rate" ] = 2,
    },
    [ 13500601 ] = {
        [ "id" ] = 13500601,
        [ "ch_key" ] = "枪撞",
        [ "name" ] = "枪撞",
        [ "desc" ] = "对后排单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "attack_type" ] = 6,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 13500602 ] = {
        [ "id" ] = 13500602,
        [ "ch_key" ] = "逃徒奋杀",
        [ "name" ] = "逃徒奋杀",
        [ "icon" ] = 513500602,
        [ "desc" ] = "对后排敌人造成132%伤害$destiny",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.2,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.2,
            },
        },
        [ "attack_type" ] = 5,
        [ "spell_hurt_pct" ] = 132,
        [ "hurt_grow_rate" ] = 3,
    },
    [ 13500901 ] = {
        [ "id" ] = 13500901,
        [ "ch_key" ] = "虎拳",
        [ "name" ] = "虎拳",
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "spell_type" ] = 1,
        [ "cost_anger" ] = 0,
        [ "add_anger" ] = 2,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.25,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.25,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 100,
        [ "hurt_grow_rate" ] = 0,
    },
    [ 13500902 ] = {
        [ "id" ] = 13500902,
        [ "ch_key" ] = "奔雷腿",
        [ "name" ] = "奔雷腿",
        [ "icon" ] = 511305235,
        [ "desc" ] = "对单个敌人造成300%伤害$destiny，40%概率眩晕",
        [ "spell_type" ] = 2,
        [ "cost_anger" ] = 4,
        [ "add_anger" ] = 0,
        [ "side_type" ] = 1,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 3 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 4 ] = {
                [ "hurt_rate" ] = 0.15,
            },
            [ 5 ] = {
                [ "hurt_rate" ] = 0.4,
            },
        },
        [ "attack_type" ] = 7,
        [ "spell_hurt_pct" ] = 300,
        [ "hurt_grow_rate" ] = 3,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.4,
        },
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
    },
}