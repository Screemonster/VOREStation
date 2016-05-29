//
// RUST Core Control Console
//

/obj/machinery/computer/rust_core_control
	name = "RUST Core Control"
	icon = 'icons/rust.dmi'
	icon_state = "core_control"
	var/list/connected_devices = list()
	var/scan_range = 25
	//currently viewed
	var/obj/machinery/power/rust_core/cur_viewed_device

/obj/machinery/computer/rust_core_control/process()
	if(stat & (BROKEN|NOPOWER))
		return

/obj/machinery/computer/rust_core_control/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/rust_core_control/attack_hand(mob/user)
	add_fingerprint(user)
	interact(user)

/obj/machinery/computer/rust_core_control/interact(mob/user)
	if(stat & BROKEN)
		user.unset_machine()
		user << browse(null, "window=rust_core_control")
		return
	if (!istype(user, /mob/living/silicon) && (get_dist(src, user) > 1 ))
		user.unset_machine()
		user << browse(null, "window=rust_core_control")
		return

	var/dat = ""
	if(stat & NOPOWER)
		dat += "<i>The console is dark and nonresponsive.</i>"
	else
		dat += "<B>Reactor Core Primary Monitor</B><BR>"
		if(cur_viewed_device && cur_viewed_device.stat & (BROKEN|NOPOWER))
			cur_viewed_device = null
		if(cur_viewed_device && !cur_viewed_device.remote_access_enabled)
			cur_viewed_device = null

		if(cur_viewed_device)
			dat += "<b>Device tag:</b> [cur_viewed_device.id_tag ? cur_viewed_device.id_tag : "UNSET"]<br>"
			dat += "<font color=blue>Device [cur_viewed_device.owned_field ? "activated" : "deactivated"].</font><br>"
			dat += "<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];toggle_active=1'>\[Bring field [cur_viewed_device.owned_field ? "offline" : "online"]\]</a><br>"
			dat += "<b>Device [cur_viewed_device.anchored ? "secured" : "unsecured"].</b><br>"
			dat += "<hr>"
			dat += "<b>Field encumbrance:</b> [cur_viewed_device.owned_field ? 0 : "NA"]<br>"
			dat += "<b>Field strength:</b> [cur_viewed_device.field_strength] Wm^3<br>"
			dat += "<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];str=-1000'>\[----\]</a> \
			<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];str=-100'>\[--- \]</a> \
			<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];str=-10'>\[--  \]</a> \
			<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];str=-1'>\[-   \]</a> \
			<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];str=1'>\[+   \]</a> \
			<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];str=10'>\[++  \]</a> \
			<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];str=100'>\[+++ \]</a> \
			<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];str=1000'>\[++++\]</a><br>"

			var/power_stat = "Good"
			if(cur_viewed_device.cached_power_avail < cur_viewed_device.active_power_usage)
				power_stat = "Insufficient"
			else if(cur_viewed_device.cached_power_avail < cur_viewed_device.active_power_usage * 2)
				power_stat = "Marginal"
			dat += "<b>Power status:</b> [power_stat]<br>"

			if(cur_viewed_device.owned_field)
				var/obj/effect/rust_em_field/EM = cur_viewed_device.owned_field
				dat += "<B>Field Energy</B>: [EM.energy]<BR>"
				var/datum/gas_mixture/environment = EM.held_phoron
				var/pressure = environment.return_pressure()
				var/total_moles = environment.total_moles
				dat += "<B><U>Enclosed Gasses:</U></B><BR>"
				dat += "<B>Pressure:</B> [round(pressure,0.1)] kPa<BR>"
				if(total_moles)
					for(var/g in environment.gas)
						dat += "<B>[gas_data.name[g]]:</B> [round((environment.gas[g] / total_moles) * 100)]% ([round(environment.gas[g], 0.01)] moles)<BR>"
					dat += "<B>Temperature:</B> [round(environment.temperature-T0C,0.1)]&deg;C ([round(environment.temperature,0.1)]K)<BR>"
					dat += "<B>Heat Capacity:</B> [round(environment.heat_capacity(),0.1)]<BR>"
		else
			dat += "<a href='?src=\ref[src];scan=1'>\[Refresh device list\]</a><br><br>"
			if(connected_devices.len)
				dat += "<table width='100%' border=1>"
				dat += "<tr>"
				dat += "<td><b>Device tag</b></td>"
				dat += "<td></td>"
				dat += "</tr>"
				for(var/obj/machinery/power/rust_core/C in connected_devices)
					if(!check_core_status(C))
						connected_devices.Remove(C)
						continue

					dat += "<tr>"
					dat += "<td>[C.id_tag]</td>"
					dat += "<td><a href='?src=\ref[src];manage_individual=\ref[C]'>\[Manage\]</a></td>"
					dat += "</tr>"
					dat += "</table>"
			else
				dat += "No devices connected.<br>"

		dat += "<hr>"
		dat += "<a href='?src=\ref[src];refresh=1'>Refresh</a> "
		dat += "<a href='?src=\ref[src];close=1'>Close</a>"

	user << browse(dat, "window=rust_core_control;size=500x400")
	onclose(user, "rust_core_control")
	user.set_machine(src)

/obj/machinery/computer/rust_core_control/Topic(href, href_list)
	..()

	if( href_list["goto_scanlist"] )
		cur_viewed_device = null

	if( href_list["manage_individual"] )
		cur_viewed_device = locate(href_list["manage_individual"])

	if( href_list["scan"] )
		connected_devices = list()
		for(var/obj/machinery/power/rust_core/C in range(scan_range, src))
			if(check_core_status(C))
				connected_devices.Add(C)

	if( href_list["startup"] )
		if(cur_viewed_device)
			cur_viewed_device.Startup()

	if( href_list["shutdown"] )
		if(cur_viewed_device)
			cur_viewed_device.Shutdown()

	if( href_list["close"] )
		usr << browse(null, "window=core_control")
		usr.unset_machine()

	updateDialog()

/obj/machinery/computer/rust_core_control/proc/check_core_status(var/obj/machinery/power/rust_core/C)
	if(!C)
		return 0

	if(C.stat & (BROKEN|NOPOWER) || !C.remote_access_enabled || !C.id_tag)
		if(connected_devices.Find(C))
			connected_devices.Remove(C)
		return 0

	return 1
