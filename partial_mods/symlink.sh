#!/bin/sh
set -e

cd ../mods
do_link() {
	ln -s "../partial_mods/$1" $(basename "$1")
}

# animals_modpack
for mod in mobf mobf_settings animalmaterials\
	animal_big_red animal_chicken animal_clownfish animal_cow\
	animal_creeper animal_deer animal_dm animal_fish_blue_white\
	animal_gull animal_rat animal_sheep animal_vombie animal_wolf\
	mob_oerkki mob_ostrich mob_slime
do
	do_link "animals_modpack/$mod"
done

