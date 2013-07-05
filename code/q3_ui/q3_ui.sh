#!/bin/sh

mkdir -p vm
cd vm

CC="q3lcc"
# -DQ3_VM -DIOS -S -Wf-target=bytecode -Wf-g -I../../cgame -I../../game -I../../q3_ui "

$CC ../ui_main.c
$CC ../ui_cdkey.c
$CC ../ui_ingame.c
$CC ../ui_confirm.c
$CC ../ui_setup.c
$CC ../../game/bg_misc.c
$CC ../../game/bg_lib.c
$CC ../../game/q_math.c
$CC ../../game/q_shared.c
$CC ../ui_gameinfo.c
$CC ../ui_atoms.c
$CC ../ui_connect.c
$CC ../ui_controls2.c
$CC ../ui_demo2.c
$CC ../ui_mfield.c
$CC ../ui_credits.c
$CC ../ui_menu.c
$CC ../ui_options.c
$CC ../ui_display.c
$CC ../ui_sound.c
$CC ../ui_network.c
$CC ../ui_playermodel.c
$CC ../ui_players.c
$CC ../ui_playersettings.c
$CC ../ui_preferences.c
$CC ../ui_qmenu.c
$CC ../ui_serverinfo.c
$CC ../ui_servers2.c
$CC ../ui_sparena.c
$CC ../ui_specifyserver.c
$CC ../ui_splevel.c
$CC ../ui_sppostgame.c
$CC ../ui_startserver.c
$CC ../ui_team.c
$CC ../ui_video.c
$CC ../ui_cinematics.c
$CC ../ui_spskill.c
$CC ../ui_addbots.c
$CC ../ui_removebots.c
$CC ../ui_loadconfig.c
$CC ../ui_saveconfig.c
$CC ../ui_teamorders.c
$CC ../ui_mods.c

q3asm -vq3 -o ui.qvm \
ui_main.asm \
bg_lib.asm \
bg_misc.asm \
ui_addbots.asm \
ui_ingame.asm \
ui_atoms.asm \
ui_cdkey.asm \
ui_cinematics.asm \
ui_confirm.asm \
ui_connect.asm \
ui_controls2.asm \
ui_credits.asm \
ui_demo2.asm \
ui_display.asm \
ui_gameinfo.asm \
ui_loadconfig.asm \
ui_menu.asm \
ui_mfield.asm \
ui_mods.asm \
ui_network.asm \
ui_options.asm \
ui_playermodel.asm \
ui_players.asm \
ui_playersettings.asm \
ui_preferences.asm \
ui_qmenu.asm \
ui_removebots.asm \
ui_saveconfig.asm \
ui_serverinfo.asm \
ui_servers2.asm \
ui_setup.asm \
ui_sound.asm \
ui_sparena.asm \
ui_specifyserver.asm \
ui_splevel.asm \
ui_sppostgame.asm \
ui_spskill.asm \
ui_startserver.asm \
ui_team.asm \
ui_teamorders.asm \
ui_video.asm \
q_math.asm \
q_shared.asm \
../../ui/ui_syscalls.asm

cd ..
