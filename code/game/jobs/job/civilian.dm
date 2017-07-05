/datum/job/civilian
	title = "Prisoner"
	flag = CIVILIAN
	department_flag = SUPPORT
	total_positions = -1
	spawn_positions = -1
	supervisors = "Security"
	selection_color = "#dddddd"
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()
	alt_titles = list("Convict","Lifer")
	outfit = /datum/outfit/job/assistant

/datum/job/civilian/get_access()
	if(config.assistant_maint)
		return list(access_maint_tunnels)
	else
		return list()

/datum/outfit/job/assistant
	name = "Prisoner"
	jobtype = /datum/job/civilian

	uniform = /obj/item/clothing/under/color/random
	shoes = /obj/item/clothing/shoes/black


