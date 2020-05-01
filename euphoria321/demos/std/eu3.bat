@ echo off

REM
REM Version 3.2.1.1: 2020/05/01; C A Newbould - revised for GitHub folder structure
REM Set the environment for this installation of Euphoria (v3.2.1)
REM The interpreter is RDS3.1.1
REM The installation is 32-bit
REM This is the "eu.cfg" equivalent for executing the demos relating to the std libraries
REM

ECHO Euphoria Version 3.2.1: Core RDS Euphoria Interpreter (32-bit) with "std" libraries

SET EUDIR=..\..\..\euphoria311
SET PATH=%EUDIR%\bin;%PATH%;..\..\dll;
SET EUINC=..\..\include

:: ECHO EUDIR = %EUDIR%
:: ECHO EUINC = %EUINC%
:: ECHO Command is %EUDIR%\bin\exw %1%

%EUDIR%\bin\exw %1
