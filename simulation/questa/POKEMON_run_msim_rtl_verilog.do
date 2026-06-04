transcript on
if ![file isdirectory POKEMON_iputf_libs] {
	file mkdir POKEMON_iputf_libs
}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

###### Libraries for IPUTF cores 
###### End libraries for IPUTF cores 
###### MIF file copy and HDL compilation commands for IPUTF cores 


vcom "/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/PLL_40MHz_sim/PLL_40MHz.vho"

vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/BACKGROUND_ROM.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/CHARIZARD_ROM.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/FLAREON_ROM.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/GARCHOMP_ROM.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/JOLTEON_ROM.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/LAPRAS_ROM.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/LEAFEON_ROM.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/ODDISH_ROM.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/RANDOM_ROM.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/SANDSLASH_ROM.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/VAPOREON_ROM.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/ZERAORA_ROM.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/basic_package.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/bit1_fullAdder.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/contador_uni.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/VGA_package.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/bitn_fullAdder.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/battle_engine.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/image_sync.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/move_controller.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/pokemon_sel.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/pixel_generate.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/VGA.vhd}
vcom -93 -work work {/home/griznu1_/Nextcloud/ERR/UNI/5semestre/digitales/2proyecto/codigo/POKEMON.vhd}

