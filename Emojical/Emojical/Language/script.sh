#!/bin/sh

EN=en.lproj/Localizable.strings
SP=es.lproj/Localizable.strings

echo "*** English language: $EN"
grep '^\"' $EN | while read name value
do
   if ! grep -q "^$name" $SP
   then 
      echo "[ERROR!] Not found - $name"
   fi
done

echo "*** Spanish language: $SP"
grep '^\"' $SP | while read name value
do
   if ! grep -q "^$name" $EN
   then 
      echo "[ERROR!] Not found - $name"
   fi
done

