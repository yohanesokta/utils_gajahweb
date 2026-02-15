@echo off
mkdir build
cd build
echo Building...
cmake ..
cd ..
cmake --build build --config Release
echo .
echo .
echo Successfull build
echo Build In Files : .\build\Release\
@echo on