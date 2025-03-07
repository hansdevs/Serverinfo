echo @echo off > testscript.bat
echo cd /d E:\Serverinfo >> testscript.bat
echo echo Hello from Git test > testfile.txt >> testscript.bat
echo git add -A >> testscript.bat
echo git commit -m "Test commit" >> testscript.bat
echo git push origin main >> testscript.bat
echo echo Done! >> testscript.bat
echo pause >> testscript.bat
