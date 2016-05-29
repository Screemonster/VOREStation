/*
	RUST - Fusion Reactor

	History:
		RUST was originally designed and made by {SOMEONE?} but it was never finished and didn't work.
		Worse, it was not clear even how it was SUPPOSED to work.  Therefore Leshana decided to
		use the basic concepts and the sprites to make a new idea.

	Okay here is the new and improved RUST design.

	Thing.
	Stuff.

	Okay a core that generates an EM field.

	The fluff is that fusion is possible by using PHORON as a catalyst for the fusion.

	Core consumes power to generate (and maintain!) the EM field!
	The core ONLY generates the EM core, it does not help fuse fuel at all!

	Once created, the EM field acts as a ccontainer for the "reaction" to happen in.

	Fuel is injected into the EM field by a fuel injector!
	Fuel is added to fuel injector by fuel injector port.

	Fusion only takes place if the EM field's phoron content is at a certain minimum "excitation" level.
		TODO - Possibly if the "radiation" level is high?
	EM field phoron excitation is boosted by shooting the field with emitters!

	EM field:
		Emits radiation proportional to its excitation level.
		Heats the air around it proportional to its excitation level?
		Should it generate energy any other way? Any other side effects?
	If EM field should collapse... everything inside is released. This includes fuel and
		phoron at insane temperatures.  So, no explosion, but insane temps!
		Possibly at extreme pressure too?
		TODO - Way to orderly shutdown.

	TODO - Needs to be a way to get phron into the EM field.
		Should it just pull in all phron around it?
		Should it need to be connected by pipes?
		Pipes make the most sense, but I also would like there to
		be a need to handle loose plasma as part of its operation (simply for gameplay reasons!)

	Reactions:
		When excitation energy is high enough, fuels in the EM field will react.
		These reactions will produce byproducts, radiation, and increase excitation level.
			Note! Yes this DOES mean that BOTH the EM field AND reactions produce radiation.
			This represents nuclear radiation from fusion, and also synchrotron radiation from
			the particles curving in magnetic field.

	Field Strength:
		Should we do this? Perhaps can contain maximum energy inside EM field (based on field str)
		But higher field str requires more energy to maintain.

	NOTE: Old system had some concept of "frequencies" of the EM field and gyrotrons.
		I'm not sure what purpose that served and was a bit confusing too...
		At least for now I have done away with that feature.  Perhaps in the future
		can re-add it simply to add another element of gameplay, but will need to think.

*/

// Stages of attaching the machine to the floor
#define STATE_LOOSE		0
#define STATE_BOLTED	1
#define STATE_WELDED	2
