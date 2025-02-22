/obj/item/clothing/feet/shoes/runic
	name = "right runic boot"
	desc = "For when you want to turn up the heat a little."
	desc_extended = "A black combat boot. Shields your feet from shrapnel."

	icon_state = "inventory_right"
	icon_state_worn = "worn_right"
	worn_layer = LAYER_MOB_CLOTHING_BELT

	icon = 'icons/obj/item/clothing/shoes/runic.dmi'

	armor = /armor/steel/runic

	size = SIZE_2


	value = 60

	speed_bonus = 0

	rarity = RARITY_MYTHICAL



/obj/item/clothing/feet/shoes/runic/left
	name = "left runic boot"
	icon_state = "inventory_left"
	icon_state_worn = "worn_left"

	item_slot = SLOT_FOOT
	item_slot_mod = SLOT_MOD_LEFT
	protected_limbs = list(BODY_FOOT_LEFT)

