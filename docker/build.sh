#!/bin/sh
echo copy files to /build
cp -R /mnt/build/* /build
echo running npm install
npm install --production
echo zipping all to /mnt/dist/function.zip 
zip -r /mnt/dist/function.zip *