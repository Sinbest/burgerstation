/reagent/core/drug/ //Found in the snow biome as a magic plant
	name = "drug"
	id = "drug"
	desc = "What the fuck is this?"
	color = "#FFFFFF"
	metabolism_stomach = 1
	metabolism_blood = 2

	var/strength = 50
	var/duration_mod = 10

	liquid = -0.4

/reagent/core/drug/on_metabolize_stomach(var/atom/owner,var/reagent_container/container,var/starting_volume=0,var/multiplier=1)

	. = ..()

	if(is_living(owner))
		var/mob/living/L = owner
		L.add_status_effect(
			DRUGGY,
			magnitude = strength,
			duration = . * duration_mod //Every 20 units should last 5 minutes.
		)

	return .

/reagent/core/drug/on_metabolize_blood(var/atom/owner,var/reagent_container/container,var/starting_volume=0,var/multiplier=1)

	. = ..()

	if(is_living(owner))
		var/mob/living/L = owner
		L.add_status_effect(
			DRUGGY,
			magnitude = strength*2,
			duration = . * duration_mod //Every 20 units should last 5 minutes.
		)

	return .

/reagent/core/drug/liberty_dust
	name = "space liberty dust"
	id = "liberty_dust"
	desc = "The taste of liberty AND FREEDOM."
	color = "#FFFFFF"

	flavor = "freedom"

	strength = 75
	duration_mod = 10

	value = 7.5

	liquid = -0.6

/reagent/core/drug/space
	name = "space drugs"
	id = "space_drugs"
	desc = "It's like space weed."
	color = "#FFFFFF"

	flavor = "dude weed bro"

	strength = 25
	duration_mod = 15

	value = 4.5


/reagent/core/drug/dust
	name = "space dust"
	id = "space_dust"
	desc = "It's like space weed but better."
	color = "#7A9BFF"

	flavor = "regret"

	strength = 200
	duration_mod = 15

	value = 12

	liquid = -0.6