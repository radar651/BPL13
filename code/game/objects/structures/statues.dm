/obj/structure/statue
	name = "statue"
	desc = "Placeholder. Yell at Firecage if you SOMEHOW see this."
	icon = 'icons/obj/statue.dmi'
	icon_state = ""
	density = 1
	anchored = 0
	var/hardness = 1
	var/oreAmount = 5
	var/material_drop_type = /obj/item/stack/sheet/metal

/obj/structure/statue/attackby(obj/item/weapon/W, mob/living/user, params)
	add_fingerprint(user)
	user.changeNext_move(CLICK_CD_MELEE)
	if(iswrench(W))
		if(anchored)
			playsound(loc, W.usesound, 100, 1)
			user.visible_message("[user] is loosening the [name]'s bolts.", \
								 "<span class='notice'>You are loosening the [name]'s bolts...</span>")
			if(do_after(user, 40 * W.toolspeed, target = src))
				if(!loc || !anchored)
					return
				user.visible_message("[user] loosened the [name]'s bolts!", \
									 "<span class='notice'>You loosen the [name]'s bolts!</span>")
				anchored = 0
		else
			if(!isfloorturf(loc))
				user.visible_message("<span class='warning'>A floor must be present to secure the [name]!</span>")
				return
			playsound(loc, W.usesound, 100, 1)
			user.visible_message("[user] is securing the [name]'s bolts...", \
								 "<span class='notice'>You are securing the [name]'s bolts...</span>")
			if(do_after(user, 40 * W.toolspeed, target = src))
				if(!loc || anchored)
					return
				user.visible_message("[user] has secured the [name]'s bolts.", \
									 "<span class='notice'>You have secured the [name]'s bolts.</span>")
				anchored = 1

	else if(istype(W, /obj/item/weapon/gun/energy/plasmacutter))
		playsound(src, W.usesound, 100, 1)
		user.visible_message("[user] is slicing apart the [name]...", \
							 "<span class='notice'>You are slicing apart the [name]...</span>")
		if(do_after(user, 40 * W.toolspeed, target = src))
			if(!loc)
				return
			user.visible_message("[user] slices apart the [name].", \
								 "<span class='notice'>You slice apart the [name].</span>")
			Dismantle(TRUE)

	else if(istype(W, /obj/item/weapon/pickaxe/drill/jackhammer))
		var/obj/item/weapon/pickaxe/drill/jackhammer/D = W
		if(!loc)
			return
		user.visible_message("[user] destroys the [name]!", \
							 "<span class='notice'>You destroy the [name].</span>")
		D.playDigSound()
		qdel(src)

	else if(iswelder(W) && !anchored)
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			playsound(loc, W.usesound, 40, 1)
			user.visible_message("[user] is slicing apart the [name].", \
								 "<span class='notice'>You are slicing apart the [name]...</span>")
			if(do_after(user, 40 * W.toolspeed, target = src))
				if(!loc)
					return
				playsound(loc, W.usesound, 50, 1)
				user.visible_message("[user] slices apart the [name].", \
									 "<span class='notice'>You slice apart the [name]!</span>")
				Dismantle(TRUE)
	else
		hardness -= W.force/100
		..()
		CheckHardness()
		return ..()

/obj/structure/statue/attack_hand(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)
	user.visible_message("[user] rubs some dust off from the [name]'s surface.", \
						 "<span class='notice'>You rub some dust off from the [name]'s surface.</span>")

/obj/structure/statue/CanAtmosPass()
	return !density

/obj/structure/statue/bullet_act(obj/item/projectile/Proj)
	hardness -= Proj.damage
	..()
	CheckHardness()

/obj/structure/statue/proc/CheckHardness()
	if(hardness <= 0)
		Dismantle(TRUE)

/obj/structure/statue/proc/Dismantle(disassembled = TRUE)
	if(material_drop_type)
		var/drop_amt = oreAmount
		if(!disassembled)
			drop_amt -= 2
		if(drop_amt > 0)
			new material_drop_type(get_turf(src), drop_amt)
	qdel(src)

/obj/structure/statue/ex_act(severity = 1)
	switch(severity)
		if(1)
			Dismantle(TRUE)
		if(2)
			if(prob(20))
				Dismantle(TRUE)
			else
				hardness--
				CheckHardness()
		if(3)
			hardness -= 0.1
			CheckHardness()

/obj/structure/statue/uranium
	hardness = 3
	light_range = 2
	material_drop_type = /obj/item/stack/sheet/mineral/uranium
	var/last_event = 0
	var/active = null

/obj/structure/statue/uranium/nuke
	name = "statue of a nuclear fission explosive"
	desc = "This is a grand statue of a Nuclear Explosive. It has a sickening green colour."
	icon_state = "nuke"

/obj/structure/statue/uranium/eng
	name = "statue of an engineer"
	desc = "This statue has a sickening green colour."
	icon_state = "eng"

/obj/structure/statue/uranium/attackby(obj/item/weapon/W, mob/user, params)
	radiate()
	..()

/obj/structure/statue/uranium/Bumped(atom/user)
	radiate()
	..()

/obj/structure/statue/uranium/attack_hand(mob/user)
	radiate()
	..()

/obj/structure/statue/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			for(var/mob/living/L in range(3,src))
				L.apply_effect(12,IRRADIATE,0)
			last_event = world.time
			active = null

/obj/structure/statue/plasma
	hardness = 2
	material_drop_type = /obj/item/stack/sheet/mineral/plasma
	desc = "This statue is suitably made from plasma."

/obj/structure/statue/plasma/scientist
	name = "statue of a scientist"
	icon_state = "sci"

/obj/structure/statue/plasma/xeno
	name = "statue of a xenomorph"
	icon_state = "xeno"

/obj/structure/statue/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/structure/statue/plasma/bullet_act(obj/item/projectile/Proj)
	var/burn = FALSE
	if(istype(Proj,/obj/item/projectile/beam))
		PlasmaBurn(2500)
		burn = TRUE
	else if(istype(Proj,/obj/item/projectile/ion))
		PlasmaBurn(500)
		burn = TRUE
	if(burn)
		if(Proj.firer)
			message_admins("Plasma statue ignited by [key_name_admin(Proj.firer)](<A HREF='?_src_=holder;adminmoreinfo=\ref[Proj.firer]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[Proj.firer]'>FLW</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
			log_game("Plasma statue ignited by [key_name(Proj.firer)] in ([x],[y],[z])")
		else
			message_admins("Plasma statue ignited by [Proj]. No known firer.(<A HREF='?_src_=holder;adminmoreinfo=\ref[Proj.firer]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[Proj.firer]'>FLW</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
			log_game("Plasma statue ignited by [Proj] in ([x],[y],[z]). No known firer.")
	..()

/obj/structure/statue/plasma/attackby(obj/item/weapon/W, mob/user, params)
	if(is_hot(W) > 300)//If the temperature of the object is over 300, then ignite
		message_admins("Plasma statue ignited by [key_name_admin(user)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
		log_game("Plasma statue ignited by [key_name(user)] in ([x],[y],[z])")
		ignite(is_hot(W))
		return
	..()

/obj/structure/statue/plasma/proc/PlasmaBurn()
	atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 160)
	Dismantle(FALSE)

/obj/structure/statue/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn()

/obj/structure/statue/gold
	hardness = 3
	material_drop_type = /obj/item/stack/sheet/mineral/gold
	desc = "This is a highly valuable statue made from gold."

/obj/structure/statue/gold/hos
	name = "Statue of the Captain of the Guard"
	icon_state = "hos"

/obj/structure/statue/gold/hop
	name = "Statue of the Colony Resource Director"
	icon_state = "hop"

/obj/structure/statue/gold/cmo
	name = "Statue of the Chief Medical Officer"
	icon_state = "cmo"

/obj/structure/statue/gold/ce
	name = "Statue of the Chief Engineer"
	icon_state = "ce"

/obj/structure/statue/gold/rd
	name = "Statue of the Research Director"
	icon_state = "rd"

/obj/structure/statue/silver
	hardness = 3
	material_drop_type = /obj/item/stack/sheet/mineral/silver
	desc = "This is a valuable statue made from silver."

/obj/structure/statue/silver/md
	name = "statue of a medical doctor"
	icon_state = "md"

/obj/structure/statue/silver/janitor
	name = "statue of a janitor"
	icon_state = "jani"

/obj/structure/statue/silver/sec
	name = "statue of a security officer"
	icon_state = "sec"

/obj/structure/statue/silver/secborg
	name = "statue of a security cyborg"
	icon_state = "secborg"

/obj/structure/statue/silver/medborg
	name = "statue of a medical cyborg"
	icon_state = "medborg"

/obj/structure/statue/diamond
	hardness = 10
	material_drop_type = /obj/item/stack/sheet/mineral/diamond
	desc = "This is a very expensive diamond statue"

/obj/structure/statue/diamond/captain
	name = "statue of THE Overseer."
	icon_state = "cap"

/obj/structure/statue/diamond/ai1
	name = "statue of the AI hologram."
	icon_state = "ai1"

/obj/structure/statue/diamond/ai2
	name = "statue of the AI core."
	icon_state = "ai2"

/obj/structure/statue/bananium
	hardness = 3
	material_drop_type = /obj/item/stack/sheet/mineral/bananium
	desc = "A bananium statue with a small engraving:'HOOOOOOONK'."
	var/spam_flag = 0

/obj/structure/statue/bananium/clown
	name = "statue of a clown"
	icon_state = "clown"

/obj/structure/statue/bananium/Bumped(atom/user)
	honk()
	..()

/obj/structure/statue/bananium/attackby(obj/item/weapon/W, mob/user, params)
	honk()
	..()

/obj/structure/statue/bananium/attack_hand(mob/user)
	honk()
	..()

/obj/structure/statue/bananium/proc/honk()
	if(!spam_flag)
		spam_flag = 1
		playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)
		spawn(20)
			spam_flag = 0

/obj/structure/statue/sandstone
	hardness = 0.5
	material_drop_type = /obj/item/stack/sheet/mineral/sandstone

/obj/structure/statue/sandstone/assistant
	name = "statue of an assistant"
	desc = "A cheap statue of sandstone for a greyshirt."
	icon_state = "assist"

/obj/structure/statue/sandstone/venus //call me when we add marble i guess
	name = "statue of a pure maiden"
	desc = "An ancient marble statue. The subject is depicted with a floor-length braid and is wielding a toolbox. By Jove, it's easily the most gorgeous depiction of a woman you've ever seen. The artist must truly be a master of his craft. Shame about the broken arm, though."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "venus"

/*
/obj/structure/statue/snow
	hardness = 0.5
	material_drop_type = /obj/item/stack/sheet/mineral/snow

/obj/structure/statue/snow/snowman
	name = "snowman"
	desc = "Several lumps of snow put together to form a snowman."
	icon_state = "snowman"
*/

/obj/structure/statue/tranquillite
	hardness = 0.5
	material_drop_type = /obj/item/stack/sheet/mineral/tranquillite
	desc = "..."

/obj/structure/statue/tranquillite/mime
	name = "statue of a mime"
	icon_state = "mime"

/obj/structure/statue/tranquillite/mime/AltClick(mob/user)//has 4 dirs
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!Adjacent(user))
		return
	if(anchored)
		to_chat(user, "It is fastened to the floor!")
		return
	setDir(turn(dir, 90))
////////////////////////////////
/obj/structure/snowman
	name = "snowman"
	desc = "Seems someone made a snowman here."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "snowman"
	anchored = 1
	density = 1

/obj/structure/kidanstatue
	name = "Obsidian Kidan warrior statue"
	desc = "A beautifully carved and menacing statue of a Kidan warrior made out of obsidian. It looks very heavy."
	icon = 'icons/obj/decorations.dmi'
	icon_state = "kidanstatue"
	anchored = 1
	density = 1

/obj/structure/chickenstatue
	name = "Bronze Chickenman Statue"
	desc = "An antique and oriental-looking statue of a Chickenman made of bronze."
	icon = 'icons/obj/decorations.dmi'
	icon_state = "chickenstatue"
	anchored = 1
	density = 1
