#!/bin/sh
set -e

cd ../mods
do_link() {
	if [ ! -d "$(basename "$1")" ]
	then
		ln -s "../partial_mods/$1" $(basename "$1")
	fi
}

# animals_modpack
for mod in mobf mobf_settings animalmaterials\
	animal_big_red animal_chicken animal_clownfish\
	animal_creeper animal_deer animal_dm animal_fish_blue_white\
	animal_gull animal_rat animal_wolf\
	mob_oerkki mob_slime
do
	do_link "animals_modpack/$mod"
done

# survival_modpack
for mod in survival_lib\
	survival_drowning survival_hazards survival_hunger
do
	do_link "survival_modpack/$mod"
done

