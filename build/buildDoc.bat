:### setup
call build_configuration.bat

echo JAVA_HOME is %JAVA_HOME%
echo SERVLET_API_CP is %SERVLET_API_CP%
echo SOURCE_DIR is %SOURCE_DIR%
echo TARGET_DIR is %TARGET_DIR%
echo TARGET_DIR_DRIVE is %TARGET_DIR_DRIVE%

:### setup classpath

set WU_CP=%SERVLET_API_CP%

:### compile java classes
"%JAVA_HOME%/bin/javadoc" -classpath "%WU_CP%;%SOURCE_DIR%\thirdparty\mendo.jar" -d %TARGET_DIR%\wu_war\javadoc %SOURCE_DIR%\src\org\workcast\wu\*.java

if errorlevel 1 goto EXIT

echo Compile successful

:### build nugen.war
%TARGET_DIR_DRIVE%
pushd %TARGET_DIR%\wu_war
del %TARGET_DIR%\wu.war
"%JAVA_HOME%/bin/jar" -cvfM %TARGET_DIR%\wu.war *
if errorlevel 1 exit /b

echo wu.war created successfully at %TARGET_DIR%

:### restore starting directory
popd

:EXIT
pause
