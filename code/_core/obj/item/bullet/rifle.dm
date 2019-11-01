/obj/item/bullet/rifle_762
	name = "\improper 7.62mm bullet"
	desc = "For rifles that require 7.62mm"
	id = "7.62"
	icon = 'icons/obj/items/bullet/762.dmi'

	item_count_max = 5
	item_count_max_icon = 5

	projectile = /obj/projectile/bullet/rifle
	damage_type = "7.62"

	bullet_speed = BULLET_SPEED_RIFLE_HEAVY


/obj/item/bullet/rifle_762/on_spawn()
	item_count_current = 5


/obj/item/bullet/rifle_762/surplus
	name = "\improper 7.62mm surplus bullet"
	damage_type = "7.62_surplus"
	icon = 'icons/obj/items/bullet/762_surplus.dmi'

	bullet_speed = BULLET_SPEED_RIFLE_HEAVY * SURPLUS_PENALTY

/obj/item/bullet/rifle_556
	name = "\improper 5.56mm bullet"
	desc = "For rifles and machineguns that requre 5.56mm"
	id = "5.56"
	icon = 'icons/obj/items/bullet/556.dmi'

	projectile = /obj/projectile/bullet/rifle
	damage_type = "5.56"

	bullet_speed = BULLET_SPEED_RIFLE_LIGHT