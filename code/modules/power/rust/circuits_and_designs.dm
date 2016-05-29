#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

//////////////////////////////////////
// RUST Core Control computer

/obj/item/weapon/circuitboard/rust_core_control
	name = T_BOARD("RUST core controller")
	build_path = /obj/machinery/computer/rust_core_control
	origin_tech = list(TECH_DATA = 1, TECH_ENGINEERING = 3, TECH_POWER = 3)

/datum/design/circuit/rust_core_control
	name = "RUST core controller"
	id = "rust_core_control"
	req_tech = list(TECH_DATA = 1, TECH_ENGINEERING = 3, TECH_POWER = 3)
	build_path = /obj/item/weapon/circuitboard/rust_core_control
	sort_string = "JAABA"

//////////////////////////////////////
// RUST Fuel Control computer

/obj/item/weapon/circuitboard/rust_fuel_control
	name = T_BOARD("RUST fuel controller")
	build_path = /obj/machinery/computer/rust_fuel_control
	origin_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 3, TECH_POWER = 1)

/datum/design/circuit/rust_fuel_control
	name = "RUST fuel controller"
	id = "rust_core_control"
	req_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 3, TECH_POWER = 1)
	build_path = /obj/item/weapon/circuitboard/rust_fuel_control
	sort_string = "JAABA"

//////////////////////////////////////
// RUST Fuel Port board

// TODO - Make this buildable

/*
/obj/item/weapon/module/rust_fuel_port
	name = "Internal circuitry (RUST fuel port)"
	icon_state = "card_mod"
	origin_tech = "engineering=4;materials=5"

datum/design/rust_fuel_port
	name = "Internal circuitry (RUST fuel port)"
	desc = "Allows for the construction of circuit boards used to build a fuel injection port for the RUST fusion engine."
	id = "rust_fuel_port"
	req_tech = list("engineering" = 4, "materials" = 5)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$uranium" = 3000)
	build_path = "/obj/item/weapon/module/rust_fuel_port"
*/

//////////////////////////////////////
// RUST Fuel Compressor board

/obj/item/weapon/circuitboard/rust_fuel_compressor
	name = T_BOARD("RUST fuel compressor")
	build_path = "/obj/machinery/rust_fuel_compressor"
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 3, TECH_MATERIAL = 3)
	req_components = list(
							/obj/item/stack/cable_coil = 4,
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/manipulator = 1)

/datum/design/circuit/rust_fuel_compressor
	name = "RUST fuel compressor"
	id = "rust_fuel_compressor"
	req_tech = list(TECH_ENGINEERING = 3, TECH_MATERIAL = 3)
	materials = list("glass" = 1000, "gold" = 100)
	build_path = /obj/item/weapon/circuitboard/rust_fuel_compressor
	sort_string = "JAABA"

//////////////////////////////////////
// RUST Tokamak Core board

/obj/item/weapon/circuitboard/rust_core
	name = T_BOARD("RUST tokamak core")
	build_path = "/obj/machinery/rust_core"
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 3, TECH_POWER = 3, TECH_PHORON = 2)
	req_components = list(
							/obj/item/stack/cable_coil = 30,
							/obj/item/weapon/stock_parts/capacitor = 2,
							/obj/item/weapon/stock_parts/micro_laser = 1)

/datum/design/circuit/rust_core
	name = "RUST tokamak core"
	id = "rust_core"
	req_tech = list(TECH_ENGINEERING = 3, TECH_POWER = 3, TECH_PHORON = 2)
	materials = list("glass" = 1000, "gold" = 100)
	build_path = /obj/item/weapon/circuitboard/rust_core
	sort_string = "JAABA"

// TODO - Reliability

//////////////////////////////////////
// RUST Fuel Injector board

/obj/item/weapon/circuitboard/rust_fuel_injector
	name = T_BOARD("RUST fuel injector")
	build_path = "/obj/machinery/rust_fuel_injector"
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 3, TECH_DATA = 1)
	req_components = list(
							/obj/item/stack/cable_coil = 4,
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1)

/datum/design/circuit/rust_fuel_injector
	name = "RUST fuel injector"
	id = "rust_fuel_injector"
	req_tech = list(TECH_ENGINEERING = 3, TECH_DATA = 1)
	materials = list("glass" = 1000, "gold" = 100)
	build_path = /obj/item/weapon/circuitboard/rust_fuel_injector
	sort_string = "JAABA"

