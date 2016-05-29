//
// RUST Fuel Asembly
//	This is the container for reactor fuel

/obj/item/weapon/fuel_assembly
	icon = 'icons/rust.dmi'
	icon_state = "fuel_assembly"
	name = "Fuel Rod Assembly"
	var/list/rod_quantities
	var/percent_depleted = 1
	layer = 3.1

	New()
		rod_quantities = new/list
