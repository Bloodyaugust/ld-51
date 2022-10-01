#!/bin/sh

# set -e

which butler

echo "Checking application versions..."
echo "-----------------------------"
cat ~/.local/share/godot/templates/3.3.stable/version.txt
godot --version
butler -V
echo "-----------------------------"

mkdir build/
mkdir build/linux/
mkdir build/osx/
mkdir build/win/

echo "EXPORTING FOR LINUX"
echo "-----------------------------"
godot --export "Linux/X11" build/linux/ld-51.x86_64 -v
# echo "EXPORTING FOR OSX"
# echo "-----------------------------"
# godot --export "Mac OSX" build/osx/ld-51.dmg -v
echo "EXPORTING FOR WINDOZE"
echo "-----------------------------"
godot --export-debug "Windows Desktop" build/win/ld-51.exe -v
echo "-----------------------------"

# echo "CHANGING FILETYPE AND CHMOD EXECUTABLE FOR OSX"
# echo "-----------------------------"
# cd build/osx/
# mv ld-51.dmg ld-51-osx-alpha.zip
# unzip ld-51-osx-alpha.zip
# rm ld-51-osx-alpha.zip
# chmod +x ld-51.app/Contents/MacOS/ld-51
# zip -r ld-51-osx-alpha.zip ld-51.app
# rm -rf ld-51.app
# cd ../../

ls -al
ls -al build/
ls -al build/linux/
ls -al build/osx/
ls -al build/win/

echo "ZIPPING FOR WINDOZE"
echo "-----------------------------"
cd build/win/
zip -r ld-51-win-alpha.zip ld-51.exe ld-51.pck
rm -r ld-51.exe ld-51.pck
cd ../../

echo "ZIPPING FOR LINUX"
echo "-----------------------------"
cd build/linux/
zip -r ld-51-linux-alpha.zip ld-51.x86_64 ld-51.pck
rm -r ld-51.x86_64 ld-51.pck
cd ../../

echo "Logging in to Butler"
echo "-----------------------------"
butler login

echo "Pushing builds with Butler"
echo "-----------------------------"
butler push build/linux/ synsugarstudio/ld-51:linux-alpha
# butler push build/osx/ synsugarstudio/ld-51:osx-alpha
butler push build/win/ synsugarstudio/ld-51:win-alpha
