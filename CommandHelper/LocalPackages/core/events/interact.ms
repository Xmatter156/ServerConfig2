bind('player_interact', null, array('item': 0, 'button': 'left'), @event,

    @player = player()

    if(import(@player.'webSlingStatus') != true){
        die()
    }
    
    if(has_permission(@player,'ch.alias.websling')){

        assign(@cooldown, 1)
        assign(@lastshot, import(@player.'lastwebshot'))
        if(@lastshot + @cooldown > time() / 1000,
            die()
        )
        export(@player.'lastwebshot', time() / 1000)
        @puuid = puuid(@player, true)
        set_entity_rider(null, @puuid)
        @multiplier = 0.5
        @arrow = shoot_projectile(@player, 'ARROW')
        @velocity = entity_velocity(@arrow)
        
        # spawn pig
        @ploc = ploc(@player)
        @ploc['y']  = @ploc['y'] + 1
        @pig = spawn_entity("CHICKEN", 1, @ploc)[0]
        
        try(set_mob_effect(@pig, 14, 1, 9999, true, false),
            tmsg(player(), "Sorry, you can't use websling in here")
            entity_remove(@arrow)
            entity_remove(@pig)
            die()
        )
        
        # set pig invisible
        set_mob_effect(@pig, 11, 254, 9999, true, false)
        
        # sit player on pig
        set_entity_rider(@pig, @puuid)
        set_leashholder(@pig,@arrow)
        
        set_entity_velocity(@arrow, array(@velocity['x'] * @multiplier, @velocity['y'] * @multiplier, @velocity['z'] * @multiplier))
        @puuidd = puuid(@player)
        bind('entity_dismount', null, null, @event, @puuidd, @arrow) {
            if(@event['id'] == @puuidd){
                entity_remove(@event['mountid'])
                try{entity_remove(@arrow)}catch(Exception @e){}
                unbind()
            }
        }

        set_timeout(5000,closure(
            try{entity_remove(@arrow)}catch(Exception @e){}
            try{entity_remove(@pig)}catch(Exception @e){}
        ))
    }

)
