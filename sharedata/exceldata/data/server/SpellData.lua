return {
    [ 11101101 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 2,
        [ "ch_key" ] = "裁决",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对敌方怒气最高的3个敌人造成65%伤害，20%概率减少2点怒气",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11101101,
        [ "name" ] = "裁决",
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.2,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 65,
        [ "spell_type" ] = 1,
    },
    [ 11101102 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000049,
        },
        [ "attack_type" ] = 2,
        [ "buff_object_list" ] = {
            [ 1 ] = 3,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "静电打击",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对敌方怒气最高的3个敌人造成175%伤害$destiny，50%概率减少2点怒气，我方全体闪避提高10%，持续2回合。",
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
        [ "hurt_grow_rate" ] = 0,
        [ "icon" ] = 511305214,
        [ "id" ] = 11101102,
        [ "name" ] = "静电打击",
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.5,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 175,
        [ "spell_type" ] = 2,
    },
    [ 11101103 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000046,
        },
        [ "attack_type" ] = 2,
        [ "buff_object_list" ] = {
            [ 1 ] = 3,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "过载脉冲",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对敌方怒气最高的3个敌人造成227%伤害$destiny，80%概率减少2点怒气，我方全体闪避提高15%，持续2回合。【与$unit共同出战可触发，由科尔特发动】",
        [ "first_spell_hero" ] = 11011,
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
        [ "hurt_grow_rate" ] = 0,
        [ "icon" ] = 511305208,
        [ "id" ] = 11101103,
        [ "name" ] = "过载脉冲",
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.8,
        [ "second_spell_hero" ] = 11041,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 227,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 11011,
        [ "spell_unit_list" ] = {
            [ 1 ] = 11043,
        },
    },
    [ 11101104 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000075,
        },
        [ "attack_type" ] = 2,
        [ "buff_object_list" ] = {
            [ 1 ] = 3,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "超·过载脉冲",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对敌方怒气最高的3个敌人造成245%伤害$destiny，减少2点怒气，我方全体闪避提高20%，持续2回合。【与$unit共同出战可触发，由科尔特发动】",
        [ "first_spell_hero" ] = 11011,
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
        [ "hurt_grow_rate" ] = 0,
        [ "icon" ] = 511305208,
        [ "id" ] = 11101104,
        [ "name" ] = "超·过载脉冲",
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 1,
        [ "second_spell_hero" ] = 11041,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 245,
        [ "spell_type" ] = 4,
        [ "spell_unit" ] = 11011,
        [ "spell_unit_list" ] = {
            [ 1 ] = 11043,
        },
        [ "super_spell_id" ] = 11101104,
    },
    [ 11101201 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 9,
        [ "ch_key" ] = "镭击",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11101201,
        [ "name" ] = "镭击",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11101202 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 4,
        [ "ch_key" ] = "电能冲击",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成152%伤害$destiny，本次攻击的暴击率上升40%",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 51101202,
        [ "id" ] = 11101202,
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "crit",
                [ "attr_value" ] = 0.4,
            },
        },
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.4,
        },
        [ "name" ] = "电能冲击",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 152,
        [ "spell_type" ] = 2,
    },
    [ 11102201 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "劲矢",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11102201,
        [ "name" ] = "劲矢",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11102202 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000064,
        },
        [ "attack_type" ] = 4,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.2,
        },
        [ "ch_key" ] = "猎杀本能",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成152%伤害，20%概率降低敌人攻击30%，持续2回合",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511106116,
        [ "id" ] = 11102202,
        [ "name" ] = "猎杀本能",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 152,
        [ "spell_type" ] = 2,
    },
    [ 11103101 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 3,
        [ "ch_key" ] = "凶星",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对一列敌人造成80%伤害",
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
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11103101,
        [ "name" ] = "凶星",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 80,
        [ "spell_type" ] = 1,
    },
    [ 11103102 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000011,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "军火仲裁",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对所有敌人造成111%伤害$destiny，自身的闪避率提高30%，持续2回合",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 51103102,
        [ "id" ] = 11103102,
        [ "name" ] = "军火仲裁",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 111,
        [ "spell_type" ] = 2,
    },
    [ 11103103 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000013,
            [ 2 ] = 20000012,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 3,
            [ 2 ] = 1,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
        [ "ch_key" ] = "枪林刃雨",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对所有敌人造成144%伤害$destiny，自身的伤害提高40%，闪避率提高40%，持续2回合【与$unit共同出战可触发，由代号：六发动】",
        [ "first_spell_hero" ] = 11031,
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
        [ "hurt_grow_rate" ] = 4,
        [ "icon" ] = 51103103,
        [ "id" ] = 11103103,
        [ "name" ] = "枪林刃雨",
        [ "second_spell_hero" ] = 11051,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 144,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 11031,
        [ "spell_unit_list" ] = {
            [ 1 ] = 11051,
        },
    },
    [ 11103201 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "压制",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11103201,
        [ "name" ] = "压制",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11103202 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "attack_type" ] = 7,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.75,
        },
        [ "ch_key" ] = "烈焰回声",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对单个敌人造成300%伤害$destiny，75%概率造成眩晕",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 51103203,
        [ "id" ] = 11103202,
        [ "name" ] = "烈焰回声",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 300,
        [ "spell_type" ] = 2,
    },
    [ 11104201 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "痛殴",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11104201,
        [ "name" ] = "痛殴",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11104202 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000009,
        },
        [ "attack_type" ] = 4,
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "亿吨重拳",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成152%伤害$destiny，自身受到伤害降低55%，持续2回合",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 51104202,
        [ "id" ] = 11104202,
        [ "name" ] = "亿吨重拳",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 152,
        [ "spell_type" ] = 2,
    },
    [ 11104203 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000009,
            [ 2 ] = 20000010,
        },
        [ "attack_type" ] = 5,
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 3,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
        [ "ch_key" ] = "狂乱蹂躏",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对后排敌人造成185%伤害$destiny，自身受到伤害降低55%，我方全体头目抗暴率+30%，持续2回合【与$unit共同出战可触发，由亨利发动】",
        [ "first_spell_hero" ] = 11042,
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
        [ "hurt_grow_rate" ] = 4,
        [ "icon" ] = 51104203,
        [ "id" ] = 11104203,
        [ "name" ] = "狂乱蹂躏",
        [ "second_spell_hero" ] = 11032,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 185,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 11042,
        [ "spell_unit_list" ] = {
            [ 1 ] = 11032,
        },
    },
    [ 11104311 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 1,
        [ "ch_key" ] = "血疗",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "治疗全体友军（48%+150）",
        [ "fixed_hurt" ] = 150,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11104311,
        [ "name" ] = "血疗",
        [ "side_type" ] = 2,
        [ "spell_hurt_pct" ] = 48,
        [ "spell_type" ] = 1,
    },
    [ 11104312 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 1,
        [ "buff_clear_level" ] = 1,
        [ "buff_clear_ratio" ] = 0.8,
        [ "ch_key" ] = "愈合激素",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "治疗全体友军（116%+250），80%概率清除（抵抗1级清除）我方所有不利状态，本次治疗的暴击率提升10%",
        [ "fixed_hurt" ] = 250,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 2,
        [ "icon" ] = 511305220,
        [ "id" ] = 11104312,
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "crit",
                [ "attr_value" ] = 0.1,
            },
        },
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.1,
        },
        [ "name" ] = "愈合激素",
        [ "side_type" ] = 2,
        [ "spell_hurt_pct" ] = 116,
        [ "spell_type" ] = 2,
    },
    [ 11105101 ] = {
        [ "add_anger" ] = 1,
        [ "attack_type" ] = 4,
        [ "ch_key" ] = "刃返",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对前排敌人造成70%伤害",
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
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11105101,
        [ "name" ] = "刃返",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 70,
        [ "spell_type" ] = 1,
    },
    [ 11105102 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "attack_type" ] = 4,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.19,
        },
        [ "ch_key" ] = "秘·居合",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成159%伤害$destiny，19%概率造成眩晕",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 51105102,
        [ "id" ] = 11105102,
        [ "name" ] = "秘·居合",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 159,
        [ "spell_type" ] = 2,
    },
    [ 11105103 ] = {
        [ "add_anger" ] = 1,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "刃返1",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对前排敌人造成70%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11105103,
        [ "name" ] = "刃返1",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 70,
        [ "spell_type" ] = 1,
    },
    [ 11105104 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 1,
        [ "ch_key" ] = "秘·居合1",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成159%伤害$destiny，19%概率造成眩晕",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 51105102,
        [ "id" ] = 11105104,
        [ "is_second_kill" ] = true,
        [ "name" ] = "秘·居合1",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 159,
        [ "spell_type" ] = 2,
    },
    [ 11105201 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "猛踢",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11105201,
        [ "name" ] = "猛踢",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11105202 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 4,
        [ "ch_key" ] = "致命律动",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成152%伤害$destiny",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 51105202,
        [ "id" ] = 11105202,
        [ "name" ] = "致命律动",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 152,
        [ "spell_type" ] = 2,
    },
    [ 11105203 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000046,
        },
        [ "attack_type" ] = 4,
        [ "buff_object_list" ] = {
            [ 1 ] = 3,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "末路逆袭",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成197%伤害$destiny，我方全体头目的闪避率提高15%，持续2回合【与$unit共同出战可触发，由贝蒂发动】",
        [ "first_spell_hero" ] = 11052,
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511106118,
        [ "id" ] = 11105203,
        [ "name" ] = "末路逆袭",
        [ "second_spell_hero" ] = 14051,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 197,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 11052,
        [ "spell_unit_list" ] = {
            [ 1 ] = 14051,
        },
    },
    [ 11106101 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 6,
        [ "ch_key" ] = "侵扰",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害，20%概率减少1怒气",
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
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11106101,
        [ "name" ] = "侵扰",
        [ "reduce_anger" ] = 1,
        [ "reduce_anger_level" ] = 1,
        [ "reduce_anger_ratio" ] = 0.2,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11106102 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 3,
        [ "ch_key" ] = "贯穿之矢",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对一列敌人造成232%伤害$destiny，减少1点怒气",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511106109,
        [ "id" ] = 11106102,
        [ "name" ] = "贯穿之矢",
        [ "reduce_anger" ] = 1,
        [ "reduce_anger_level" ] = 1,
        [ "reduce_anger_ratio" ] = 1,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 232,
        [ "spell_type" ] = 2,
    },
    [ 11106201 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 9,
        [ "ch_key" ] = "暴怒",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11106201,
        [ "name" ] = "暴怒",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11106202 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000008,
        },
        [ "attack_type" ] = 3,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.5,
        },
        [ "ch_key" ] = "终极爆弹",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对一列敌人造成221%伤害$destiny，50%概率降低敌人防御60%，持续1回合",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511305210,
        [ "id" ] = 11106202,
        [ "name" ] = "终极爆弹",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 221,
        [ "spell_type" ] = 2,
    },
    [ 11106203 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 4,
        [ "ch_key" ] = "火力全开",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成197%伤害$destiny，本次攻击的暴击率和命中率上升65%【与$unit共同出战可触发，由阿尔法发动】",
        [ "first_spell_hero" ] = 11062,
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
        [ "hurt_grow_rate" ] = 4,
        [ "icon" ] = 51106203,
        [ "id" ] = 11106203,
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
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.65,
            [ "hit" ] = 0.65,
        },
        [ "name" ] = "火力全开",
        [ "second_spell_hero" ] = 11012,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 197,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 11062,
        [ "spell_unit_list" ] = {
            [ 1 ] = 11012,
        },
    },
    [ 11106204 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 1,
        [ "ch_key" ] = "火力全开1",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "暂无",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "icon" ] = 511305210,
        [ "id" ] = 11106204,
        [ "is_second_kill" ] = true,
        [ "name" ] = "火力全开1",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 2,
    },
    [ 11106205 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 4,
        [ "ch_key" ] = "超·火力全开2",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成197%伤害$destiny，本次攻击的暴击率和命中率上升65%【与$unit共同出战可触发，由阿尔法发动】",
        [ "first_spell_hero" ] = 11062,
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
        [ "hurt_grow_rate" ] = 4,
        [ "icon" ] = 51106203,
        [ "id" ] = 11106205,
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
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.65,
            [ "hit" ] = 0.65,
        },
        [ "name" ] = "超·火力全开2",
        [ "second_spell_hero" ] = 11012,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 197,
        [ "spell_type" ] = 4,
        [ "spell_unit" ] = 11062,
        [ "spell_unit_list" ] = {
            [ 1 ] = 11012,
        },
        [ "super_spell_id" ] = 11106205,
    },
    [ 11106206 ] = {
        [ "add_anger" ] = 1,
        [ "attack_type" ] = 9,
        [ "ch_key" ] = "暴怒1",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11106206,
        [ "name" ] = "暴怒1",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11110211 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 1,
        [ "ch_key" ] = "暴走",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对所有敌人造成40%伤害，本次攻击命中率和暴击率额外提升30%",
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
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11110211,
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
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.3,
            [ "hit" ] = 0.3,
        },
        [ "name" ] = "暴走",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 40,
        [ "spell_type" ] = 1,
    },
    [ 11110212 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.1,
        },
        [ "ch_key" ] = "裂地重锤",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对所有敌人造成115%伤害$destiny，10%概率造成眩晕，本次攻击命中率和暴击率额外提升30%",
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
        [ "hurt_grow_rate" ] = 2,
        [ "icon" ] = 511110112,
        [ "id" ] = 11110212,
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
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.3,
            [ "hit" ] = 0.3,
        },
        [ "name" ] = "裂地重锤",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 115,
        [ "spell_type" ] = 2,
    },
    [ 11110213 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.15,
        },
        [ "ch_key" ] = "区域肃清",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对所有敌人造成149%伤害$destiny，15%概率造成眩晕，本次攻击命中率和暴击率额外提升50%【与$unit共同出战可触发，由亚当触发】",
        [ "first_spell_hero" ] = 11021,
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
        [ "hurt_grow_rate" ] = 2,
        [ "icon" ] = 511305219,
        [ "id" ] = 11110213,
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
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.5,
            [ "hit" ] = 0.5,
        },
        [ "name" ] = "区域肃清",
        [ "second_spell_hero" ] = 11061,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 149,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 11021,
        [ "spell_unit_list" ] = {
            [ 1 ] = 11061,
        },
    },
    [ 11110214 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.2,
        },
        [ "ch_key" ] = "超·区域肃清",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对所有敌人造成161%伤害$destiny，20%概率造成眩晕，本次攻击必命中和必暴击率【与$unit共同出战可触发，由亚当触发】",
        [ "first_spell_hero" ] = 11021,
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
        [ "hurt_grow_rate" ] = 2,
        [ "icon" ] = 511305219,
        [ "id" ] = 11110214,
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
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 1,
            [ "hit" ] = 1,
        },
        [ "name" ] = "超·区域肃清",
        [ "second_spell_hero" ] = 11061,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 161,
        [ "spell_type" ] = 4,
        [ "spell_unit" ] = 11021,
        [ "spell_unit_list" ] = {
            [ 1 ] = 11061,
        },
        [ "super_spell_id" ] = 11110214,
    },
    [ 11110215 ] = {
        [ "add_anger" ] = 1,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "暴走1",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对所有敌人造成40%伤害，本次攻击命中率和暴击率额外提升30%",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11110215,
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
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.3,
            [ "hit" ] = 0.3,
        },
        [ "name" ] = "暴走1",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 40,
        [ "spell_type" ] = 1,
    },
    [ 11110216 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.1,
        },
        [ "ch_key" ] = "裂地重锤1",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对所有敌人造成115%伤害$destiny，10%概率造成眩晕，本次攻击命中率和暴击率额外提升30%",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 2,
        [ "icon" ] = 511110112,
        [ "id" ] = 11110216,
        [ "is_second_kill" ] = true,
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
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.3,
            [ "hit" ] = 0.3,
        },
        [ "name" ] = "裂地重锤1",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 115,
        [ "spell_type" ] = 2,
    },
    [ 11140121 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 6,
        [ "ch_key" ] = "低语",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对后排单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11140121,
        [ "name" ] = "低语",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11140122 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 5,
        [ "ch_key" ] = "死亡通牒",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对后排敌人造成152%伤害$destiny，50%概率减少1点怒气",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 51140122,
        [ "id" ] = 11140122,
        [ "name" ] = "死亡通牒",
        [ "reduce_anger" ] = 1,
        [ "reduce_anger_level" ] = 1,
        [ "reduce_anger_ratio" ] = 0.5,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 152,
        [ "spell_type" ] = 2,
    },
    [ 11140123 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000063,
        },
        [ "attack_type" ] = 5,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "死亡通牒1",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对后排敌人造成197%伤害$destiny，70%概率减少1点怒气，降低敌人攻击20%，持续2回合【与$unit共同出战可触发，由米娅触发】",
        [ "first_spell_hero" ] = 14022,
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 51140122,
        [ "id" ] = 11140123,
        [ "name" ] = "死亡通牒1",
        [ "reduce_anger" ] = 1,
        [ "reduce_anger_level" ] = 1,
        [ "reduce_anger_ratio" ] = 0.7,
        [ "second_spell_hero" ] = 11022,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 197,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 14012,
        [ "spell_unit_list" ] = {
            [ 1 ] = 11022,
        },
    },
    [ 11140511 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 11,
        [ "ch_key" ] = "急救",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "治疗生命最少的1个友军（94%+100）",
        [ "fixed_hurt" ] = 100,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11140511,
        [ "name" ] = "急救",
        [ "side_type" ] = 2,
        [ "spell_hurt_pct" ] = 94,
        [ "spell_type" ] = 1,
    },
    [ 11140512 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 1,
        [ "ch_key" ] = "治愈之风",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "治疗全体友军（110%+200）$destiny",
        [ "fixed_hurt" ] = 200,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 2,
        [ "icon" ] = 51140512,
        [ "id" ] = 11140512,
        [ "name" ] = "治愈之风",
        [ "side_type" ] = 2,
        [ "spell_hurt_pct" ] = 110,
        [ "spell_type" ] = 2,
    },
    [ 11201101 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "挥击",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11201101,
        [ "name" ] = "挥击",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11201102 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000002,
        },
        [ "attack_type" ] = 3,
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "怒火链枷",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对一列敌人造成221%伤害$destiny，自身无敌一回合",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511305217,
        [ "id" ] = 11201102,
        [ "name" ] = "怒火链枷",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 221,
        [ "spell_type" ] = 2,
    },
    [ 11201103 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000002,
        },
        [ "attack_type" ] = 3,
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "残忍无情",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对一列敌人造成287%伤害$destiny，自身无敌一回合，本次攻击暴击率和命中率提升70%",
        [ "first_spell_hero" ] = 12011,
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511201103,
        [ "id" ] = 11201103,
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
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.7,
            [ "hit" ] = 0.7,
        },
        [ "name" ] = "残忍无情",
        [ "second_spell_hero" ] = 12032,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 287,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 12011,
        [ "spell_unit_list" ] = {
            [ 1 ] = 12032,
        },
    },
    [ 11201201 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 4,
        [ "ch_key" ] = "重锤",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对前排敌人造成70%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 3,
        [ "id" ] = 11201201,
        [ "name" ] = "重锤",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 152,
        [ "spell_type" ] = 1,
    },
    [ 11201202 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
            [ 2 ] = 20000061,
        },
        [ "attack_type" ] = 4,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
            [ 2 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.2,
            [ 2 ] = 1,
        },
        [ "ch_key" ] = "大地震颤",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成159%伤害$destiny，20%概率造成眩晕，造成流血效果（30%），持续2回合",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 4,
        [ "icon" ] = 511201202,
        [ "id" ] = 11201202,
        [ "name" ] = "大地震颤",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 159,
        [ "spell_type" ] = 2,
    },
    [ 11202101 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "烈弹",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11202101,
        [ "name" ] = "烈弹",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11202102 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000027,
        },
        [ "attack_type" ] = 4,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "最终弹幕",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成152%伤害$destiny，敌人造成的伤害降低10%，持续2回合",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511106137,
        [ "id" ] = 11202102,
        [ "name" ] = "最终弹幕",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 152,
        [ "spell_type" ] = 2,
    },
    [ 11202311 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 11,
        [ "ch_key" ] = "挽救",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "治疗生命最少的1个友军（102%+150）",
        [ "fixed_hurt" ] = 150,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11202311,
        [ "name" ] = "挽救",
        [ "side_type" ] = 2,
        [ "spell_hurt_pct" ] = 102,
        [ "spell_type" ] = 1,
    },
    [ 11202312 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000028,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 5,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "战场急救",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "治疗全体友军（116%+250）$destiny，我方随机1个头目增加2点怒气",
        [ "fixed_hurt" ] = 250,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 2,
        [ "icon" ] = 511106135,
        [ "id" ] = 11202312,
        [ "name" ] = "战场急救",
        [ "side_type" ] = 2,
        [ "spell_hurt_pct" ] = 116,
        [ "spell_type" ] = 2,
    },
    [ 11203101 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 1,
        [ "ch_key" ] = "重击",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对所有敌人造成40%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11203101,
        [ "name" ] = "重击",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 40,
        [ "spell_type" ] = 1,
    },
    [ 11203102 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000059,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "所向披靡",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对所有敌人造成111%伤害$destiny，敌人受到伤害提升12%，持续2回合",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511106128,
        [ "id" ] = 11203102,
        [ "name" ] = "所向披靡",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 115,
        [ "spell_type" ] = 2,
    },
    [ 11203103 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000062,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "狂乱锤击",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对所有敌人造成144%伤害$destiny，30%概率减少2点怒气，敌人受到伤害提升18%，持续2回合【与$unit共同出战可触发，由艾伦发动】",
        [ "first_spell_hero" ] = 12031,
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
        [ "hurt_grow_rate" ] = 4,
        [ "icon" ] = 511305232,
        [ "id" ] = 11203103,
        [ "name" ] = "狂乱锤击",
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.3,
        [ "second_spell_hero" ] = 12012,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 144,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 12031,
        [ "spell_unit_list" ] = {
            [ 1 ] = 12012,
        },
    },
    [ 11203104 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000062,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "狂乱锤击1",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对所有敌人造成144%伤害$destiny，30%概率减少2点怒气，敌人受到伤害提升18%，持续2回合【与$unit共同出战可触发，由艾伦发动】",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 4,
        [ "id" ] = 11203104,
        [ "name" ] = "狂乱锤击1",
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.3,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 144,
        [ "spell_type" ] = 2,
    },
    [ 11203201 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "突刺",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11203201,
        [ "name" ] = "突刺",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11203202 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 4,
        [ "ch_key" ] = "野蛮打击",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成152%伤害$destiny，本次攻击的命中率和暴击率上升40%",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511305228,
        [ "id" ] = 11203202,
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
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.4,
            [ "hit" ] = 0.4,
        },
        [ "name" ] = "野蛮打击",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 152,
        [ "spell_type" ] = 2,
    },
    [ 11204101 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "精准",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
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
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11204101,
        [ "name" ] = "精准",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11204102 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "attack_type" ] = 7,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.4,
        },
        [ "ch_key" ] = "疾风骤雨",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对单个敌人造成300%伤害$destiny，40%概率造成眩晕",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511204102,
        [ "id" ] = 11204102,
        [ "name" ] = "疾风骤雨",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 300,
        [ "spell_type" ] = 2,
    },
    [ 11204103 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
            [ 2 ] = 20000048,
        },
        [ "attack_type" ] = 7,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
            [ 2 ] = 1,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 0.2,
        },
        [ "ch_key" ] = "死亡艺术",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对单个敌人造成390%伤害$destiny，100%概率造成眩晕，20%概率自身增加4点怒气【与$unit共同出战可触发，由蝎子发动】",
        [ "first_spell_hero" ] = 12041,
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
        [ "hurt_grow_rate" ] = 4,
        [ "icon" ] = 511106127,
        [ "id" ] = 11204103,
        [ "name" ] = "死亡艺术",
        [ "second_spell_hero" ] = 12052,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 390,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 12041,
        [ "spell_unit_list" ] = {
            [ 1 ] = 12052,
        },
    },
    [ 11204104 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
            [ 2 ] = 20000048,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
            [ 2 ] = 1,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 0.2,
        },
        [ "ch_key" ] = "死亡艺术1",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对单个敌人造成390%伤害$destiny，100%概率造成眩晕，20%概率自身增加4点怒气【与$unit共同出战可触发，由蝎子发动】",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 4,
        [ "icon" ] = 511204102,
        [ "id" ] = 11204104,
        [ "is_second_kill" ] = true,
        [ "name" ] = "死亡艺术1",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 390,
        [ "spell_type" ] = 2,
        [ "super_spell_id" ] = 11204104,
    },
    [ 11204105 ] = {
        [ "add_anger" ] = 1,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "精准1",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
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
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11204105,
        [ "name" ] = "精准1",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11204201 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 6,
        [ "ch_key" ] = "抹杀",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对后排单体造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11204201,
        [ "name" ] = "抹杀",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11204202 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000009,
        },
        [ "attack_type" ] = 6,
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "阴影袭杀",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对后排单个敌人造成315%伤害$destiny，80%减少4点怒气，自身受到伤害降低55%，持续2回合",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511106134,
        [ "id" ] = 11204202,
        [ "name" ] = "阴影袭杀",
        [ "reduce_anger" ] = 4,
        [ "reduce_anger_level" ] = 4,
        [ "reduce_anger_ratio" ] = 0.8,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 315,
        [ "spell_type" ] = 2,
    },
    [ 11205111 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 1,
        [ "ch_key" ] = "电击",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对所有敌人造成40%伤害，10%概率减少2点怒气",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11205111,
        [ "name" ] = "电击",
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.1,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 40,
        [ "spell_type" ] = 1,
    },
    [ 11205112 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000029,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 6,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "磁电链接",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对所有敌人造成115%伤害$destiny，25%概率减少2点怒气，我方随机2个头目伤害提高20%，持续2回合",
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
        [ "hurt_grow_rate" ] = 2,
        [ "icon" ] = 511205112,
        [ "id" ] = 11205112,
        [ "name" ] = "磁电链接",
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.25,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 115,
        [ "spell_type" ] = 2,
    },
    [ 11205113 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000018,
            [ 2 ] = 20000019,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 3,
            [ 2 ] = 3,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
        [ "ch_key" ] = "失控电荷",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对所有敌人造成149%伤害$destiny，40%概率减少2点怒气，我方全体头目伤害和命中率提高20%，持续2回合【与$unit共同出战可触发，由朱可夫发动】",
        [ "first_spell_hero" ] = 12051,
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
        [ "hurt_grow_rate" ] = 2,
        [ "icon" ] = 511305223,
        [ "id" ] = 11205113,
        [ "name" ] = "失控电荷",
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.4,
        [ "second_spell_hero" ] = 12022,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 149,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 12051,
        [ "spell_unit_list" ] = {
            [ 1 ] = 12023,
        },
    },
    [ 11205114 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000070,
            [ 2 ] = 20000071,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 3,
            [ 2 ] = 3,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
        [ "ch_key" ] = "超·失控电荷",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对所有敌人造成161%伤害$destiny，50%概率减少2点怒气，我方全体头目伤害和命中率提高30%，持续2回合【与$unit共同出战可触发，由朱可夫发动】",
        [ "first_spell_hero" ] = 12051,
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
        [ "hurt_grow_rate" ] = 2,
        [ "icon" ] = 511305223,
        [ "id" ] = 11205114,
        [ "name" ] = "超·失控电荷",
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.5,
        [ "second_spell_hero" ] = 12022,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 161,
        [ "spell_type" ] = 4,
        [ "spell_unit" ] = 12051,
        [ "spell_unit_list" ] = {
            [ 1 ] = 12023,
        },
        [ "super_spell_id" ] = 11205114,
    },
    [ 11205201 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "击弦",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11205201,
        [ "name" ] = "击弦",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11205202 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "attack_type" ] = 4,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.18,
        },
        [ "ch_key" ] = "致命和弦",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成152%伤害$destiny，18%概率造成眩晕",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511305230,
        [ "id" ] = 11205202,
        [ "name" ] = "致命和弦",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 152,
        [ "spell_type" ] = 2,
    },
    [ 11206101 ] = {
        [ "add_anger" ] = 2,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000055,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "锯鲨",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对所有敌人造成40%伤害，敌人受到的伤害增加5%，持续2回合",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11206101,
        [ "name" ] = "锯鲨",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 40,
        [ "spell_type" ] = 1,
    },
    [ 11206102 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000056,
            [ 2 ] = 20000005,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
            [ 2 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 0.05,
        },
        [ "ch_key" ] = "锯鲨风暴",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对所有敌人造成115%伤害$destiny，5%概率造成眩晕，敌人受到的伤害增加10%，持续2回合",
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
        [ "hurt_grow_rate" ] = 2,
        [ "icon" ] = 511305215,
        [ "id" ] = 11206102,
        [ "name" ] = "锯鲨风暴",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 115,
        [ "spell_type" ] = 2,
    },
    [ 11206103 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000057,
            [ 2 ] = 20000005,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
            [ 2 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 0.15,
        },
        [ "ch_key" ] = "残虐猛击",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对所有敌人造成149%伤害$destiny，15%概率造成眩晕，敌人受到的伤害增加15%，持续2回合【与$unit共同出战可触发，由剃刀发动】",
        [ "first_spell_hero" ] = 12061,
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
        [ "hurt_grow_rate" ] = 2,
        [ "icon" ] = 511206103,
        [ "id" ] = 11206103,
        [ "name" ] = "残虐猛击",
        [ "second_spell_hero" ] = 12042,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 149,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 12061,
        [ "spell_unit_list" ] = {
            [ 1 ] = 12042,
        },
    },
    [ 11206104 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000069,
            [ 2 ] = 20000005,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
            [ 2 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 0.2,
        },
        [ "ch_key" ] = "超·残虐猛击",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对所有敌人造成161%伤害$destiny，20%概率造成眩晕，敌人受到的伤害增加20%，持续2回合【与$unit共同出战可触发，由剃刀发动】",
        [ "first_spell_hero" ] = 12061,
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
        [ "hurt_grow_rate" ] = 2,
        [ "icon" ] = 511206103,
        [ "id" ] = 11206104,
        [ "name" ] = "超·残虐猛击",
        [ "second_spell_hero" ] = 12042,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 161,
        [ "spell_type" ] = 4,
        [ "spell_unit" ] = 12061,
        [ "spell_unit_list" ] = {
            [ 1 ] = 12042,
        },
        [ "super_spell_id" ] = 11206104,
    },
    [ 11206201 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "处决",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11206201,
        [ "name" ] = "处决",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11206202 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000020,
        },
        [ "attack_type" ] = 4,
        [ "buff_object_list" ] = {
            [ 1 ] = 6,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "剑影重重",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成152%伤害$destiny，我方随即2个头目防御提高30%，持续2回合",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511305213,
        [ "id" ] = 11206202,
        [ "name" ] = "剑影重重",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 152,
        [ "spell_type" ] = 2,
    },
    [ 11206203 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 4,
        [ "ch_key" ] = "英伦杀机",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成197%伤害$destiny，本次攻击的暴击率和命中率上升65%【与$unit共同出战可触发，由阿尔法发动】",
        [ "first_spell_hero" ] = 12062,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "hurt_grow_rate" ] = 4,
        [ "icon" ] = 511305229,
        [ "id" ] = 11206203,
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
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.65,
            [ "hit" ] = 0.65,
        },
        [ "name" ] = "英伦杀机",
        [ "second_spell_hero" ] = 12021,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 197,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 12062,
        [ "spell_unit_list" ] = {
            [ 1 ] = 12021,
        },
    },
    [ 11206204 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 4,
        [ "ch_key" ] = "英伦杀机1",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成197%伤害$destiny，本次攻击的暴击率和命中率上升65%【与$unit共同出战可触发，由阿尔法发动】",
        [ "first_spell_hero" ] = 12062,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "hurt_grow_rate" ] = 4,
        [ "id" ] = 11206204,
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
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.65,
            [ "hit" ] = 0.65,
        },
        [ "name" ] = "英伦杀机1",
        [ "second_spell_hero" ] = 12021,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 197,
        [ "spell_type" ] = 4,
        [ "spell_unit" ] = 12062,
        [ "spell_unit_list" ] = {
            [ 1 ] = 12021,
        },
        [ "super_spell_id" ] = 11206204,
    },
    [ 11301101 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 3,
        [ "ch_key" ] = "诸刃",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对一列敌人造成80%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11301101,
        [ "name" ] = "诸刃",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 80,
        [ "spell_type" ] = 1,
    },
    [ 11301102 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000028,
        },
        [ "attack_type" ] = 3,
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.5,
        },
        [ "ch_key" ] = "忍法·鹰落",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对一列敌人造成221%伤害$destiny，50%概率恢复自身2点怒气",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511305221,
        [ "id" ] = 11301102,
        [ "name" ] = "忍法·鹰落",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 221,
        [ "spell_type" ] = 2,
    },
    [ 11301103 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000048,
            [ 2 ] = 20000063,
        },
        [ "attack_type" ] = 3,
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.5,
            [ 2 ] = 1,
        },
        [ "ch_key" ] = "最佳战略",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对一列敌人造成287%伤害$destiny，50%概率恢复自身4点怒气，敌人的攻击力降低20%，持续2回合",
        [ "first_spell_hero" ] = 13011,
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511305231,
        [ "id" ] = 11301103,
        [ "name" ] = "最佳战略",
        [ "second_spell_hero" ] = 13031,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 221,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 13011,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13031,
        },
    },
    [ 11301104 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000048,
            [ 2 ] = 20000063,
        },
        [ "attack_type" ] = 3,
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.5,
            [ 2 ] = 1,
        },
        [ "ch_key" ] = "最佳战略1",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对一列敌人造成287%伤害$destiny，50%概率恢复自身4点怒气，敌人的攻击力降低20%，持续2回合",
        [ "first_spell_hero" ] = 13011,
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
        [ "hurt_grow_rate" ] = 3,
        [ "id" ] = 11301104,
        [ "name" ] = "最佳战略1",
        [ "second_spell_hero" ] = 13031,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 221,
        [ "spell_type" ] = 4,
        [ "spell_unit" ] = 13011,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13031,
        },
        [ "super_spell_id" ] = 11301104,
    },
    [ 11301201 ] = {
        [ "add_anger" ] = 2,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000028,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.5,
        },
        [ "ch_key" ] = "落刃",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对所有敌人造成40%伤害，50%概率恢复自身2点怒气。",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11301201,
        [ "name" ] = "落刃",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 40,
        [ "spell_type" ] = 1,
    },
    [ 11301202 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000048,
            [ 2 ] = 20000053,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.5,
            [ 2 ] = 1,
        },
        [ "ch_key" ] = "一字皆杀",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对所有敌人造成115%伤害$destiny，50%概率恢复自身4点怒气，自身伤害提高25%，持续2回合。",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 4,
        [ "icon" ] = 511106133,
        [ "id" ] = 11301202,
        [ "name" ] = "一字皆杀",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 115,
        [ "spell_type" ] = 2,
    },
    [ 11301203 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000048,
            [ 2 ] = 20000054,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.5,
            [ 2 ] = 1,
        },
        [ "ch_key" ] = "向死而生",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对所有敌人造成149%伤害$destiny，50%概率恢复自身4点怒气，自身伤害提高30%，持续2回合。【与$unit共同出战可发动，由龙王发动】",
        [ "first_spell_hero" ] = 13012,
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
        [ "hurt_grow_rate" ] = 4,
        [ "icon" ] = 511305226,
        [ "id" ] = 11301203,
        [ "name" ] = "向死而生",
        [ "second_spell_hero" ] = 13032,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 149,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 13012,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13043,
        },
    },
    [ 11301204 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000048,
            [ 2 ] = 20000054,
        },
        [ "attack_type" ] = 1,
        [ "buff_clear_level" ] = 1,
        [ "buff_clear_ratio" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
        [ "ch_key" ] = "超·向死而生",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对所有敌人造成161%伤害$destiny，恢复自身4点怒气，自身伤害提高50%，同时免疫（1级抵御）所有减益状态，持续2回合，此技能有50%的额外命中率和暴击率。【与$unit共同出战可发动，由龙王发动】",
        [ "first_spell_hero" ] = 13012,
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
        [ "hurt_grow_rate" ] = 4,
        [ "icon" ] = 511305226,
        [ "id" ] = 11301204,
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
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.5,
            [ "hit" ] = 0.5,
        },
        [ "name" ] = "超·向死而生",
        [ "second_spell_hero" ] = 13032,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 161,
        [ "spell_type" ] = 4,
        [ "spell_unit" ] = 13012,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13043,
        },
        [ "super_spell_id" ] = 11301204,
    },
    [ 11302101 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 6,
        [ "ch_key" ] = "怒龙",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对后排单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11302101,
        [ "name" ] = "怒龙",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11302102 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 5,
        [ "ch_key" ] = "精武之怒",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对后排敌人造成152%伤害$destiny",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511106111,
        [ "id" ] = 11302102,
        [ "name" ] = "精武之怒",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 152,
        [ "spell_type" ] = 2,
    },
    [ 11302201 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "扇舞",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.3,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.7,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11302201,
        [ "name" ] = "扇舞",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11302202 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000066,
        },
        [ "attack_type" ] = 3,
        [ "buff_object_list" ] = {
            [ 1 ] = 6,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "飞扇连击",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对一列敌人造成221%伤害$destiny，我方随机2个头目的攻击提高20%，持续2回合",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511305206,
        [ "id" ] = 11302202,
        [ "name" ] = "飞扇连击",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 221,
        [ "spell_type" ] = 2,
    },
    [ 11302203 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000067,
        },
        [ "attack_type" ] = 3,
        [ "buff_object_list" ] = {
            [ 1 ] = 6,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "刚柔并济",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对一列敌人造成287%伤害$destiny，我方随机2个头目的攻击提高30%，持续2回合",
        [ "first_spell_hero" ] = 13022,
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511305207,
        [ "id" ] = 11302203,
        [ "name" ] = "刚柔并济",
        [ "second_spell_hero" ] = 13021,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 287,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 13022,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13021,
        },
    },
    [ 11302204 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000067,
        },
        [ "attack_type" ] = 3,
        [ "buff_object_list" ] = {
            [ 1 ] = 6,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "刚柔并济1",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对一列敌人造成287%伤害$destiny，我方随机2个头目的攻击提高30%，持续2回合",
        [ "first_spell_hero" ] = 13022,
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
        [ "hurt_grow_rate" ] = 3,
        [ "id" ] = 11302204,
        [ "name" ] = "刚柔并济1",
        [ "second_spell_hero" ] = 13021,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 287,
        [ "spell_type" ] = 4,
        [ "spell_unit" ] = 13022,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13021,
        },
        [ "super_spell_id" ] = 11302204,
    },
    [ 11303101 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 10,
        [ "ch_key" ] = "破裂",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对敌人及其相邻位置造成60%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11303101,
        [ "name" ] = "破裂",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 60,
        [ "spell_type" ] = 1,
    },
    [ 11303102 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000068,
        },
        [ "attack_type" ] = 4,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "飞弹轰击",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对敌人及其相邻位置造成140%伤害$destiny，造成灼烧效果（35%），持续2回合",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 51303102,
        [ "id" ] = 11303102,
        [ "name" ] = "飞弹轰击",
        [ "reduce_anger" ] = 1,
        [ "reduce_anger_level" ] = 1,
        [ "reduce_anger_ratio" ] = 0.5,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 140,
        [ "spell_type" ] = 2,
    },
    [ 11303103 ] = {
        [ "add_anger" ] = 1,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "破裂1",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对敌人及其相邻位置造成60%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11303103,
        [ "name" ] = "破裂1",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 60,
        [ "spell_type" ] = 1,
    },
    [ 11303104 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 1,
        [ "ch_key" ] = "飞弹轰击1",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对敌人及其相邻位置造成140%伤害$destiny，造成灼烧效果（35%），持续2回合",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 51303102,
        [ "id" ] = 11303104,
        [ "is_second_kill" ] = true,
        [ "name" ] = "飞弹轰击1",
        [ "reduce_anger" ] = 1,
        [ "reduce_anger_level" ] = 1,
        [ "reduce_anger_ratio" ] = 0.5,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 140,
        [ "spell_type" ] = 2,
    },
    [ 11304101 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "践踏",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.8,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.2,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11304101,
        [ "name" ] = "践踏",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11304102 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "attack_type" ] = 7,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.4,
        },
        [ "ch_key" ] = "断筋折骨",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对单个敌人造成300%伤害$destiny，40%概率造成眩晕",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511106104,
        [ "id" ] = 11304102,
        [ "name" ] = "断筋折骨",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 300,
        [ "spell_type" ] = 2,
    },
    [ 11304201 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 6,
        [ "ch_key" ] = "杀戒",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对后排单个敌人造成100%伤害",
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
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11304201,
        [ "name" ] = "杀戒",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11304202 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 5,
        [ "ch_key" ] = "怒目金刚",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对后排敌人造成152%伤害$destiny，40%概率减少2点怒气",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511305218,
        [ "id" ] = 11304202,
        [ "name" ] = "怒目金刚",
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.4,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 152,
        [ "spell_type" ] = 2,
    },
    [ 11304203 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 5,
        [ "ch_key" ] = "横冲直撞",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对后排敌人造成206%伤害$destiny，60%概率减少2点怒气",
        [ "first_spell_hero" ] = 13042,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511305209,
        [ "id" ] = 11304203,
        [ "name" ] = "横冲直撞",
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.6,
        [ "second_spell_hero" ] = 13061,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 206,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 13042,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13061,
        },
    },
    [ 11304204 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 5,
        [ "ch_key" ] = "横冲直撞1",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对后排敌人造成206%伤害$destiny，60%概率减少2点怒气",
        [ "first_spell_hero" ] = 13042,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 3,
        [ "id" ] = 11304204,
        [ "name" ] = "横冲直撞1",
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.6,
        [ "second_spell_hero" ] = 13061,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 206,
        [ "spell_type" ] = 4,
        [ "spell_unit" ] = 13042,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13061,
        },
        [ "super_spell_id" ] = 11304204,
    },
    [ 11304311 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 11,
        [ "ch_key" ] = "愈合",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "治疗生命最少的1个友军（102%+150）",
        [ "fixed_hurt" ] = 150,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11304311,
        [ "name" ] = "愈合",
        [ "side_type" ] = 2,
        [ "spell_hurt_pct" ] = 102,
        [ "spell_type" ] = 1,
    },
    [ 11304312 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000026,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 3,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "复苏药剂",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "治疗全体友军（116%+250）$destiny，每回合恢复生命（50%)，持续2回合",
        [ "fixed_hurt" ] = 250,
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
        [ "hurt_grow_rate" ] = 2,
        [ "icon" ] = 511106107,
        [ "id" ] = 11304312,
        [ "name" ] = "复苏药剂",
        [ "side_type" ] = 2,
        [ "spell_hurt_pct" ] = 116,
        [ "spell_type" ] = 2,
    },
    [ 11305101 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 6,
        [ "ch_key" ] = "割裂",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对后排单个敌人造成100%伤害",
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
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11305101,
        [ "name" ] = "割裂",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11305102 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 6,
        [ "ch_key" ] = "利刃冲击",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对后排单个敌人造成300%伤害$destiny，15%概率减少3点怒气",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511106115,
        [ "id" ] = 11305102,
        [ "name" ] = "利刃冲击",
        [ "reduce_anger" ] = 3,
        [ "reduce_anger_level" ] = 3,
        [ "reduce_anger_ratio" ] = 0.15,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 300,
        [ "spell_type" ] = 2,
    },
    [ 11305201 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "引爆",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11305201,
        [ "name" ] = "引爆",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11305202 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000007,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.5,
        },
        [ "ch_key" ] = "毒瓶投掷",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对全部敌人造成106%伤害$destiny，50%概率造成中毒效果（15%)，持续2回合",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511305202,
        [ "id" ] = 11305202,
        [ "name" ] = "毒瓶投掷",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 106,
        [ "spell_type" ] = 2,
    },
    [ 11305203 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000045,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "毁灭狂欢",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对全部敌人造成137%伤害$destiny，造成中毒效果（20%），持续2回合，本次攻击的命中率上升50%【与$unit共同出战可触发，由蜘蛛发动】",
        [ "first_spell_hero" ] = 13052,
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
        [ "hurt_grow_rate" ] = 4,
        [ "icon" ] = 511305211,
        [ "id" ] = 11305203,
        [ "name" ] = "毁灭狂欢",
        [ "second_spell_hero" ] = 13051,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 137,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 13052,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13051,
        },
    },
    [ 11305204 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000045,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "1",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对全部敌人造成137%伤害$destiny，造成中毒效果（20%），持续2回合，本次攻击的命中率上升50%【与$unit共同出战可触发，由蜘蛛发动】",
        [ "first_spell_hero" ] = 13052,
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
        [ "hurt_grow_rate" ] = 4,
        [ "id" ] = 11305204,
        [ "name" ] = "1",
        [ "second_spell_hero" ] = 13051,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 137,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 13052,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13051,
        },
        [ "super_spell_id" ] = 11305204,
    },
    [ 11305311 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 4,
        [ "ch_key" ] = "爆裂",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对前排敌人造成70%伤害，20%概率减少2点怒气",
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
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11305311,
        [ "name" ] = "爆裂",
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.2,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 70,
        [ "spell_type" ] = 1,
    },
    [ 11305312 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "attack_type" ] = 4,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.15,
        },
        [ "ch_key" ] = "地狱烈焰",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成165%伤害$destiny，50%概率减少2点怒气，15%概率造成眩晕",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511305312,
        [ "id" ] = 11305312,
        [ "name" ] = "地狱烈焰",
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.5,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 165,
        [ "spell_type" ] = 2,
    },
    [ 11305313 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "attack_type" ] = 4,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.25,
        },
        [ "ch_key" ] = "索命幽魂",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成214%伤害$destiny，80%概率减少2点怒气，25%概率造成眩晕【与$unit共同出战可触发，由收割者发动】",
        [ "first_spell_hero" ] = 13062,
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
        [ "hurt_grow_rate" ] = 4,
        [ "icon" ] = 511305224,
        [ "id" ] = 11305313,
        [ "name" ] = "索命幽魂",
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 0.8,
        [ "second_spell_hero" ] = 13041,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 214,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 13053,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13041,
        },
    },
    [ 11305314 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "attack_type" ] = 4,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.35,
        },
        [ "ch_key" ] = "超·索命幽魂",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成231%伤害$destiny，减少2点怒气，35%概率造成眩晕【与$unit共同出战可触发，由收割者发动】",
        [ "first_spell_hero" ] = 13062,
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
        [ "hurt_grow_rate" ] = 4,
        [ "icon" ] = 511305224,
        [ "id" ] = 11305314,
        [ "name" ] = "超·索命幽魂",
        [ "reduce_anger" ] = 2,
        [ "reduce_anger_level" ] = 2,
        [ "reduce_anger_ratio" ] = 1,
        [ "second_spell_hero" ] = 13041,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 231,
        [ "spell_type" ] = 4,
        [ "spell_unit" ] = 13053,
        [ "spell_unit_list" ] = {
            [ 1 ] = 13041,
        },
        [ "super_spell_id" ] = 11305314,
    },
    [ 11306101 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "碎颅",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11306101,
        [ "name" ] = "碎颅",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11306102 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000060,
        },
        [ "attack_type" ] = 4,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "恶徒进击",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成152%伤害$destiny，降低敌人攻击15%，持续2回合",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511305203,
        [ "id" ] = 11306102,
        [ "name" ] = "恶徒进击",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 152,
        [ "spell_type" ] = 2,
    },
    [ 11350011 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "汤姆普攻",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11350011,
        [ "name" ] = "汤姆普攻",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11350012 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 5,
        [ "ch_key" ] = "无情扫荡",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对后排敌人造成152%伤害$destiny，50%概率减少1点怒气",
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
        [ "hurt_grow_rate" ] = 0,
        [ "icon" ] = 511350012,
        [ "id" ] = 11350012,
        [ "name" ] = "无情扫荡",
        [ "reduce_anger" ] = 1,
        [ "reduce_anger_level" ] = 1,
        [ "reduce_anger_ratio" ] = 0.5,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 152,
        [ "spell_type" ] = 2,
    },
    [ 11350013 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 5,
        [ "ch_key" ] = "无情扫荡1",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对后排敌人造成152%伤害$destiny，50%概率减少1点怒气",
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
        [ "hurt_grow_rate" ] = 0,
        [ "icon" ] = 511350012,
        [ "id" ] = 11350013,
        [ "is_second_kill" ] = true,
        [ "name" ] = "无情扫荡1",
        [ "reduce_anger" ] = 1,
        [ "reduce_anger_level" ] = 1,
        [ "reduce_anger_ratio" ] = 0.5,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 152,
        [ "spell_type" ] = 2,
    },
    [ 11350014 ] = {
        [ "add_anger" ] = 1,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "汤姆普攻1",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11350014,
        [ "name" ] = "汤姆普攻1",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11350021 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "亚伯普攻",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11350021,
        [ "name" ] = "亚伯普攻",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11350022 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000020,
        },
        [ "attack_type" ] = 4,
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "喋血街头",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成139%伤害$destiny，自身的防御提高30%，持续2回合",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "icon" ] = 511350022,
        [ "id" ] = 11350022,
        [ "name" ] = "喋血街头",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 139,
        [ "spell_type" ] = 2,
    },
    [ 11350023 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000020,
        },
        [ "attack_type" ] = 4,
        [ "buff_object_list" ] = {
            [ 1 ] = 1,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "喋血街头1",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成139%伤害$destiny，自身的防御提高30%，持续2回合",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "icon" ] = 511350022,
        [ "id" ] = 11350023,
        [ "is_second_kill" ] = true,
        [ "name" ] = "喋血街头1",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 139,
        [ "spell_type" ] = 2,
    },
    [ 11350024 ] = {
        [ "add_anger" ] = 1,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "亚伯普攻1",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11350024,
        [ "name" ] = "亚伯普攻1",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11401101 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 5,
        [ "ch_key" ] = "WD-突袭",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对后排敌人造成60%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11401101,
        [ "name" ] = "WD-突袭",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 60,
        [ "spell_type" ] = 1,
    },
    [ 11401102 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000014,
        },
        [ "attack_type" ] = 5,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "WD-歼灭",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对后排敌人造成152%$destiny，敌人受到伤害+25%，持续2回合",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 51401102,
        [ "id" ] = 11401102,
        [ "name" ] = "WD-歼灭",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 152,
        [ "spell_type" ] = 2,
    },
    [ 11402101 ] = {
        [ "add_anger" ] = 2,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000050,
            [ 2 ] = 20000051,
        },
        [ "attack_type" ] = 3,
        [ "buff_object_list" ] = {
            [ 1 ] = 6,
            [ 2 ] = 6,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
        [ "ch_key" ] = "钩锁",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对一列敌人造成80%伤害，我方随机2个头目伤害加成与伤害减免提高10%，持续2回合",
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
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11402101,
        [ "name" ] = "钩锁",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 80,
        [ "spell_type" ] = 1,
    },
    [ 11402102 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000050,
            [ 2 ] = 20000051,
        },
        [ "attack_type" ] = 3,
        [ "buff_clear_level" ] = 1,
        [ "buff_clear_ratio" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 6,
            [ 2 ] = 6,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
        [ "ch_key" ] = "血腥咆哮",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对一列敌人造成240%伤害$destiny，清除（一级清除）对方所有增益状态，我方随机2个头目伤害加成与伤害减免提高10%，持续2回合",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511305227,
        [ "id" ] = 11402102,
        [ "name" ] = "血腥咆哮",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 240,
        [ "spell_type" ] = 2,
    },
    [ 11402103 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000050,
            [ 2 ] = 20000051,
        },
        [ "attack_type" ] = 3,
        [ "buff_clear_level" ] = 1,
        [ "buff_clear_ratio" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 3,
            [ 2 ] = 3,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
        [ "ch_key" ] = "屠戮盛宴",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对一列敌人造成312%伤害$destiny，清除（一级清除）对方所有增益状态，我方全体头目伤害加成与伤害减免提高10%，持续2回合【与$unit共同出战可触发，由链锯触发】",
        [ "first_spell_hero" ] = 14021,
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511305225,
        [ "id" ] = 11402103,
        [ "name" ] = "屠戮盛宴",
        [ "second_spell_hero" ] = 14042,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 312,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 14021,
        [ "spell_unit_list" ] = {
            [ 1 ] = 14042,
        },
    },
    [ 11402104 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000073,
            [ 2 ] = 20000074,
        },
        [ "attack_type" ] = 3,
        [ "buff_clear_level" ] = 1,
        [ "buff_clear_ratio" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 3,
            [ 2 ] = 3,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
        },
        [ "ch_key" ] = "超·屠戮盛宴",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对一列敌人造成336%伤害$destiny，清除（一级清除）对方所有增益状态，我方全体头目伤害加成与伤害减免提高15%，持续2回合【与$unit共同出战可触发，由链锯触发】",
        [ "first_spell_hero" ] = 14021,
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511305225,
        [ "id" ] = 11402104,
        [ "name" ] = "超·屠戮盛宴",
        [ "second_spell_hero" ] = 14042,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 336,
        [ "spell_type" ] = 4,
        [ "spell_unit" ] = 14021,
        [ "spell_unit_list" ] = {
            [ 1 ] = 14042,
        },
        [ "super_spell_id" ] = 11402104,
    },
    [ 11402201 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 5,
        [ "ch_key" ] = "弹雨",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对后排敌人造成70%伤害",
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
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11402201,
        [ "name" ] = "弹雨",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 70,
        [ "spell_type" ] = 1,
    },
    [ 11402202 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 5,
        [ "ch_key" ] = "狂热火力",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对后排敌人造成159%伤害$destiny，本次攻击的命中率和暴击率上升30%",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511106114,
        [ "id" ] = 11402202,
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
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.3,
            [ "hit" ] = 0.3,
        },
        [ "name" ] = "狂热火力",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 159,
        [ "spell_type" ] = 2,
    },
    [ 11402203 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 1,
        [ "ch_key" ] = "攻势如潮",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "全部敌人造成144%伤害$destiny，50%概率减少1点怒气，本次攻击的命中率和暴击率上升70%【与$unit共同出战可触发，由晨星发动】",
        [ "first_spell_hero" ] = 14012,
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
        [ "hurt_grow_rate" ] = 4,
        [ "icon" ] = 511106108,
        [ "id" ] = 11402203,
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
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.7,
            [ "hit" ] = 0.7,
        },
        [ "name" ] = "攻势如潮",
        [ "reduce_anger" ] = 1,
        [ "reduce_anger_level" ] = 1,
        [ "reduce_anger_ratio" ] = 0.5,
        [ "second_spell_hero" ] = 14032,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 144,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 14022,
        [ "spell_unit_list" ] = {
            [ 1 ] = 14032,
        },
    },
    [ 11403101 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 4,
        [ "ch_key" ] = "飞踢",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对前排敌人造成70%伤害",
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
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11403101,
        [ "name" ] = "飞踢",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 70,
        [ "spell_type" ] = 1,
    },
    [ 11403102 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000028,
        },
        [ "attack_type" ] = 4,
        [ "buff_object_list" ] = {
            [ 1 ] = 5,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "回旋猛踢",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成159%伤害，我方随机一名头目增加2点怒气",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511305212,
        [ "id" ] = 11403102,
        [ "name" ] = "回旋猛踢",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 159,
        [ "spell_type" ] = 2,
    },
    [ 11403103 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000028,
        },
        [ "attack_type" ] = 4,
        [ "buff_object_list" ] = {
            [ 1 ] = 6,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "战斗潮流",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成206%伤害$destiny，我方随机2个武将增加2点怒气【与$unit共同出战可触发，由韩朴仁触发】",
        [ "first_spell_hero" ] = 14031,
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
        [ "hurt_grow_rate" ] = 4,
        [ "icon" ] = 511305233,
        [ "id" ] = 11403103,
        [ "name" ] = "战斗潮流",
        [ "second_spell_hero" ] = 14011,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 206,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 14031,
        [ "spell_unit_list" ] = {
            [ 1 ] = 14011,
        },
    },
    [ 11403104 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000028,
        },
        [ "attack_type" ] = 4,
        [ "buff_object_list" ] = {
            [ 1 ] = 6,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "战斗潮流1",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成206%伤害$destiny，我方随机2个武将增加2点怒气【与$unit共同出战可触发，由韩朴仁触发】",
        [ "first_spell_hero" ] = 14031,
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
        [ "hurt_grow_rate" ] = 4,
        [ "id" ] = 11403104,
        [ "name" ] = "战斗潮流1",
        [ "second_spell_hero" ] = 14011,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 206,
        [ "spell_type" ] = 4,
        [ "spell_unit" ] = 14031,
        [ "spell_unit_list" ] = {
            [ 1 ] = 14011,
        },
        [ "super_spell_id" ] = 11403104,
    },
    [ 11403201 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 4,
        [ "ch_key" ] = "鞭挞",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对前排敌人造成70%伤害",
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
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11403201,
        [ "name" ] = "鞭挞",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 70,
        [ "spell_type" ] = 1,
    },
    [ 11403202 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000056,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "鞭刃乱舞",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对所有敌人造成111%伤害$destiny，本次攻击的暴击率上升40%，敌人受到的伤害提高10%，持续2回合",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511403202,
        [ "id" ] = 11403202,
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "crit",
                [ "attr_value" ] = 0.4,
            },
        },
        [ "modify_attr_dict" ] = {
            [ "crit" ] = 0.4,
        },
        [ "name" ] = "鞭刃乱舞",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 111,
        [ "spell_type" ] = 2,
    },
    [ 11404101 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "收割",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11404101,
        [ "name" ] = "收割",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11404102 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "attack_type" ] = 4,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.18,
        },
        [ "ch_key" ] = "利刃狂涛",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成152%伤害$destiny，18%概率造成眩晕",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511305216,
        [ "id" ] = 11404102,
        [ "name" ] = "利刃狂涛",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 152,
        [ "spell_type" ] = 2,
    },
    [ 11404103 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "attack_type" ] = 4,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.32,
        },
        [ "ch_key" ] = "恶徒怒火",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成192%伤害$destiny，32%概率造成眩晕【与$unit共同出战可触发，由比尔发动】",
        [ "first_spell_hero" ] = 14041,
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
        [ "hurt_grow_rate" ] = 4,
        [ "icon" ] = 511305205,
        [ "id" ] = 11404103,
        [ "name" ] = "恶徒怒火",
        [ "second_spell_hero" ] = 14062,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 192,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 14041,
        [ "spell_unit_list" ] = {
            [ 1 ] = 14062,
        },
    },
    [ 11404104 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "attack_type" ] = 4,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.32,
        },
        [ "ch_key" ] = "恶徒怒火1",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成192%伤害$destiny，32%概率造成眩晕【与$unit共同出战可触发，由比尔发动】",
        [ "first_spell_hero" ] = 14041,
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
        [ "hurt_grow_rate" ] = 4,
        [ "id" ] = 11404104,
        [ "name" ] = "恶徒怒火1",
        [ "second_spell_hero" ] = 14062,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 192,
        [ "spell_type" ] = 4,
        [ "spell_unit" ] = 14041,
        [ "spell_unit_list" ] = {
            [ 1 ] = 14062,
        },
        [ "super_spell_id" ] = 11404104,
    },
    [ 11404201 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 3,
        [ "ch_key" ] = "绞杀",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对一列敌人造成80%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11404201,
        [ "name" ] = "绞杀",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 80,
        [ "spell_type" ] = 1,
    },
    [ 11404202 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "attack_type" ] = 3,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.35,
        },
        [ "ch_key" ] = "血口獠牙",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对一列敌人造成232%伤害$destiny，35%概率造成眩晕",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 51404202,
        [ "id" ] = 11404202,
        [ "name" ] = "血口獠牙",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 232,
        [ "spell_type" ] = 2,
    },
    [ 11405201 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 11,
        [ "ch_key" ] = "治疗",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "治疗生命最少的1个友军（102%+150）",
        [ "fixed_hurt" ] = 150,
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11405201,
        [ "name" ] = "治疗",
        [ "side_type" ] = 2,
        [ "spell_hurt_pct" ] = 102,
        [ "spell_type" ] = 1,
    },
    [ 11405202 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 12,
        [ "ch_key" ] = "生化试剂",
        [ "cost_anger" ] = 4,
        [ "cure_param" ] = {
            [ 1 ] = 60,
            [ 2 ] = 50,
        },
        [ "desc" ] = "治疗全体友军（116%+250）$destiny，对生命低于60%的友军额外治疗（50%）",
        [ "fixed_hurt" ] = 250,
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
        [ "hurt_grow_rate" ] = 2,
        [ "icon" ] = 511305234,
        [ "id" ] = 11405202,
        [ "name" ] = "生化试剂",
        [ "side_type" ] = 2,
        [ "spell_hurt_pct" ] = 116,
        [ "spell_type" ] = 2,
    },
    [ 11406101 ] = {
        [ "add_anger" ] = 2,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000001,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "焚灭",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对所有敌人造成40%伤害，造成灼烧效果【40%】",
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
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11406101,
        [ "name" ] = "焚灭",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 40,
        [ "spell_type" ] = 1,
    },
    [ 11406102 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000015,
            [ 2 ] = 20000005,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
            [ 2 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 0.05,
        },
        [ "ch_key" ] = "炎浪侵袭",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对所有敌人造成115%伤害$destiny，造成灼烧效果【60%】，持续2回合，5%造成眩晕，本次攻击的命中率+30%",
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
        [ "hurt_grow_rate" ] = 4,
        [ "icon" ] = 51406102,
        [ "id" ] = 11406102,
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "hit",
                [ "attr_value" ] = 0.3,
            },
        },
        [ "modify_attr_dict" ] = {
            [ "hit" ] = 0.3,
        },
        [ "name" ] = "炎浪侵袭",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 115,
        [ "spell_type" ] = 2,
    },
    [ 11406103 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000047,
            [ 2 ] = 20000005,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
            [ 2 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 0.15,
        },
        [ "ch_key" ] = "焦热地狱",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对所有敌人造成149%伤害$destiny，造成灼烧效果【100%】，持续2回合，15%造成眩晕，本次攻击的命中率+30%【与$unit共同出战可触发，由赫里奥发动】",
        [ "first_spell_hero" ] = 14061,
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
        [ "hurt_grow_rate" ] = 4,
        [ "icon" ] = 511106120,
        [ "id" ] = 11406103,
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "hit",
                [ "attr_value" ] = 0.3,
            },
        },
        [ "modify_attr_dict" ] = {
            [ "hit" ] = 0.3,
        },
        [ "name" ] = "焦热地狱",
        [ "second_spell_hero" ] = 14052,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 149,
        [ "spell_type" ] = 3,
        [ "spell_unit" ] = 14061,
        [ "spell_unit_list" ] = {
            [ 1 ] = 14052,
        },
    },
    [ 11406104 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000072,
            [ 2 ] = 20000005,
        },
        [ "attack_type" ] = 1,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
            [ 2 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
            [ 2 ] = 0.2,
        },
        [ "ch_key" ] = "超·焦热地狱",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对所有敌人造成161%伤害$destiny，造成不可被清除（抵抗1级清除）的灼烧效果（120%），持续2回合，20%造成眩晕，本次攻击的命中率+30%【与$unit共同出战可触发，由赫里奥发动】",
        [ "first_spell_hero" ] = 14061,
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
        [ "hurt_grow_rate" ] = 4,
        [ "icon" ] = 511106120,
        [ "id" ] = 11406104,
        [ "modify_attr" ] = {
            [ 1 ] = {
                [ "attr_name" ] = "hit",
                [ "attr_value" ] = 0.3,
            },
        },
        [ "modify_attr_dict" ] = {
            [ "hit" ] = 0.3,
        },
        [ "name" ] = "超·焦热地狱",
        [ "second_spell_hero" ] = 14052,
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 161,
        [ "spell_type" ] = 4,
        [ "spell_unit" ] = 14061,
        [ "spell_unit_list" ] = {
            [ 1 ] = 14052,
        },
        [ "super_spell_id" ] = 11406104,
    },
    [ 11406201 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "撕裂",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11406201,
        [ "name" ] = "撕裂",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11406202 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000008,
        },
        [ "attack_type" ] = 4,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.5,
        },
        [ "ch_key" ] = "虐杀快感",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对前排敌人造成152%伤害$destiny，50%概率降低敌人防御60%，持续1回合",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511106119,
        [ "id" ] = 11406202,
        [ "name" ] = "虐杀快感",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 152,
        [ "spell_type" ] = 2,
    },
    [ 11500401 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "瑞克单射",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11500401,
        [ "name" ] = "瑞克单射",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11500402 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000017,
        },
        [ "attack_type" ] = 5,
        [ "buff_object_list" ] = {
            [ 1 ] = 3,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 1,
        },
        [ "ch_key" ] = "毁灭射击",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对后排敌人造成152%伤害$destiny，我方全体头目抗暴率提高40%，持续2回合",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "icon" ] = 51500402,
        [ "id" ] = 11500402,
        [ "name" ] = "毁灭射击",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 152,
        [ "spell_type" ] = 2,
    },
    [ 11500501 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 6,
        [ "ch_key" ] = "斧击",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "这是英雄技能7",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 11500501,
        [ "name" ] = "斧击",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 11500502 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "attack_type" ] = 3,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.16,
        },
        [ "ch_key" ] = "回旋斧",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "16%眩晕",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 0.5,
            },
            [ 2 ] = {
                [ "hurt_rate" ] = 0.5,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "icon" ] = 51500502,
        [ "id" ] = 11500502,
        [ "name" ] = "回旋斧",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 221,
        [ "spell_type" ] = 2,
    },
    [ 13500301 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "宫崎普攻",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 13500301,
        [ "name" ] = "宫崎普攻",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 13500302 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 5,
        [ "ch_key" ] = "棒球猛袭",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对后排敌人造成132%伤害$destiny",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 2,
        [ "icon" ] = 513500302,
        [ "id" ] = 13500302,
        [ "name" ] = "棒球猛袭",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 132,
        [ "spell_type" ] = 2,
    },
    [ 13500601 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 6,
        [ "ch_key" ] = "枪撞",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对后排单个敌人造成100%伤害",
        [ "hit_tb" ] = {
            [ 1 ] = {
                [ "hurt_rate" ] = 1,
            },
        },
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 13500601,
        [ "name" ] = "枪撞",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 13500602 ] = {
        [ "add_anger" ] = 0,
        [ "attack_type" ] = 5,
        [ "ch_key" ] = "逃徒奋杀",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对后排敌人造成132%伤害$destiny",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 513500602,
        [ "id" ] = 13500602,
        [ "name" ] = "逃徒奋杀",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 132,
        [ "spell_type" ] = 2,
    },
    [ 13500901 ] = {
        [ "add_anger" ] = 2,
        [ "attack_type" ] = 7,
        [ "ch_key" ] = "虎拳",
        [ "cost_anger" ] = 0,
        [ "desc" ] = "对单个敌人造成100%伤害",
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
        [ "hurt_grow_rate" ] = 0,
        [ "id" ] = 13500901,
        [ "name" ] = "虎拳",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 100,
        [ "spell_type" ] = 1,
    },
    [ 13500902 ] = {
        [ "add_anger" ] = 0,
        [ "add_buff_list" ] = {
            [ 1 ] = 20000005,
        },
        [ "attack_type" ] = 7,
        [ "buff_object_list" ] = {
            [ 1 ] = 2,
        },
        [ "buff_random_list" ] = {
            [ 1 ] = 0.4,
        },
        [ "ch_key" ] = "奔雷腿",
        [ "cost_anger" ] = 4,
        [ "desc" ] = "对单个敌人造成300%伤害$destiny，40%概率眩晕",
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
        [ "hurt_grow_rate" ] = 3,
        [ "icon" ] = 511305235,
        [ "id" ] = 13500902,
        [ "name" ] = "奔雷腿",
        [ "side_type" ] = 1,
        [ "spell_hurt_pct" ] = 300,
        [ "spell_type" ] = 2,
    },
}