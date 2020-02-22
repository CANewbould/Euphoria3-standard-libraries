@ echo off

REM
REM Set the environment for this installation of Euphoria
REM

SET EUDIR=\euphoria311
SET PATH=%EUDIR%\bin;%PATH%;\dll\32
SET EUINC=%EUDIR%\include\rds

%EUDIR%\bin\exw %1
