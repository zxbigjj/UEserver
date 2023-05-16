return {
    [ 1 ] = {
        [ "id" ] = 1,
        [ "ch_key" ] = "剩余总血量>10%",
        [ "remian_hp" ] = {
            [ 1 ] = 0.1,
            [ 2 ] = 0.2,
            [ 3 ] = 0.3,
        },
        [ "str_format" ] = langexcel["剩余总血量不低于%s%%"],
        [ "str_list" ] = {
            [ 1 ] = langexcel["剩余总血量不低于10.0%"],
            [ 2 ] = langexcel["剩余总血量不低于20.0%"],
            [ 3 ] = langexcel["剩余总血量不低于30.0%"],
        },
    },
    [ 2 ] = {
        [ "id" ] = 2,
        [ "ch_key" ] = "剩余总血量>50%",
        [ "remian_hp" ] = {
            [ 1 ] = 0.5,
            [ 2 ] = 0.7,
            [ 3 ] = 0.9,
        },
        [ "str_format" ] = langexcel["剩余总血量不低于%s%%"],
        [ "str_list" ] = {
            [ 1 ] = langexcel["剩余总血量不低于50.0%"],
            [ 2 ] = langexcel["剩余总血量不低于70.0%"],
            [ 3 ] = langexcel["剩余总血量不低于90.0%"],
        },
    },
    [ 3 ] = {
        [ "id" ] = 3,
        [ "ch_key" ] = "剩余总血量>70%",
        [ "remian_hp" ] = {
            [ 1 ] = 0.7,
            [ 2 ] = 0.7,
            [ 3 ] = 0.9,
        },
        [ "str_format" ] = langexcel["剩余总血量不低于%s%%"],
        [ "str_list" ] = {
            [ 1 ] = langexcel["剩余总血量不低于70.0%"],
            [ 2 ] = langexcel["剩余总血量不低于70.0%"],
            [ 3 ] = langexcel["剩余总血量不低于90.0%"],
        },
    },
    [ 4 ] = {
        [ "id" ] = 4,
        [ "ch_key" ] = "死亡人数<3",
        [ "death_num" ] = {
            [ 1 ] = 2,
            [ 2 ] = 1,
            [ 3 ] = 0,
        },
        [ "str_format" ] = langexcel["死亡人数不超过%s个"],
        [ "str_list" ] = {
            [ 1 ] = langexcel["死亡人数不超过2个"],
            [ 2 ] = langexcel["死亡人数不超过1个"],
            [ 3 ] = langexcel["死亡人数不超过0个"],
        },
    },
    [ 5 ] = {
        [ "id" ] = 5,
        [ "ch_key" ] = "死亡人数<2",
        [ "death_num" ] = {
            [ 1 ] = 1,
            [ 2 ] = 1,
            [ 3 ] = 0,
        },
        [ "str_format" ] = langexcel["死亡人数不超过%s个"],
        [ "str_list" ] = {
            [ 1 ] = langexcel["死亡人数不超过1个"],
            [ 2 ] = langexcel["死亡人数不超过1个"],
            [ 3 ] = langexcel["死亡人数不超过0个"],
        },
    },
    [ 6 ] = {
        [ "id" ] = 6,
        [ "ch_key" ] = "死亡人数0",
        [ "death_num" ] = {
            [ 1 ] = 0,
            [ 2 ] = 1,
            [ 3 ] = 0,
        },
        [ "str_format" ] = langexcel["死亡人数不超过%s个"],
        [ "str_list" ] = {
            [ 1 ] = langexcel["死亡人数不超过0个"],
            [ 2 ] = langexcel["死亡人数不超过1个"],
            [ 3 ] = langexcel["死亡人数不超过0个"],
        },
    },
    [ 7 ] = {
        [ "id" ] = 7,
        [ "ch_key" ] = "回合数不超过15",
        [ "round_num" ] = {
            [ 1 ] = 15,
            [ 2 ] = 13,
            [ 3 ] = 10,
        },
        [ "str_format" ] = langexcel["回合数不超过%s"],
        [ "str_list" ] = {
            [ 1 ] = langexcel["回合数不超过15"],
            [ 2 ] = langexcel["回合数不超过13"],
            [ 3 ] = langexcel["回合数不超过10"],
        },
    },
    [ 8 ] = {
        [ "id" ] = 8,
        [ "ch_key" ] = "回合数<7",
        [ "round_num" ] = {
            [ 1 ] = 6,
            [ 2 ] = 4,
            [ 3 ] = 2,
        },
        [ "str_format" ] = langexcel["回合数不超过%s"],
        [ "str_list" ] = {
            [ 1 ] = langexcel["回合数不超过6"],
            [ 2 ] = langexcel["回合数不超过4"],
            [ 3 ] = langexcel["回合数不超过2"],
        },
    },
    [ 9 ] = {
        [ "id" ] = 9,
        [ "ch_key" ] = "回合数<6",
        [ "round_num" ] = {
            [ 1 ] = 5,
            [ 2 ] = 13,
            [ 3 ] = 10,
        },
        [ "str_format" ] = langexcel["回合数不超过%s"],
        [ "str_list" ] = {
            [ 1 ] = langexcel["回合数不超过5"],
            [ 2 ] = langexcel["回合数不超过13"],
            [ 3 ] = langexcel["回合数不超过10"],
        },
    },
    [ 10 ] = {
        [ "id" ] = 10,
        [ "ch_key" ] = "回合数<5",
        [ "round_num" ] = {
            [ 1 ] = 4,
            [ 2 ] = 13,
            [ 3 ] = 10,
        },
        [ "str_format" ] = langexcel["回合数不超过%s"],
        [ "str_list" ] = {
            [ 1 ] = langexcel["回合数不超过4"],
            [ 2 ] = langexcel["回合数不超过13"],
            [ 3 ] = langexcel["回合数不超过10"],
        },
    },
    [ 11 ] = {
        [ "id" ] = 11,
        [ "ch_key" ] = "敌方全灭",
        [ "str_format" ] = langexcel["敌方全灭"],
        [ "str_list" ] = {
            [ 1 ] = langexcel["敌方全灭"],
            [ 2 ] = langexcel["敌方全灭"],
            [ 3 ] = langexcel["敌方全灭"],
        },
    },
    [ 12 ] = {
        [ "id" ] = 12,
        [ "ch_key" ] = "关卡通关普通条件",
        [ "death_num" ] = {
            [ 1 ] = 5,
            [ 2 ] = 1,
            [ 3 ] = 0,
        },
        [ "str_format" ] = langexcel["顺利通关"],
        [ "str_list" ] = {
            [ 1 ] = langexcel["顺利通关"],
            [ 2 ] = langexcel["顺利通关"],
            [ 3 ] = langexcel["顺利通关"],
        },
    },
}