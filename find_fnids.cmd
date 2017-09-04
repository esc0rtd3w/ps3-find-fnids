:: find_fnids Windows Port
:: https://github.com/esc0rtd3w/ps3-find-fnids

:: esc0rtd3w 2017


@echo off

title PS3 FNIDS Script      [original script: kakaroto]   [Windows Port by esc0rtd3w 2017]

setlocal enabledelayedexpansion

:: Thanks to kakaroto for ps3ida files and original find_fnids.sh Linux script https://github.com/kakaroto/ps3ida
:: Thanks to MatChung for ps3 cygwin binaries https://github.com/MatChung/ps3dev-Cygwin

set root=%~dp0
set bin=%root%bin
set scripts=%root%scripts
set temp=%root%temp
set objTemp=%root%obj

set rmd=rd /s /q
set rmf=del /s /q
set rmff=del /f /s /q
set mkdir=md
set mv=move

set ar=%bin%\ar.exe
set awk=%bin%\awk.exe
set cat=%bin%\cat.exe
set cut=%bin%\cut.exe
set diff=%bin%\diff.exe
set echo=%bin%\echo.exe
set grep=%bin%\grep.exe
set head=%bin%\head.exe
::set objdump=%bin%objdump.exe
set ppu-cppfilt=%bin%\ppu-cppfilt.exe
set ppu-objdump=%bin%\ppu-objdump.exe
set print=%bin%\printf.exe
set sed=%bin%\sed.exe
set sort=%bin%\sort.exe
set tclsh=%bin%\tclsh.exe
set uniq=%bin%\uniq.exe

set CPPFUNC=
set CPPFUNC_args=
set FNIDS=
set FNID=
set FUNC=

set PS3_SDK=c:\usr\local\cell
set PPU_LIB=%PS3_SDK%\target\ppu\lib
set SPU_LIB=%PS3_SDK%\target\spu\lib

set argOne=
set argTwo=

:: Remove old obj folder and create a new one
if exist obj %rmd% obj
if not exist obj %mkdir% obj

:: Check for temp folder
if not exist obj %mkdir% temp


:: Remove old txt dumps
%rmff% %temp%\stublistSDK.txt
%rmff% %temp%\stublistRoot.txt
%rmff% %temp%\cppfunc.txt


color 0e
cls
echo Creating obj Directory and Copying SDK _stub.a Files....
echo.
echo.
echo.

:: Go to SDK PPU lib folder
pushd %PPU_LIB%

::echo.
::echo.
::echo.
::echo You Are Here: %cd%
::pause

for /f "delims=" %%f in ('dir /b /a-d-h-s') do (
echo "%PPU_LIB%\%%f">>%temp%\stublistSDK.txt
)

:: Go back to root
popd

::echo.
::echo.
::echo.
::echo You Are Here: %cd%
::pause

cd obj

%rmff% FNIDS_temp

cls
echo.
echo.
echo Copying stub files to "%objTemp%\"....
echo.
echo.
copy /y "%PPU_LIB%\*_stub.a" "%objTemp%\"

for /f "delims=" %%s in ('dir /b /a-d-h-s') do (
%ar% x "%objTemp%\%%s"
)

::set stubs=%temp%\stublistRoot.txt
::for /f "tokens=1 delims=\" %%a in (%stubs%) do (
::    set /a stubs=!stubs! + 1
::    set var!stubs!=%%a
::	%ar% x s "%PPU_LIB%\%%a"
::)

:: Build list for copied object files
for /f "delims=" %%f in ('dir /b /a-d-h-s') do (
echo "%objTemp%\%%f">>%temp%\stublistRoot.txt
)


:cppFunc

cls
echo Creating CPPFUNC Arguments....
echo.
echo.
echo.

for /f "tokens=* delims=" %%i in ('type "%temp%\stublistRoot.txt"') do (
	set FUNC=%ppu-objdump% -D %i% | %sed% -f %scripts%\FUNC1.sed -f %scripts%\FUNC1a.sed | %grep% -A1 "^0000000000000000" | %grep% -B1 "^8" | %head% -n 1 | %cut% -b 18- | %sed% -f %scripts%\FUNC3.sed -f %scripts%\FUNC3.sed
)

echo "%FUNC%" | %sed% -f %scripts%\FUNC4.sed>>%temp%\cppfunc.txt

set /p CPPFUNC_args=<%temp%\cppfunc.txt

::pause

goto ppuObjDump


:ppuObjDump


::pause

::goto end

cls
echo Making Magic Happen....
echo.
echo.
echo.


for /f "tokens=* delims=" %%i in ('type "%temp%\stublistRoot.txt"') do (

  set FUNC=%ppu-objdump% -D %i% | %sed% -f %scripts%\FUNC1.sed -f %scripts%\FUNC1a.sed | %grep% -A1 "^0000000000000000" | %grep% -B1 "^8" | %head% -n 1 | %cut% -b 18- | %sed% -f %scripts%\FUNC3.sed -f %scripts%\FUNC3.sed
  set FNID=%ppu-objdump% -D %i% | %sed% -f %scripts%\FNID1.sed -f %scripts%\FNID1.sed | %grep% -A1 "^0000000000000000" | %grep% "^8" | %cut% -b 4-14 | %sed% -f %scripts%\FNID3.sed
  
  :: figure out where getting arg1 and arg2 from??
  set FNIDS=echo "%FUNC%@ 0x%FNID%" | %awk% -F@ "{%print% %argTwo%\"\t\"%argOne%}"
  
  if not "%FNID%"=="" (
	
	if not "%FNID%"==".psp_libgen_markvar" (
		
		set CPPFUNC=%ppu-cppfilt% %CPPFUNC_args%
		
		if "%FUNC%"=="%CPPFUNC%" (
		
			echo %i% | %sed% -f %scripts%\CPPFUNC1.sed | %awk% -F_ "{%print% %argOne%\"_\"%argTwo%}" | %sed% -f %scripts%\CPPFUNC2.sed -f %scripts%\CPPFUNC3.sed  %FNIDS% %CPPFUNC%" | %sed% -f %scripts%\CPPFUNC4.sed -f %scripts%\CPPFUNC5.sed -f %scripts%\CPPFUNC6.sed -f %scripts%\CPPFUNC7.sed >> FNIDS_temp
		
		) else (
		
			 echo %i% | %sed% -f %scripts%\CPPFUNC8.sed -f %scripts%\CPPFUNC9.sed | %awk% -F_ "{%print% %argOne%\"_\"%argTwo%}" | %sed% -f %scripts%\CPPFUNCA.sed -f %scripts%\CPPFUNCB.sed  %FNIDS%" | %sed% -f %scripts%\CPPFUNCC.sed -f %scripts%\CPPFUNCD.sed -f %scripts%\CPPFUNCE.sed -f %scripts%\CPPFUNCF.sed >> FNIDS_temp
		)
		
	)
  
  )
    
  set FNIDS=
  set FNID=
  
)

:: Come back to root
cd ..


cls
echo Doing Final Magic....
echo.
echo.
echo.


%mv% "obj\FNIDS_temp" "%root%"
%rmd% obj

%tclsh% ps3.tcl > FNIDS_xor
%sort% FNIDS_xor | %uniq% > FNIDS_xor2
%sort% FNIDS_temp | %uniq% > FNIDS_temp2
%rmf% FNIDS_temp

%diff% FNIDS_temp2 FNIDS_xor2  | %grep% -f %scripts%\FNIDSXOR1.grep | %sed% -f %scripts%\FNIDS.sed | %grep% -vf %scripts%\FNIDSXOR2.grep | %grep% -vf %scripts%\FNIDSXOR2.grep > FNIDS_temp3
%rmf% FNIDS_xor2

%cat% FNIDS_temp2 FNIDS_temp3 | %sort% | %uniq% > FNIDS
%rmf% FNIDS_temp2
%rmf% FNIDS_temp3


endlocal

:end

echo.
echo.
echo END!
pause>nul

