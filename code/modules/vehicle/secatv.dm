
/obj/vehicle/secatv
	name = "Ranger ATV"
	desc = "A Repainted ATV used for Secuirty Rangers. Other then being a repaint, they are nothing speical."
	icon = 'icons/vehicles/4wheelersec.dmi'
	icon_state = "fourwheelsec"
	keytype = /obj/item/key/security/sec2
	generic_pixel_x = 0
	generic_pixel_y = 4
	vehicle_move_delay = 1
	var/static/image/atvcover = null



/obj/vehicle/secatv/New()
	..()
	if(!atvcover)
		atvcover = image("icons/vehicles/4wheelersec.dmi", "4wheeler_northsec")
		atvcover.layer = MOB_LAYER + 0.1

/obj/vehicle/secatv/post_buckle_mob(mob/living/M)
	if(buckled_mob)
		overlays += atvcover
	else
		overlays -= atvcover

/obj/vehicle/secatv/handle_vehicle_layer()
	if(dir == SOUTH)
		layer = MOB_LAYER+0.1
	else
		layer = OBJ_LAYER




/obj/vehicle/secatv/comatv
	name = "Command ATV"
	desc = "A Repainted ATV used for the command team. Other then being a repaint, they are nothing speical."
	icon = 'icons/vehicles/4wheelercom.dmi'
	icon_state = "fourwheelcom"
	keytype = /obj/item/key/security/com
	generic_pixel_x = 0
	generic_pixel_y = 4
	vehicle_move_delay = 1
	var/static/image/atvcover2 = null



/obj/vehicle/secatv/comatv/New()
	..()
	if(!atvcover2)
		atvcover2 = image("icons/vehicles/4wheelercom.dmi", "4wheeler_northcom")
		atvcover2.layer = MOB_LAYER + 0.1

/obj/vehicle/secatv/comatv/post_buckle_mob(mob/living/M)
	if(buckled_mob)
		overlays += atvcover2
	else
		overlays -= atvcover2

/obj/vehicle/secatv/comatv/handle_vehicle_layer()
	if(dir == SOUTH)
		layer = MOB_LAYER+0.1
	else
		layer = OBJ_LAYER