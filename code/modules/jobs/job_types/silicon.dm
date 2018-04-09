/*
AI
*/
/datum/job/ai
	title = "AI"
	flag = AI_JF
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	selection_color = "#ccffcc"
	supervisors = "your laws"
	req_admin_notify = TRUE
	minimal_player_age = 30
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	antag_rep = 20
	var/do_special_check = TRUE

/datum/job/ai/equip(mob/living/carbon/human/H, visualsOnly, announce, latejoin)
	. = H.AIize(latejoin)

/datum/job/ai/after_spawn(mob/H, mob/M, latejoin)
	. = ..()
	if(latejoin)
		var/obj/structure/AIcore/latejoin_inactive/lateJoinCore
		for(var/obj/structure/AIcore/latejoin_inactive/P in GLOB.latejoin_ai_cores)
			if(P.is_available())
				lateJoinCore = P
				GLOB.latejoin_ai_cores -= P
				break
		if(lateJoinCore)
			lateJoinCore.available = FALSE
			H.forceMove(lateJoinCore.loc)
			qdel(lateJoinCore)
	var/mob/living/silicon/ai/AI = H
	AI.rename_self("ai", M.client)			//If this runtimes oh well jobcode is fucked.

	//we may have been created after our borg
	if(SSticker.current_state == GAME_STATE_SETTING_UP)
		for(var/mob/living/silicon/robot/R in GLOB.silicon_mobs)
			if(!R.connected_ai)
				R.TryConnectToAI()

	if(latejoin)
		announce(AI)

/datum/job/ai/override_latejoin_spawn()
	return TRUE

/datum/job/ai/special_check_latejoin(client/C)
	if(!do_special_check)
		return TRUE
	for(var/i in GLOB.latejoin_ai_cores)
		var/obj/structure/AIcore/latejoin_inactive/LAI = i
		if(istype(LAI))
			if(LAI.is_available())
				return TRUE
	return FALSE

/datum/job/ai/announce(mob/living/silicon/ai/AI)
	. = ..()
	var/area/A = get_area(AI)
	var/turf/T = get_turf(AI)
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, .proc/minor_announce, "[AI] has been downloaded to an empty bluespace-networked AI core at [COORD(T)], [A.name]."))

/datum/job/ai/config_check()
	return CONFIG_GET(flag/allow_ai)

/*
Cyborg
*/
/datum/job/cyborg
	title = "Cyborg"
	flag = CYBORG
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 1
	supervisors = "your laws and the AI"	//Nodrak
	selection_color = "#ddffdd"
	minimal_player_age = 21
	exp_requirements = 120
	exp_type = EXP_TYPE_CREW

/datum/job/cyborg/equip(mob/living/carbon/human/H)
	return H.Robotize(FALSE, FALSE)

/datum/job/cyborg/after_spawn(mob/living/silicon/robot/R, mob/M)
	if(CONFIG_GET(flag/rename_cyborg))	//name can't be set in robot/New without the client
		R.rename_self("cyborg", M.client)
