//
// The RUST EM field where all the cool stuff happens.
//

// TODO - Major Redesign!

/*
Deuterium-deuterium fusion : 40 x 10^7 K
Deuterium-tritium fusion: 4.5 x 10^7 K
*/

//#DEFINE MAX_STORED_ENERGY (held_phoron.phoron * held_phoron.phoron * SPECIFIC_HEAT_TOXIN)

/obj/effect/rust_em_field
	name = "EM Field"
	desc = "A coruscating, barely visible field of energy. It is shaped like a slightly flattened torus."
	icon = 'icons/rust.dmi'
	icon_state = "emfield_s1"
	layer = 3.1

	var/major_radius = 0	//longer radius in meters = field_strength * 0.21875, max = 8.75
	var/minor_radius = 0	//shorter radius in meters = field_strength * 0.2125, max = 8.625
	var/size = 1			//diameter in tiles
	var/volume_covered = 0	//atmospheric volume covered
	//
	var/obj/machinery/power/rust_core/owned_core
	var/list/dormant_reactant_quantities = list()

	// TODO - Brightness (and brightness color!) based on power!

	//
	var/energy = 0
	var/radiation = 0
	var/field_strength = 0.01						//in teslas, max is 50T
	var/datum/gas_mixture/held_phoron = new
	var/list/particle_catchers = list()

	var/emp_overload = 0

/obj/effect/rust_em_field/New()
	..()

	//make sure there's a field generator
	for(var/obj/machinery/power/rust_core/core in loc)
		owned_core = core

	if(!owned_core)
		qdel(src)


	// This creates catchers in a + pattern around us
	// TODO - Leshana - See about cleaning this up
	//create the gimmicky things to handle field collisions
	var/obj/effect/rust_particle_catcher/catcher

	// Radius 0
	catcher = new (locate(src.x,src.y,src.z))
	catcher.parent = src
	catcher.SetSize(1)
	particle_catchers.Add(catcher)
	// Radius 1
	catcher = new (locate(src.x-1,src.y,src.z))
	catcher.parent = src
	catcher.SetSize(3)
	particle_catchers.Add(catcher)
	catcher = new (locate(src.x+1,src.y,src.z))
	catcher.parent = src
	catcher.SetSize(3)
	particle_catchers.Add(catcher)
	catcher = new (locate(src.x,src.y+1,src.z))
	catcher.parent = src
	catcher.SetSize(3)
	particle_catchers.Add(catcher)
	catcher = new (locate(src.x,src.y-1,src.z))
	catcher.parent = src
	catcher.SetSize(3)
	particle_catchers.Add(catcher)
	// Radius 2
	catcher = new (locate(src.x-2,src.y,src.z))
	catcher.parent = src
	catcher.SetSize(5)
	particle_catchers.Add(catcher)
	catcher = new (locate(src.x+2,src.y,src.z))
	catcher.parent = src
	catcher.SetSize(5)
	particle_catchers.Add(catcher)
	catcher = new (locate(src.x,src.y+2,src.z))
	catcher.parent = src
	catcher.SetSize(5)
	particle_catchers.Add(catcher)
	catcher = new (locate(src.x,src.y-2,src.z))
	catcher.parent = src
	catcher.SetSize(5)
	particle_catchers.Add(catcher)
	// Radius 3
	catcher = new (locate(src.x-3,src.y,src.z))
	catcher.parent = src
	catcher.SetSize(7)
	particle_catchers.Add(catcher)
	catcher = new (locate(src.x+3,src.y,src.z))
	catcher.parent = src
	catcher.SetSize(7)
	particle_catchers.Add(catcher)
	catcher = new (locate(src.x,src.y+3,src.z))
	catcher.parent = src
	catcher.SetSize(7)
	particle_catchers.Add(catcher)
	catcher = new (locate(src.x,src.y-3,src.z))
	catcher.parent = src
	catcher.SetSize(7)
	particle_catchers.Add(catcher)

	//init values
	major_radius = field_strength * 0.21875// max = 8.75
	minor_radius = field_strength * 0.2125// max = 8.625
	volume_covered = M_PI * major_radius * minor_radius * 2.5 * 2.5 * 1000

	processing_objects.Add(src)

/obj/effect/rust_em_field/process()
	//make sure the field generator is still intact
	if(!owned_core)
		qdel(src)

	// TODO - Handle Radiation

	// Update values
	var/transfer_ratio = field_strength / 50 // higher field strength will result in faster phoron aggregation
	transfer_ratio = max(min(5, transfer_ratio, 100)) // Sanity check

	// Volume of a Torus: (pi*r^2)(2*pi*R)
	// Minor radius is alsays 1m (cells are 2.5m tall, lets leave 25cm clearance between floor and ceiling please!
	minor_radius = 1
	major_radius = field_strength * 0.21875// max = 8.75m
	volume_covered = (M_PI * minor_radius * minor_radius) * (2 * M_PI * major_radius) * 1000 // 1000 L in 1 m^3

	// Add phoron from the surrounding environment
	var/datum/gas_mixture/environment = loc.return_air()

	//hack in some stuff to remove phoron from the air because SCIENCE
	//the amount of phoron pulled in each update is relative to the field strength,
	//with 50T (max field strength) = 100% of area covered by the field
	//at minimum strength, 0.25% of the field volume is pulled in per update (?)
	//have a max of 1000 moles suspended
	if(!held_phoron.gas["phoron"] || held_phoron.gas["phoron"] < transfer_ratio * 1000)
		// Moles of gas in our enclosed volume?
		// n = PV/RT
		var/moles_covered = environment.return_pressure() * volume_covered / (environment.temperature * R_IDEAL_GAS_EQUATION)
		world << "\blue moles_covered: [moles_covered]"

		var/datum/gas_mixture/phoron_captured = environment.remove_by_flag(XGM_GAS_CONTAMINANT, moles_covered)
		world << "\blue phoron_captured.total_moles = [phoron_captured.total_moles]"
		if(phoron_captured.total_moles)
			held_phoron.merge(phoron_captured)

		// If it contains any phoron, extract it!
		/*
		if(gas_covered.gas["phoron"])
			var/datum/gas_mixture/phoron_captured = new /datum/gas_mixture()
			phoron_captured.gas["phoron"] = round(gas_covered.gas["phoron"] * transfer_ratio)
			phoron_captured.temperature = gas_covered.temperature
			phoron_captured.update_values()
			world << "\blue [phoron_captured.gas["phoron"]] moles of phoron captured"
			gas_covered.adjust_gas("phoron", -phoron_captured.gas["phoron"])

			held_phoron.merge(phoron_captured)
		environment.merge(gas_covered) // Put it back
		*/

	//let the particles inside the field react
	React()

	//forcibly radiate any excess energy
	/*var/energy_max = transfer_ratio * 100000
	if(mega_energy > energy_max)
		var/energy_lost = rand( 1.5 * (mega_energy - energy_max), 2.5 * (mega_energy - energy_max) )
		mega_energy -= energy_lost
		radiation += energy_lost*/

	//change held phoron temp according to energy levels
	//SPECIFIC_HEAT_TOXIN
	// But don't let it get TOO hot or it breaks ZAS
	if(energy > 0 && held_phoron.gas["phoron"])
		var/heat_capacity = held_phoron.heat_capacity() //200 * number of phoron moles
		if(heat_capacity > 0.0003)	//formerly MINIMUM_HEAT_CAPACITY
			if(held_phoron.temperature < 16000000 && held_phoron.temperature + energy < 16000000)
				held_phoron.temperature += energy

	//if there is too much phoron in the field, lose some
	if(held_phoron.gas["phoron"] > 1)
		//lose a random amount of phoron back into the air, increased by the field strength (want to switch this over to frequency eventually)
		var/loss_ratio = rand() * (0.05 + (0.05 * 50 / field_strength))
		world << "lost [loss_ratio*100]% of held phoron"
		//
		var/datum/gas_mixture/phoron_lost = new
		phoron_lost.temperature = held_phoron.temperature
		//
		phoron_lost.gas["phoron"] = held_phoron.gas["phoron"] * loss_ratio
		//phoron_lost.update_values()
		held_phoron.gas["phoron"] -= held_phoron.gas["phoron"] * loss_ratio
		//held_phoron.update_values()
		//
		environment.merge(phoron_lost)
	else
		held_phoron.gas["phoron"] = 0
		held_phoron.update_values()

	//handle some reactants formatting
	for(var/reactant in dormant_reactant_quantities)
		var/amount = dormant_reactant_quantities[reactant]
		if(amount < 1)
			dormant_reactant_quantities.Remove(reactant)
		else if(amount >= 1000000)
			var/radiate = rand(3 * amount / 4, amount / 4)
			dormant_reactant_quantities[reactant] -= radiate
			radiation += radiate

	return 1

/obj/effect/rust_em_field/proc/ChangeFieldStrength(var/new_strength)
	var/calc_size = 1
	emp_overload = 0
	if(new_strength <= 50)
		calc_size = 1
	else if(new_strength <= 200)
		calc_size = 3
	else if(new_strength <= 500)
		calc_size = 5
	else
		calc_size = 7
		if(new_strength > 900)
			emp_overload = 1

	field_strength = new_strength
	change_size(calc_size)

/obj/effect/rust_em_field/proc/AddEnergy(var/a_energy)
	world << "\blue Added [a_energy]"
	energy += a_energy

/obj/effect/rust_em_field/proc/AddParticles(var/name, var/quantity = 1)
	world << "\blue AddParticles([name], [quantity])"
	if(name in dormant_reactant_quantities)
		dormant_reactant_quantities[name] += quantity
	else if(name != "proton" && name != "electron" && name != "neutron")
		dormant_reactant_quantities.Add(name)
		dormant_reactant_quantities[name] = quantity

// Field is shutting down, dump it all!
/obj/effect/rust_em_field/proc/RadiateAll(var/ratio_lost = 1)
	// Particles get converted to radiation
	for(var/particle in dormant_reactant_quantities)
		radiation += dormant_reactant_quantities[particle]
		dormant_reactant_quantities.Remove(particle)
	// All stored energy gets converted to radiation!
	radiation += energy
	energy = 0

	// Release all held gasses back into the air
	var/datum/gas_mixture/environment = loc.return_air()
	environment.merge(held_phoron)

/obj/effect/rust_em_field/proc/change_size(var/newsize = 1)
	switch(newsize)
		if(1)
			size = 1
			icon = 'icons/rust.dmi'
			icon_state = "emfield_s1"
			pixel_x = 0
			pixel_y = 0
		if(3)
			size = 3
			icon = 'icons/effects/96x96.dmi'
			icon_state = "emfield_s3"
			pixel_x = -32
			pixel_y = -32
		if(5)
			size = 5
			icon = 'icons/effects/160x160.dmi'
			icon_state = "emfield_s5"
			pixel_x = -64
			pixel_y = -64
		if(7)
			size = 7
			icon = 'icons/effects/224x224.dmi'
			icon_state = "emfield_s7"
			pixel_x = -96
			pixel_y = -96

	// TODO - Reallocate the catchers instead of this dumb thing!
	for(var/obj/effect/rust_particle_catcher/catcher in particle_catchers)
		catcher.UpdateSize()


//the !!fun!! part
/obj/effect/rust_em_field/proc/React()
	//loop through the reactants in random order
	var/list/reactants_reacting_pool = dormant_reactant_quantities.Copy()
	/*
	for(var/reagent in dormant_reactant_quantities)
		world << "	before: [reagent]: [dormant_reactant_quantities[reagent]]"
		*/

	//cant have any reactions if there aren't any reactants present
	if(reactants_reacting_pool.len)
		//determine a random amount to actually react this cycle, and remove it from the standard pool
		//this is a hack, and quite nonrealistic :(
		for(var/reactant in reactants_reacting_pool)
			reactants_reacting_pool[reactant] = rand(0, reactants_reacting_pool[reactant])
			dormant_reactant_quantities[reactant] -= reactants_reacting_pool[reactant]
			if(!reactants_reacting_pool[reactant])
				reactants_reacting_pool -= reactant

		//loop through all the reacting reagents, picking out random reactions for them
		var/list/produced_reactants = new/list
		var/list/primary_reactant_pool = reactants_reacting_pool.Copy()
		while(primary_reactant_pool.len)
			//pick one of the unprocessed reacting reagents randomly
			var/cur_primary_reactant = pick(primary_reactant_pool)
			primary_reactant_pool.Remove(cur_primary_reactant)
			world << "\blue	primary reactant chosen: [cur_primary_reactant]"

			//grab all the possible reactants to have a reaction with
			var/list/possible_secondary_reactants = reactants_reacting_pool.Copy()
			//if there is only one of a particular reactant, then it can not react with itself so remove it
			possible_secondary_reactants[cur_primary_reactant] -= 1
			if(possible_secondary_reactants[cur_primary_reactant] < 1)
				possible_secondary_reactants.Remove(cur_primary_reactant)

			//loop through and work out all the possible reactions
			var/list/possible_reactions = new/list
			for(var/cur_secondary_reactant in possible_secondary_reactants)
				if(possible_secondary_reactants[cur_secondary_reactant] < 1)
					continue
				var/datum/fusion_reaction/cur_reaction = get_fusion_reaction(cur_primary_reactant, cur_secondary_reactant)
				if(cur_reaction)
					world << "\blue	secondary reactant: [cur_secondary_reactant]"
					possible_reactions.Add(cur_reaction)

			//if there are no possible reactions here, abandon this primary reactant and move on
			if(!possible_reactions.len)
				//world << "\blue	no reactions"
				continue

			//split up the reacting atoms between the possible reactions
			while(possible_reactions.len)
				//pick a random substance to react with
				var/datum/fusion_reaction/cur_reaction = pick(possible_reactions)
				possible_reactions.Remove(cur_reaction)
				world << "\blue Reaction Chosen: [cur_reaction.type]"

				//set the randmax to be the lower of the two involved reactants
				var/max_num_reactants = reactants_reacting_pool[cur_reaction.primary_reactant] > reactants_reacting_pool[cur_reaction.secondary_reactant] ? \
				reactants_reacting_pool[cur_reaction.secondary_reactant] : reactants_reacting_pool[cur_reaction.primary_reactant]
				if(max_num_reactants < 1)
					continue

				//make sure we have enough energy
				if(energy < max_num_reactants * cur_reaction.energy_consumption)
					max_num_reactants = round(energy / cur_reaction.energy_consumption)
					if(max_num_reactants < 1)
						world << "\red But not enough energy"
						continue

				//randomly determined amount to react
				var/amount_reacting = rand(1, max_num_reactants)

				//removing the reacting substances from the list of substances that are primed to react this cycle
				//if there aren't enough of that substance (there should be) then modify the reactant amounts accordingly
				if( reactants_reacting_pool[cur_reaction.primary_reactant] - amount_reacting >= 0 )
					reactants_reacting_pool[cur_reaction.primary_reactant] -= amount_reacting
				else
					amount_reacting = reactants_reacting_pool[cur_reaction.primary_reactant]
					reactants_reacting_pool[cur_reaction.primary_reactant] = 0
				//same again for secondary reactant
				if( reactants_reacting_pool[cur_reaction.secondary_reactant] - amount_reacting >= 0 )
					reactants_reacting_pool[cur_reaction.secondary_reactant] -= amount_reacting
				else
					reactants_reacting_pool[cur_reaction.primary_reactant] += amount_reacting - reactants_reacting_pool[cur_reaction.primary_reactant]
					amount_reacting = reactants_reacting_pool[cur_reaction.secondary_reactant]
					reactants_reacting_pool[cur_reaction.secondary_reactant] = 0

				//remove the consumed energy
				energy -= max_num_reactants * cur_reaction.energy_consumption

				//add any produced energy
				energy += max_num_reactants * cur_reaction.energy_production

				//add any produced radiation
				radiation += max_num_reactants * cur_reaction.radiation

				//create the reaction products
				for(var/reactant in cur_reaction.products)
					var/success = 0
					for(var/check_reactant in produced_reactants)
						if(check_reactant == reactant)
							produced_reactants[reactant] += cur_reaction.products[reactant] * amount_reacting
							success = 1
							break
					if(!success)
						produced_reactants[reactant] = cur_reaction.products[reactant] * amount_reacting

				//this reaction is done, and can't be repeated this sub-cycle
				possible_reactions.Remove(cur_reaction.secondary_reactant)

		//
		/*if(new_radiation)
			if(!radiating)
				radiating = 1
				PeriodicRadiate()*/

		//loop through the newly produced reactants and add them to the pool
		//var/list/neutronic_radiation = new
		//var/list/protonic_radiation = new
		for(var/reactant in produced_reactants)
			AddParticles(reactant, produced_reactants[reactant])
			//world << "produced: [reactant], [dormant_reactant_quantities[reactant]]"

		//check whether there are reactants left, and add them back to the pool
		for(var/reactant in reactants_reacting_pool)
			AddParticles(reactant, reactants_reacting_pool[reactant])
			//world << "retained: [reactant], [reactants_reacting_pool[reactant]]"

/obj/effect/rust_em_field/Destroy()
	//radiate everything in one giant burst
	for(var/obj/effect/rust_particle_catcher/catcher in particle_catchers)
		qdel(catcher)
	RadiateAll()

	processing_objects.Remove(src)
	..()
