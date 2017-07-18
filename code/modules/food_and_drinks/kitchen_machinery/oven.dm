var/global/recursiveFood = 0
var/list/foodChoices = list()


/obj/machinery/cooking/proc/validateIngredient(var/obj/item/I, var/force_cook)
	if(istype(I,/obj/item/weapon/grab) || istype(I,/obj/item/tk_grab))
		. = "It won't fit."
	else if(istype(I,/obj/item/weapon/disk/nuclear))
		. = "It's the fucking nuke disk!"
	else if(!recursive_ingredients && !recursiveFood && istype(I, /obj/item/weapon/reagent_containers/food/snacks/customizable))
		. = "It would be a straining topological exercise."
	else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks) || istype(I,/obj/item/weapon/holder) || force_cook)
		. = "valid"
	else if(istype(I,/obj/item/weapon/reagent_containers))
		. = "transto"
	else if(istype(I,/obj/item/organ))
		var/obj/item/organ/organ = I
		if(organ.robotic)
			. = "That's a prosthetic. It wouldn't taste very good."
		else
			. = "valid"
	else
		. = "It's not edible food."
	return

/obj/machinery/cooking/proc/getFoodChoices()

	return (typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable/cook)-(/obj/item/weapon/reagent_containers/food/snacks/customizable/cook))

/obj/machinery/cooking/initialize()
	if (foodChoices)
		var/obj/item/food

		for (var/path in getFoodChoices())
			food = path

			foodChoices.Add(list(initial(food.name) = path))




/obj/machinery/cooking
	name = "oven"
	desc = "Cookies are ready, dear."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "oven_off"
	var/recursive_ingredients = 0
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	var/candy = 0
	idle_power_usage = 5
	var/on = FALSE	//Is it making food already?
	var/list/food_choices = list()
/obj/machinery/cooking/New()
	..()
	updatefood()

/obj/machinery/cooking/attackby(obj/item/I, mob/user, params)
	if(on)
		to_chat(user, "The machine is already running.")
		return
	else
		var/obj/item/F = I
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/C
		C = input("Select food to make.", "Cooking", C) in food_choices
		if(!C)
			return
		else
			to_chat(user, "You put [F] into [src] for cooking.")
			user.drop_item()
			F.loc = src
			on = TRUE
			if(!candy)
				icon_state = "oven_on"
			else
				icon_state = "mixer_on"
			sleep(100)
			on = FALSE
			if(!candy)
				icon_state = "oven_off"
			else
				icon_state = "mixer_off"
			C.loc = get_turf(src)
			C.attackby(F,user, params)
			playsound(loc, 'sound/machines/ding.ogg', 50, 1)
			updatefood()
			return

/obj/machinery/cooking/proc/updatefood()
	return

/obj/machinery/cooking/oven
	name = "oven"
	desc = "Cookies are ready, dear."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "oven_off"

/obj/machinery/cooking/oven/updatefood()
	for(var/U in food_choices)
		food_choices.Remove(U)
	for(var/U in subtypesof(/obj/item/weapon/reagent_containers/food/snacks/customizable/cook))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/V = new U
		food_choices += V
	return

/obj/machinery/cooking/candy
	name = "candy machine"
	desc = "Get yer box of deep fried deep fried deep fried deep fried cotton candy cereal sandwich cookies here!"
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "mixer_off"
	candy = 1

/obj/machinery/cooking/candy/updatefood()
	for(var/U in food_choices)
		food_choices.Remove(U)
	for(var/U in subtypesof(/obj/item/weapon/reagent_containers/food/snacks/customizable/candy))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/V = new U
		food_choices += V
	return


/obj/machinery/cooking/still
	name = "still"
	desc = "Alright, so, t'make some moonshine, fust yo' gotta combine some of this hyar egg wif th' deep fried sausage."
	icon_state = "still_off"
	var/icon_state_on = "still_on"
	var/cookSound = 'sound/machines/juicer.ogg'

/obj/machinery/cooking/still/validateIngredient(var/obj/item/I)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/grown))
		. = "valid"
	else
		. = "It ain't grown food!"
	return

/obj/machinery/cooking/still/getFoodChoices()
	return (typesof(/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable)-(/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable))
