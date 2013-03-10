"%wix%bin\candle.exe" setup.wxs
"%wix%bin\light.exe" setup.wixobj
move setup.msi urlazy.msi
