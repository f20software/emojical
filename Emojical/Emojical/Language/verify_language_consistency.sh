#!/bin/ksh

EN=en.lproj/Localizable.strings
SP=es.lproj/Localizable.strings
BY=be.lproj/Localizable.strings
retval=0

echo "*** English language: $EN"
grep '^\"' $EN | while read name value
do
   if ! grep -q "^$name" $SP
   then 
      echo "[ERROR!] Not found - $name"
      retval=1
   fi
done

echo "*** Spanish language: $SP"
grep '^\"' $SP | while read name value
do
   if ! grep -q "^$name" $EN
   then 
      echo "[ERROR!] Not found - $name"
      retval=1
   fi
done

echo "*** Belarussian language: $BY"
grep '^\"' $BY | while read name value
do
   if ! grep -q "^$name" $EN
   then 
      echo "[ERROR!] Not found - $name"
      retval=1
   fi
done

exit $retval

