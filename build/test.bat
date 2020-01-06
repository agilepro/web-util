
call build_configuration.bat

:##################################################################################
:##### Setup classpath
:##################################################################################

set MENDO_CP=%TARGET_DIR%\wu_war\WEB-INF\classes\;%TARGET_DIR%\wu_war\WEB-INF\lib\purple.jar

:##################################################################################
:##### Run tests
:##################################################################################
"%JAVA_HOME%/bin/java" -classpath %MENDO_CP% com.purplehillsbooks.ohioscan.NameScanner

pause
