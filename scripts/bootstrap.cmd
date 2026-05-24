@echo off
setlocal

echo Creating missing Flutter platform folders...
flutter create .

echo Installing dependencies...
flutter pub get

echo Done.
