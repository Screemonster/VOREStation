//
// TODO - Why do we need a separate machine for emitting radiation?
//	Also, is this some sort of new radiation systems?
//

// TODO - I think we don't need this.

/obj/machinery/rust/rad_source
	var/mega_energy = 0
	var/time_alive = 0
	var/source_alive = 2
	New()
		..()

	process()
		..()
		//fade away over time
		if(source_alive > 0)
			time_alive++
			source_alive--
		else
			time_alive -= 0.1
			if(time_alive < 0)
				qdel(src)

/obj/machinery/computer/rust_radiation_monitor
	name = "Radiation Monitor"
	icon_state = "power"
