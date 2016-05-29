//the core [tokamaka generator] big funky solenoid, it generates an EM field

/*
when the core is turned on, it generates [creates] an electromagnetic field
the em field attracts phoron, and suspends it in a controlled torus (doughnut) shape, oscillating around the core

the field strength is directly controllable by the user
field strength = sqrt(energy used by the field generator)

the size of the EM field = field strength / k
(k is an arbitrary constant to make the calculated size into tilewidths)

1 tilewidth = below 5T
3 tilewidth = between 5T and 12T
5 tilewidth = between 10T and 25T
7 tilewidth = between 20T and 50T
(can't go higher than 40T)

energy is added by a gyrotron, and lost when phoron escapes
energy transferred from the gyrotron beams is reduced by how different the frequencies are (closer frequencies = more energy transferred)

frequency = field strength * (stored energy / stored moles of phoron) * x
(where x is an arbitrary constant to make the frequency something realistic)
the gyrotron beams' frequency and energy are hardcapped low enough that they won't heat the phoron much

energy is generated in considerable amounts by fusion reactions from injected particles
fusion reactions only occur when the existing energy is above a certain level, and it's near the max operating level of the gyrotron. higher energy reactions only occur at higher energy levels
a small amount of energy constantly bleeds off in the form of radiation

the field is constantly pulling in phoron from the surrounding [local] atmosphere
at random intervals, the field releases a random percentage of stored phoron in addition to a percentage of energy as intense radiation

the amount of phoron is a percentage of the field strength, increased by frequency
*/

/*
- VALUES -

max volume of phoron storeable by the field = the total volume of a number of tiles equal to the (field tilewidth)^2

*/

#define MAX_FIELD_FREQ 1000
#define MIN_FIELD_FREQ 1
#define MAX_FIELD_STR 1000
#define MIN_FIELD_STR 1

/obj/machinery/power/rust_core
	name = "RUST Tokamak core"
	desc = "Enormous solenoid for generating extremely high power electromagnetic fields"
	icon = 'icons/rust.dmi'
	icon_state = "core0"
	density = 1
	anchored = 0
	req_access = list(access_engine)
	use_power = 1
	idle_power_usage = 50
	active_power_usage = 500	//multiplied by field strength
	circuit = /obj/item/weapon/circuitboard/rust_core

	var/id_tag = "Mapper Forgot To Set Me"
	var/obj/effect/rust_em_field/owned_field
	var/locked = 0
	var/field_strength = 1
	var/cached_power_avail = 0
	var/remote_access_enabled = 1
	var/state = STATE_LOOSE

/obj/machinery/power/rust_core/New()
	..()
	circuit = new circuit(src)
	component_parts = list()
	component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(src)
	component_parts += new /obj/item/stack/cable_coil(src, 30)
	RefreshParts()
	update_icon()

/obj/machinery/power/rust_core/initialize()
	..()
	if(state == STATE_WELDED && anchored)
		connect_to_network()

/obj/machinery/power/rust_core/process()
	if(stat & BROKEN || !powernet)
		Shutdown()
	cached_power_avail = avail()

/obj/machinery/power/rust_core/attackby(obj/item/W, mob/user)
	// Do default machine stuff only if we aren't generating a field.
	if(!owned_field)
		if(default_deconstruction_screwdriver(user, W))
			return
		if(default_deconstruction_crowbar(user, W))
			return
		if(default_part_replacement(user, W))
			return

	// TODO - Copied code from emitter to get good quality, but replaced state's with constants.
	// Should go back to emitter.dm and upgrade it to use constants too!

	if(istype(W, /obj/item/weapon/wrench))
		if(owned_field)
			user << "Turn off [src] first."
			return
		switch(state)
			if(STATE_LOOSE)
				state = STATE_BOLTED
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				user.visible_message("[user.name] secures [src] to the floor.", \
					"You secure the external reinforcing bolts to the floor.", \
					"You hear a ratchet")
				src.anchored = 1
			if(STATE_BOLTED)
				state = STATE_LOOSE
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				user.visible_message("[user.name] unsecures [src] reinforcing bolts from the floor.", \
					"You undo the external reinforcing bolts.", \
					"You hear a ratchet")
				src.anchored = 0
			if(STATE_WELDED)
				user << "<span class='warning'>\The [src] needs to be unwelded from the floor.</span>"
		return

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(owned_field)
			user << "Turn off [src] first."
			return
		switch(state)
			if(STATE_LOOSE)
				user << "<span class='warning'>\The [src] needs to be wrenched to the floor.</span>"
			if(STATE_BOLTED)
				if (WT.remove_fuel(0,user))
					playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
					user.visible_message("[user.name] starts to weld [src] to the floor.", \
						"You start to weld [src] to the floor.", \
						"You hear welding")
					if (do_after(user,20))
						if(!src || !WT.isOn()) return
						state = STATE_WELDED
						user << "You weld [src] to the floor."
						connect_to_network()
				else
					user << "<span class='warning'>You need more welding fuel to complete this task.</span>"
			if(STATE_WELDED)
				if (WT.remove_fuel(0,user))
					playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
					user.visible_message("[user.name] starts to cut [src] free from the floor.", \
						"You start to cut [src] free from the floor.", \
						"You hear welding")
					if (do_after(user,20))
						if(!src || !WT.isOn()) return
						state = STATE_BOLTED
						user << "You cut [src] free from the floor."
						disconnect_from_network()
				else
					user << "<span class='warning'>You need more welding fuel to complete this task.</span>"
		return

	/*
	// No need to lock/unlock, nothing to control here anyway!
	if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		if(emagged)
			user << "<span class='warning'>The lock seems to be broken.</span>"
			return
		if(src.allowed(user))
			if(owned_field)
				src.locked = !src.locked
				user << "The controls are now [src.locked ? "locked." : "unlocked."]"
			else
				src.locked = 0 //just in case it somehow gets locked
				user << "<span class='warning'>The controls can only be locked when [src] is online.</span>"
		else
			user << "<span class='warning'>Access denied.</span>"
		return
	*/

	..()
	return


/obj/machinery/power/rust_core/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/power/rust_core/attack_hand(mob/user)
	add_fingerprint(user)
	interact(user)

/obj/machinery/power/rust_core/interact(mob/user)
	if(stat & BROKEN)
		user.unset_machine()
		user << browse(null, "window=rust_core")
		return
	if(!istype(user, /mob/living/silicon) && get_dist(src, user) > 1)
		user.unset_machine()
		user << browse(null, "window=rust_core")
		return

	var/dat = ""
	if(stat & NOPOWER || locked || state != STATE_WELDED)
		dat += "<i>The console is dark and nonresponsive.</i>"
	else
		dat += "<b>RUST Tokamak pattern Electromagnetic Field Generator</b><br>"
		dat += "<b>Device ID tag: </b> [id_tag ? id_tag : "UNSET"] <a href='?src=\ref[src];new_id_tag=1'>\[Modify\]</a><br>"
		dat += "<a href='?src=\ref[src];toggle_active=1'>\[[owned_field ? "Deactivate" : "Activate"]\]</a><br>"
		dat += "<a href='?src=\ref[src];toggle_remote=1'>\[[remote_access_enabled ? "Disable remote access to this device" : "Enable remote access to this device"]\]</a><br>"
		dat += "<hr>"
		dat += "<b>Field strength:</b> [field_strength]Wm^3<br>"
		dat += "<a href='?src=\ref[src];str=-1000'>\[----\]</a> \
		<a href='?src=\ref[src];str=-100'>\[--- \]</a> \
		<a href='?src=\ref[src];str=-10'>\[--  \]</a> \
		<a href='?src=\ref[src];str=-1'>\[-   \]</a> \
		<a href='?src=\ref[src];str=1'>\[+   \]</a> \
		<a href='?src=\ref[src];str=10'>\[++  \]</a> \
		<a href='?src=\ref[src];str=100'>\[+++ \]</a> \
		<a href='?src=\ref[src];str=1000'>\[++++\]</a><br>"

		var/font_colour = "green"
		if(cached_power_avail < active_power_usage)
			font_colour = "red"
		else if(cached_power_avail < active_power_usage * 2)
			font_colour = "orange"
		dat += "<b>Power status:</b> <font color=[font_colour]>[active_power_usage]/[cached_power_avail] W</font><br>"

	user << browse(dat, "window=rust_core;size=500x300")
	onclose(user, "rust_core")
	user.set_machine(src)

/obj/machinery/power/rust_core/Topic(href, href_list)
	if(href_list["str"])
		var/dif = text2num(href_list["str"])
		field_strength = min(max(field_strength + dif, MIN_FIELD_STR), MAX_FIELD_STR)
		active_power_usage = 5 * field_strength	//change to 500 later
		if(owned_field)
			owned_field.ChangeFieldStrength(field_strength)

	if(href_list["toggle_active"])
		if(!Startup())
			Shutdown()

	if( href_list["toggle_remote"] )
		remote_access_enabled = !remote_access_enabled

	if(href_list["new_id_tag"])
		if(usr)
			id_tag = input("Enter a new ID tag", "Tokamak core ID tag", id_tag) as text|null

	if(href_list["close"])
		usr << browse(null, "window=core_gen")
		usr.unset_machine()

	if(href_list["extern_update"])
		var/obj/machinery/computer/rust_core_control/C = locate(href_list["extern_update"])
		if(C)
			C.updateDialog()

	src.updateDialog()

/obj/machinery/power/rust_core/proc/Startup()
	if(owned_field)
		return
	owned_field = new(src.loc)
	owned_field.ChangeFieldStrength(field_strength)
	luminosity = 1
	use_power = 2
	update_icon()
	return 1

/obj/machinery/power/rust_core/proc/Shutdown()
	// TODO : safety checks for field status
	if(owned_field)
		qdel(owned_field)
		luminosity = 0
		use_power = 1
		update_icon()

/obj/machinery/power/rust_core/update_icon()
	if(owned_field)
		icon_state = "core1"
	else
		icon_state = "core0"

/obj/machinery/power/rust_core/proc/AddParticles(var/name, var/quantity = 1)
	if(owned_field)
		owned_field.AddParticles(name, quantity)
		return 1
	return 0

/obj/machinery/power/rust_core/bullet_act(var/obj/item/projectile/Proj)
	// Forward incoming projectiles to the field if active.
	if(owned_field)
		return owned_field.bullet_act(Proj)
	return ..()

/*
	TODO - Think of something cool that that emagging should do.
/obj/machinery/power/emitter/emag_act(var/remaining_charges, var/mob/user)
	if(!emagged)
		locked = 0
		emagged = 1
		user.visible_message("[user.name] emags [src].","<span class='warning'>You short out the lock.</span>")
		return 1
*/

// Pre-welded version for easy deployment on map
/obj/machinery/power/rust_core/prewelded
	anchored = 1
	state = STATE_WELDED
