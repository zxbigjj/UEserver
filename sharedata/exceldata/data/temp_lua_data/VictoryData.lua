return {
    [ [==[__element_names_scheme]==] ] = {
        [1] = [==[id]==],
        [2] = [==[ch_key]==],
        [3] = [==[remian_hp]==],
        [4] = [==[death_num]==],
        [5] = [==[round_num]==],
        [6] = [==[str_format]==],
    },
    [ [==[__table_field_list]==] ] = {
    },
    [ 1 ] = {
        remian_hp = {0.1,0.2,0.3,},
        str_format = [==[lang-剩余总血量不低于%s%%]==],
        id = 1,
        ch_key = [==[剩余总血量>10%]==],
    },
    [ 2 ] = {
        remian_hp = {0.5,0.7,0.9,},
        str_format = [==[lang-剩余总血量不低于%s%%]==],
        id = 2,
        ch_key = [==[剩余总血量>50%]==],
    },
    [ 3 ] = {
        remian_hp = {0.7,0.7,0.9,},
        str_format = [==[lang-剩余总血量不低于%s%%]==],
        id = 3,
        ch_key = [==[剩余总血量>70%]==],
    },
    [ 4 ] = {
        str_format = [==[lang-死亡人数不超过%s个]==],
        id = 4,
        death_num = {2,1,0,},
        ch_key = [==[死亡人数<3]==],
    },
    [ 5 ] = {
        str_format = [==[lang-死亡人数不超过%s个]==],
        id = 5,
        death_num = {1,1,0,},
        ch_key = [==[死亡人数<2]==],
    },
    [ 6 ] = {
        str_format = [==[lang-死亡人数不超过%s个]==],
        id = 6,
        death_num = {0,1,0,},
        ch_key = [==[死亡人数0]==],
    },
    [ 7 ] = {
        round_num = {15,13,10,},
        str_format = [==[lang-回合数不超过%s]==],
        id = 7,
        ch_key = [==[回合数不超过15]==],
    },
    [ 8 ] = {
        round_num = {6,4,2,},
        str_format = [==[lang-回合数不超过%s]==],
        id = 8,
        ch_key = [==[回合数<7]==],
    },
    [ 9 ] = {
        round_num = {5,13,10,},
        str_format = [==[lang-回合数不超过%s]==],
        id = 9,
        ch_key = [==[回合数<6]==],
    },
    [ 10 ] = {
        round_num = {4,13,10,},
        str_format = [==[lang-回合数不超过%s]==],
        id = 10,
        ch_key = [==[回合数<5]==],
    },
    [ 11 ] = {
        str_format = [==[lang-敌方全灭]==],
        id = 11,
        ch_key = [==[敌方全灭]==],
    },
    [ 12 ] = {
        str_format = [==[lang-顺利通关]==],
        id = 12,
        death_num = {5,1,0,},
        ch_key = [==[关卡通关普通条件]==],
    },
}
