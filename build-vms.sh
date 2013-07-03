#!/bin/sh

mkdir -p vm

echo "Building qagame.qvm"
cd code/game
./game.sh
cp vm/qagame.qvm ../../vm/
rm -rf vm/

echo "Building cgame.qvm"
cd ../cgame
./cgame.sh
cp vm/cgame.qvm ../../vm/
rm -rf vm/

echo "Building ui.qvm"
cd ../q3_ui
./q3_ui.sh
cp vm/ui.qvm ../../vm/
rm -rf vm/

echo "Packaging pak9.pk3 with config file"
cd ../../
zip -u pak9.pk3 vm/*
zip -u pak9.pk3 default.cfg
rm -rf vm/
