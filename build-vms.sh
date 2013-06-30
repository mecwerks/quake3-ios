#!/bin/sh

mkdir -p vm

echo "Building qagame.qvm"
cd code/game
./game.sh
cp vm/qagame.qvm ../../vm/

echo "Building cgame.qvm"
cd ../cgame
./cgame.sh
cp vm/cgame.qvm ../../vm/

echo "Building ui.qvm"
cd ../q3_ui
./q3_ui.sh
cp vm/ui.qvm ../../vm/

echo "Packaging vm.pk3"
cd ../../
zip vm.pk3 vm/*
