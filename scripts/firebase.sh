#!/bin/sh
# Download Firebase iOS SDK binary

if [ -d "Firebase" ]; then
echo "directory Firebase/ is not empty";
exit 0;
fi

wget https://github.com/firebase/firebase-ios-sdk/releases/download/6.24.0/Firebase-6.24.0.zip -O Firebase.zip
unzip Firebase.zip
rm -f Firebase.zip
rm -rf Firebase/FirebaseML*
