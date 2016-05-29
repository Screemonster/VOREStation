//
// RUST Fuel Compressor
// This machine creates the fuel assemblies that can be put into the injector port.
//

var/const/max_assembly_amount = 300

/obj/machinery/rust_fuel_compressor
	// TODO - Make an icon for this
	icon = 'icons/obj/forensics.dmi'
	icon_state = "olddna3"
	name = "Fuel Compressor"
	anchored = 1
	layer = 2.9
	circuit = /obj/item/weapon/circuitboard/rust_fuel_compressor

	var/list/new_assembly_quantities = list(
		"Deuterium"		= 150,
		"Tritium"		= 150,
		"Rodinium-6"	= 0,
		"Stravium-7"	= 0,
		"Pergium"		= 0,
		"Dilithium"		= 0
	)

	var/locked = 0
	var/compressed_matter = 0

/obj/machinery/rust_fuel_compressor/New()
	..()
	circuit = new circuit(src)
	component_parts = list()
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/stack/cable_coil(src, 4)
	RefreshParts()
	update_icon()

/obj/machinery/rust_fuel_compressor/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/rust_fuel_compressor/attack_hand(mob/user)
	add_fingerprint(user)
	interact(user)

/obj/machinery/rust_fuel_compressor/attackby(obj/item/W, mob/user)
	if(default_deconstruction_screwdriver(user, W))
		return
	if(default_deconstruction_crowbar(user, W))
		return
	if(default_part_replacement(user, W))
		return
	if(istype(W, /obj/item/weapon/rcd_ammo))
		compressed_matter += 10
		qdel(W)
		return
	..()

/obj/machinery/rust_fuel_compressor/interact(mob/user)
	if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
		if (!istype(user, /mob/living/silicon))
			user.unset_machine()
			user << browse(null, "window=fuelcomp")
			return

	var/t = "<B>Reactor Fuel Rod Compressor / Assembler</B><BR>"
	t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
	if(locked)
		t += "Swipe your ID to unlock this console."
	else
		t += "Compressed matter in storage: [compressed_matter] <A href='?src=\ref[src];eject_matter=1'>\[Eject all\]</a><br>"
		t += "<A href='?src=\ref[src];activate=1'><b>Activate Fuel Synthesis</b></A><BR> (fuel assemblies require no more than [max_assembly_amount] rods).<br>"
		t += "<hr>"
		t += "- New fuel assembly constituents:- <br>"
		for(var/reagent in new_assembly_quantities)
			t += "	[reagent] rods: [new_assembly_quantities[reagent]] \[<A href='?src=\ref[src];change_reagent=[reagent]'>Modify</A>\]<br>"
	t += "<hr>"
	t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"

	user << browse(t, "window=fuelcomp;size=500x300")
	user.set_machine(src)

/obj/machinery/rust_fuel_compressor/Topic(href, href_list)
	..()
	if( href_list["close"] )
		usr << browse(null, "window=fuelcomp")
		usr.machine = null

	if( href_list["eject_matter"] )
		var/ejected = 0
		while(compressed_matter > 10)
			new /obj/item/weapon/rcd_ammo(get_step(get_turf(src), src.dir))
			compressed_matter -= 10
			ejected = 1
		if(ejected)
			usr << "\blue \icon[src] [src] ejects some compressed matter units."
		else
			usr << "\red \icon[src] there are no more compressed matter units in [src]."

	if( href_list["activate"] )
		//world << "\blue New fuel rod assembly"
		var/obj/item/weapon/fuel_assembly/F = new(src)
		var/fail = 0
		var/old_matter = compressed_matter
		for(var/reagent in new_assembly_quantities)
			var/req_matter = round(new_assembly_quantities[reagent] / 30)
			if(req_matter <= compressed_matter)
				F.rod_quantities[reagent] = new_assembly_quantities[reagent]
				compressed_matter -= req_matter
				if(compressed_matter < 1)
					compressed_matter = 0
			else
				fail = 1
				break
		if(fail)
			flick("olddna1", src)
			qdel(F)
			compressed_matter = old_matter
			usr << "\red \icon[src] [src] flashes red: \'Out of matter.\'"
		else
			flick("olddna", src)
			F.forceMove(get_step(get_turf(src), src.dir))
			F.percent_depleted = 0
			if(compressed_matter < 0.034)
				compressed_matter = 0

	if( href_list["change_reagent"] )
		var/cur_reagent = href_list["change_reagent"]
		var/avail_rods = 300
		for(var/rod in new_assembly_quantities)
			avail_rods -= new_assembly_quantities[rod]
		avail_rods += new_assembly_quantities[cur_reagent]
		avail_rods = max(avail_rods, 0)

		var/new_amount = min(input("Enter new [cur_reagent] rod amount (max [avail_rods])", "Fuel Assembly Rod Composition ([cur_reagent])") as num, avail_rods)
		new_assembly_quantities[cur_reagent] = new_amount

	updateDialog()
