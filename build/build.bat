:### setup
call build_configuration.bat

echo JAVA_HOME is %JAVA_HOME%
echo SERVLET_API_CP is %SERVLET_API_CP%
echo SOURCE_DIR is %SOURCE_DIR%
echo TARGET_DIR is %TARGET_DIR%
echo TARGET_DIR_DRIVE is %TARGET_DIR_DRIVE%

:### delete any build previously created in TARGET_DIR & recreate folder structure
del /s /q %TARGET_DIR%\wu.war
rmdir /s /q %TARGET_DIR%\wu_war
mkdir %TARGET_DIR%\wu_war\WEB-INF\classes
mkdir %TARGET_DIR%\wu_war\WEB-INF\lib

:### copy webapp
XCOPY /sy %SOURCE_DIR%\jsp %TARGET_DIR%\wu_war

set SOURCELIB=%SOURCE_DIR%\thirdparty
COPY %SOURCELIB%\*.jar %TARGET_DIR%\wu_war\WEB-INF\lib

:### setup classpath

set WU_CP=%SERVLET_API_CP%;%SOURCELIB%\httpclient-4.1.2.jar;%SOURCELIB%\openid4java-0.9.6.jar;%SOURCELIB%\guice-2.0.jar;%SOURCELIB%\purple.jar;%SOURCELIB%\jsoup-1.11.3.jar

:### compile java classes
"%JAVA_HOME%/bin/javac" -classpath "%WU_CP%" -source 1.6 -target 1.6 -d %TARGET_DIR%\wu_war\WEB-INF\classes %SOURCE_DIR%\src\org\workcast\wu\*.java

if errorlevel 1 goto EXIT

echo Compile successful

:### build nugen.war
%TARGET_DIR_DRIVE%
pushd %TARGET_DIR%\wu_war\WEB-INF\classes

del %TARGET_DIR%\webutil.jar
"%JAVA_HOME%/bin/jar" -cvfM %TARGET_DIR%\webutil.jar *

cd ..\..

del %TARGET_DIR%\wu.war
"%JAVA_HOME%/bin/jar" -cvfM %TARGET_DIR%\wu.war *
if errorlevel 1 exit /b

echo wu.war created successfully at %TARGET_DIR%

:### restore starting directory
popd

:EXIT
pause
