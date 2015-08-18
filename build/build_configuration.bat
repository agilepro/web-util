:#####################################################################################################
:#
:# Java home
:#
:#####################################################################################################
set "JAVA_HOME=c:\Program Files\Java\jdk1.7.0_51_x64\"

:#####################################################################################################
:#
:# Path to jar file containing javax.servlet.* classes
:#
:# e.g.: 
:# For Tomcat 4.1
:# set SERVLET_API_CP="D:\Program Files\Apache Software Foundation\Tomcat 4.1\common\lib\servlet.jar"
:#
:# For Tomcat 5.5
:# set SERVLET_API_CP="D:\Program Files\Apache_Tomcat_5_5\common\lib\servlet-api.jar"
:#
:#####################################################################################################
set "CATALINA_HOME=c:\ApacheTomcat7\"

set "SERVLET_API_CP=%CATALINA_HOME%\lib\servlet-api.jar;%CATALINA_HOME%\lib\jsp-api.jar"

:#####################################################################################################
:#
:# Path to nugen source directory.
:#
:#####################################################################################################
set SOURCE_DIR=c:\GoogleSvn\WebUtil\

:#####################################################################################################
:#
:# Path to build directory. nugen.war will be created here.
:# TARGET_DIR_DRIVE should have the drive letter of TARGET_DIR - a kludge till we have a smarter script
:#
:#####################################################################################################
set TARGET_DIR=c:\GoogleBuild\wu\
set TARGET_DIR_DRIVE=C:

:#####################################################################################################
:#
:# NOW test that these settings are correct, test that the folders exist
:# and warn if they do not.  No user settings below here
:#
:#####################################################################################################

IF EXIST "%JAVA_HOME%" goto step2

echo off
echo ************************************************************
echo The Java home folder (%JAVA_HOME%) does not exist.
echo please change JAVA_HOME to a valid folder where Java is installed
echo ************************************************************
pause
echo on
goto exit1

:step2
IF EXIST "%SOURCE_DIR%" goto step3

echo off
echo ************************************************************
echo The source folder (%SOURCE_DIR%) does not exist.
echo please change SOURCE_DIR to a valid folder where source is to be read from
echo ************************************************************
pause
echo on
goto exit1

:step3
IF EXIST "%TARGET_DIR%" goto step4

echo off
echo ************************************************************
echo The build target folder (%TARGET_DIR%) does not exist.
echo please change TARGET_DIR to a valid folder where output is to go
echo ************************************************************
pause
echo on
goto exit1

:step4
IF EXIST "%CATALINA_HOME%" goto step5

echo off
echo ************************************************************
echo The Catalina home folder (%CATALINA_HOME%) does not exist.
echo please change CATALINA_HOME to a valid folder where Apache Tomcat is installed
echo ************************************************************
pause
echo on
goto exit1

:step5


:exit1