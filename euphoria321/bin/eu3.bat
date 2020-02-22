@ echo off

REM
REM Set the environment for this installation of Euphoria (v3.1.2)
REM The interpreter is RDS3.1.1
REM The installation is 32-bit
REM

SET EUDIR=\euphoria311
SET PATH=%EUDIR%\bin;%PATH%;\dll\32
SET EUINC=\euphoria312\include

%EUDIR%\bin\exw %1
