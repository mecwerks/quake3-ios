#!/bin/sh

mkdir -p vm
cd vm

CC="q3lcc"
#-DQ3_VM -DCGAME -S -Wf-target=bytecode -Wf-g -I../../cgame -I../../game -I../../q3_ui"

$CC ../../game/bg_misc.c
$CC ../../game/bg_pmove.c
$CC ../../game/bg_slidemove.c
$CC ../../game/bg_lib.c
$CC ../../game/q_math.c
$CC ../../game/q_shared.c
$CC ../cg_consolecmds.c
$CC ../cg_draw.c
$CC ../cg_drawtools.c
$CC ../cg_effects.c
$CC ../cg_ents.c
$CC ../cg_event.c
$CC ../cg_info.c
$CC ../cg_localents.c
$CC ../cg_main.c
$CC ../cg_marks.c
$CC ../cg_players.c
$CC ../cg_playerstate.c
$CC ../cg_predict.c
$CC ../cg_scoreboard.c
$CC ../cg_servercmds.c
$CC ../cg_snapshot.c
$CC ../cg_view.c
$CC ../cg_weapons.c

q3asm -vq3 -o cgame.qvm \
cg_main.asm \
bg_misc.asm \
bg_pmove.asm \
bg_slidemove.asm \
bg_lib.asm \
q_math.asm \
q_shared.asm \
cg_consolecmds.asm \
cg_draw.asm \
cg_drawtools.asm \
cg_effects.asm \
cg_ents.asm \
cg_event.asm \
cg_info.asm \
cg_localents.asm \
cg_marks.asm \
cg_players.asm \
cg_playerstate.asm \
cg_predict.asm \
cg_scoreboard.asm \
cg_servercmds.asm \
cg_snapshot.asm \
cg_view.asm \
cg_weapons.asm \
../cg_syscalls.asm

cd ..
