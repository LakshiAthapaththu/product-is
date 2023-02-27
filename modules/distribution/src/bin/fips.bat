

@echo off
rem ----------------------------------------------------------------------------
rem Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com).
rem
rem WSO2 LLC. licenses this file to you under the Apache License,
rem Version 2.0 (the "License"); you may not use this file except
rem in compliance with the License.
rem You may obtain a copy of the License at
rem
rem http://www.apache.org/licenses/LICENSE-2.0
rem
rem Unless required by applicable law or agreed to in writing,
rem software distributed under the License is distributed on an
rem "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
rem KIND, either express or implied.  See the License for the
rem specific language governing permissions and limitations
rem under the License.

set BC_FIPS_VERSION=1.0.2.3
set BCPKIX_FIPS_VERSION=1.0.7
set BCPROV_JDK15ON_VERSION=1.70.0.wso2v1
set BCPKIX_JDK15ON_VERSION=1.70.0.wso2v1

set EXPECTED_BCPROV_CHECKSUM=261f41c52b6a664a5e9011ba829e78eb314c0ed8
set EXPECTED_BCPKIX_CHECKSUM=17db4aba24861e306427bdeff03b1c2fac57760f
set EXPECTED_BC_FIPS_CHECKSUM=da62b32cb72591f5b4d322e6ab0ce7de3247b534
set EXPECTED_BCPKIX_FIPS_CHECKSUM=fe07959721cfa2156be9722ba20fdfee2b5441b0


rem ----- Only set CARBON_HOME if not already set ----------------------------
:checkServer
rem %~sdp0 is expanded pathname of the current script under NT with spaces in the path removed
if "%CARBON_HOME%"=="" set CARBON_HOME=%~sdp0..
SET curDrive=%cd:~0,1%
SET wsasDrive=%CARBON_HOME:~0,1%
if not "%curDrive%" == "%wsasDrive%" %wsasDrive%:

rem find CARBON_HOME if it does not exist due to either an invalid value passed
rem by the user or the %0 problem on Windows 9x
if not exist "%CARBON_HOME%\bin\version.txt" goto noServerHome

set ARGUEMENT=%1
set bundles_info=%CARBON_HOME%\repository\components\default\configuration\org.eclipse.equinox.simpleconfigurator\bundles.info
set bcprov_text=bcprov-jdk15on,%BCPROV_JDK15ON_VERSION%,../plugins/bcprov-jdk15on_%BCPROV_JDK15ON_VERSION%.jar,4,true
set bcpkix_text=bcpkix-jdk15on,%BCPKIX_JDK15ON_VERSION%,../plugins/bcpkix-jdk15on_%BCPKIX_JDK15ON_VERSION%.jar,4,true
set "homeDir=%userprofile%"
set server_restart_required=false

rem commandline arguement 'DISABLE' or 'disable' is passed
if "%ARGUEMENT%"=="DISABLE" goto disableFipsMode
if "%ARGUEMENT%"=="disable" goto disableFipsMode
if "%ARGUEMENT%"=="VERIFY" goto verifyFipsMode
if "%ARGUEMENT%"=="verify" goto verifyFipsMode
rem no commandline arguements are passed
goto enableFipsMode

:disableFipsMode
if exist "%CARBON_HOME%\repository\components\lib\bc-fips*.jar" (
    set server_restart_required=true
    echo Remove existing bc-fips jar from lib folder.
    DEL /F "%CARBON_HOME%\repository\components\lib\bc-fips*.jar"
    echo Successfully removed bc-fips__%BC_FIPS_VERSION%.jar from components\lib.
)
if exist "%CARBON_HOME%\repository\components\lib\bcpkix-fips*.jar" (
    set server_restart_required=true
    echo Remove existing bcpkix-fips jar from lib folder.
    DEL /F "%CARBON_HOME%\repository\components\lib\bcpkix-fips*.jar"
    echo Successfully removed bcpkix-fips_%BC_FIPS_VERSION%.jar from components\lib.
)
if exist "%CARBON_HOME%\repository\components\dropins\bc_fips*.jar" (
    set server_restart_required=true
    echo Remove existing bc-fips jar from dropins folder.
    DEL /F "%CARBON_HOME%\repository\components\dropins\bc_fips*.jar"
    echo Successfully removed bc_fips_%BC_FIPS_VERSION%.jar from components\dropins.
)
if exist "%CARBON_HOME%\repository\components\dropins\bcpkix_fips*.jar" (
    set server_restart_required=true
    echo Remove existing bcpkix_fips jar from dropins folder.
    DEL /F "%CARBON_HOME%\repository\components\dropins\bcpkix_fips*.jar"
    echo Successfully removed bcpkix-fips_%BCPKIX_FIPS_VERSION%.jar from components\dropins.
)
if not exist "%CARBON_HOME%\repository\components\plugins\bcprov-jdk15on*.jar" (
    set server_restart_required=true
    if exist "%homeDir%\.wso2-bc\backup\bcprov-jdk15on_%BCPROV_JDK15ON_VERSION%.jar" (
        move "%homeDir%\.wso2-bc\backup\bcprov-jdk15on_%BCPROV_JDK15ON_VERSION%.jar" "%CARBON_HOME%\repository\components\plugins"
        echo Moved bcprov-jdk15on_%BCPROV_JDK15ON_VERSION%.jar from %homeDir%\.wso2-bc\backup to components/plugins.
    ) else (
        echo Downloading required bcprov-jdk15on jar : bcprov-jdk15on-%BCPROV_JDK15ON_VERSION%
	    curl https://maven.wso2.org/nexus/content/repositories/releases/org/wso2/orbit/org/bouncycastle/bcprov-jdk15on/%BCPROV_JDK15ON_VERSION%/bcprov-jdk15on-%BCPROV_JDK15ON_VERSION%.jar -o %CARBON_HOME%/repository/components/plugins/bcprov-jdk15on_%BCPROV_JDK15ON_VERSION%.jar
        FOR /F "tokens=*" %%G IN ('certutil -hashfile "%CARBON_HOME%/repository/components/plugins/bcprov-jdk15on_%BCPROV_JDK15ON_VERSION%.jar" SHA1 ^| FIND /V ":"') DO SET "ACTUAL_CHECKSUM_BCPROVE=%%G"
        if "%ACTUAL_CHECKSUM_BCPROVE%"=="%EXPECTED_BCPROV_CHECKSUM%" (
            echo Checksum verified: The downloaded bcprov-jdk15on-%BCPROV_JDK15ON_VERSION%.jar is valid.
        ) else (
            echo Checksum verification failed: The downloaded bcprov-jdk15on-%BCPROV_JDK15ON_VERSION%.jar may be corrupted.
        )
    )
)
if not exist "%CARBON_HOME%\repository\components\plugins\bcpkix-jdk15on*.jar" (
    set server_restart_required=true
    if exist "%homeDir%\.wso2-bc\backup\bcpkix-jdk15on_%BCPKIX_JDK15ON_VERSION%.jar" (
        move "%homeDir%\.wso2-bc\backup\bcpkix-jdk15on_%BCPKIX_JDK15ON_VERSION%.jar" "%CARBON_HOME%\repository\components\plugins"
        echo Moved bcpkix-jdk15on_%BCPKIX_JDK15ON_VERSION%.jar from %homeDir%\.wso2-bc\backup to components/plugins.
    ) else (
	    echo Downloading required bcpkix-jdk15on jar : bcpkix-jdk15on-%BCPKIX_JDK15ON_VERSION%
	    curl https://maven.wso2.org/nexus/content/repositories/releases/org/wso2/orbit/org/bouncycastle/bcpkix-jdk15on/%BCPKIX_JDK15ON_VERSION%/bcpkix-jdk15on-%BCPKIX_JDK15ON_VERSION%.jar -o %CARBON_HOME%/repository/components/plugins/bcpkix-jdk15on_%BCPKIX_JDK15ON_VERSION%.jar
        FOR /F "tokens=*" %%G IN ('certutil -hashfile "%CARBON_HOME%/repository/components/plugins/bcpkix-jdk15on_%BCPKIX_JDK15ON_VERSION%.jar" SHA1 ^| FIND /V ":"') DO SET "ACTUAL_CHECKSUM_BCPKIX=%%G"
        if "%ACTUAL_CHECKSUM_BCPKIX%"=="%EXPECTED_BCPKIX_CHECKSUM%" (
            echo Checksum verified: The downloaded bcpkix-jdk15on-%BCPKIX_JDK15ON_VERSION%.jar is valid.
        ) else (
            echo Checksum verification failed: The downloaded bcpkix-jdk15on-%BCPKIX_JDK15ON_VERSION%.jar may be corrupted.
        )
    )
)
findstr /c:%bcprov_text% %bundles_info% > nul
if %errorlevel%==1 (
    set server_restart_required=true
    echo %bcprov_text% >>  %bundles_info%
)
findstr /c:%bcpkix_text% %bundles_info% > nul
if %errorlevel%==1 (
    set server_restart_required=true
    echo %bcpkix_text% >>  %bundles_info%
)
goto printRestartMsg

: enableFipsMode
set arg1=
set arg2=
:parse_args
if "%~1" == "" goto :done_args
if /I "%~1" == "-f" set "arg1=%~2" & shift
if /I "%~1" == "-m" set "arg2=%~2" & shift
shift
goto :parse_args
:done_args

if not exist "%homeDir%\.wso2-bc" (
    mkdir "%homeDir%\.wso2-bc"
)
if not exist "%homeDir%\.wso2-bc\backup" (
    mkdir "%homeDir%\.wso2-bc\backup"
)
if exist "%CARBON_HOME%\repository\components\plugins\bcprov-jdk15on*" (
    set server_restart_required=true
    echo Remove existing bcprov-jdk15on jar from plugins folder.
    for /f "delims=" %%a in ('dir /b /s "%CARBON_HOME%\repository\components\plugins\bcprov-jdk15on_*.jar"') do (
        set bcprov_location=%%a
        goto check_bcprov_location
    )
   :check_bcprov_location
    move "%bcprov_location%" "%homeDir%\.wso2-bc\backup"
    echo Successfully removed bcprov-jdk15on_%BCPROV_JDK15ON_VERSION%.jar from components\plugins.
)
if exist "%CARBON_HOME%\repository\components\plugins\bcpkix-jdk15on*" (
    set server_restart_required=true
    echo Remove existing bcpkix-jdk15on jar from plugins folder.
    for /f "delims=" %%a in ('dir /b /s "%CARBON_HOME%\repository\components\plugins\bcpkix-jdk15on_*.jar"') do (
        set bcpkix_location=%%a
        goto check_bcpkix_location

    )
   :check_bcpkix_location
    move "%bcpkix_location%" "%homeDir%\.wso2-bc\backup"
    echo Successfully removed bcpkix-jdk15on_%BCPKIX_JDK15ON_VERSION%.jar Removed from components\plugins.
)
if exist "%CARBON_HOME%\repository\components\lib\bc-fips*.jar" (
    for /f "delims=" %%a in ('dir /b /s "%CARBON_HOME%\repository\components\lib\bc-fips*.jar"') do (
        set bcfips_location=%%a
        goto check_bcfips_location
    )
    :check_bcfips_location
    for %%f in ("%bcfips_location%") do set "bcfips_location=%%~nxf"
    if not "%bcfips_location%"=="bc-fips-%BC_FIPS_VERSION%.jar" (
        set sever_restart_required=true
        echo There is an update for bc-fips. Therefore Remove existing bc-fips jar from lib folder.
        del /q "%CARBON_HOME%\repository\components\lib\bc-fips*.jar" 2> nul
        echo Successfully removed bc-fips_%BC_FIPS_VERSION%.jar from components/lib.
        if exist "%CARBON_HOME%\repository\components\dropins\bc_fips*.jar" (
            set sever_restart_required=true
            echo Remove existing bc-fips jar from dropins folder.
            del /q "%CARBON_HOME%\repository\components\dropins\bc_fips*.jar" 2> nul
            echo Successfully removed bc-fips_%BC_FIPS_VERSION%.jar from components/dropins.
        )
    )
)

if exist "%CARBON_HOME%\repository\components\lib\bcpkix-fips*.jar" (
    for /f "delims=" %%a in ('dir /b /s "%CARBON_HOME%\repository\components\lib\bcpkix-fips*.jar"') do (
        set bcpkixfips_location=%%a
        goto check_bcpkixfips_location
    )
    :check_bcpkixfips_location
    for %%f in ("%bcpkixfips_location%") do set "bcpkixfips_location=%%~nxf"
    if not "%bcpkixfips_location%"=="bcpkix-fips-%BCPKIX_FIPS_VERSION%.jar" (
        set sever_restart_required=true
        echo There is an update for bcpkix-fips. Therefore Remove existing bcpkix-fips jar from lib folder.
        del /q "%CARBON_HOME%\repository\components\lib\bcpkix-fips*.jar" 2> nul
        echo Successfully removed bcpkix-fips_%BCPKIX_FIPS_VERSION%.jar from components/lib.
        if exist "%CARBON_HOME%\repository\components\dropins\bcpkix_fips*.jar" (
            set sever_restart_required=true
            echo Remove existing bcpkix-fips jar from dropins folder.
            del /q "%CARBON_HOME%\repository\components\dropins\bcpkix_fips*.jar" 2> nul
            echo Successfully removed bcpkix-fips_%BCPKIX_FIPS_VERSION%.jar from components/dropins.
        )
    )
)

if not exist "%CARBON_HOME%\repository\components\lib\bc-fips*.jar" (
    set server_restart_required=true
	if not "%arg1%"=="" (
	    if not exist "%arg1%\bc-fips-%BC_FIPS_VERSION%.jar" (
	    	echo Can not be found requried bc-fips-%BC_FIPS_VERSION%.jar in given file path : "%arg1%".
	    ) else (
		    copy "%arg1%\bc-fips-%BC_FIPS_VERSION%.jar" "%CARBON_HOME%\repository\components\lib\"
            if %errorlevel% equ 0 (
                echo bc-fips JAR file copied successfully.
            ) else (
                echo Error copying bc-fips JAR file.
            )
    )
	)
	if not "%arg2%"=="" if "%arg1%"=="" (
        echo Downloading required bc-fips jar : bc-fips-%BC_FIPS_VERSION%
	    curl %arg2%/org/bouncycastle/bc-fips/%BC_FIPS_VERSION%/bc-fips-%BC_FIPS_VERSION%.jar -o %CARBON_HOME%/repository/components/lib/bc-fips-%BC_FIPS_VERSION%.jar
        FOR /F "tokens=*" %%G IN ('certutil -hashfile "%CARBON_HOME%\repository\components\lib\bc-fips-%BC_FIPS_VERSION%.jar" SHA1 ^| FIND /V ":"') DO SET "ACTUAL_CHECKSUM_BC_FIPS=%%G"
        if "%ACTUAL_CHECKSUM_BC_FIPS%"=="%EXPECTED_BC_FIPS_CHECKSUM%" (
            echo Checksum verified: The downloaded bc-fips-%BC_FIPS_VERSION%.jar is valid.
        ) else (
            echo Checksum verification failed: The downloaded bc-fips-%BC_FIPS_VERSION%.jar may be corrupted.
        )
	)
	if "%arg1%"=="" if "%arg2%"=="" (
	    echo Downloading required bc-fips jar : bc-fips-%BC_FIPS_VERSION%
	    curl https://repo1.maven.org/maven2/org/bouncycastle/bc-fips/%BC_FIPS_VERSION%/bc-fips-%BC_FIPS_VERSION%.jar -o %CARBON_HOME%/repository/components/lib/bc-fips-%BC_FIPS_VERSION%.jar
        FOR /F "tokens=*" %%G IN ('certutil -hashfile "%CARBON_HOME%\repository\components\lib\bc-fips-%BC_FIPS_VERSION%.jar" SHA1 ^| FIND /V ":"') DO SET "ACTUAL_CHECKSUM_BC_FIPS=%%G"
        if "%ACTUAL_CHECKSUM_BC_FIPS%"=="%EXPECTED_BC_FIPS_CHECKSUM%" (
            echo Checksum verified: The downloaded bc-fips-%BC_FIPS_VERSION%.jar is valid.
        ) else (
            echo Checksum verification failed: The downloaded bc-fips-%BC_FIPS_VERSION%.jar may be corrupted.
        )
    )
)

if not exist "%CARBON_HOME%\repository\components\lib\bcpkix-fips*.jar" (
    set server_restart_required=true
	if not "%arg1%"=="" (
	if not exist "%arg1%\bcpkix-fips-%BCPKIX_FIPS_VERSION%.jar" (
		echo Can not be found requried bcpkix-fips-%BCPKIX_FIPS_VERSION%.jar in given file path : "%arg1%".
	) else (
        copy "%arg1%\bcpkix-fips-%BCPKIX_FIPS_VERSION%.jar" "%CARBON_HOME%\repository\components\lib\"
        if %errorlevel% equ 0 (
            echo bcpkix-fips JAR file copied successfully.
        ) else (
            echo Error copying bcpkix-fips JAR file.
        )
	)
	)
	if not "%arg2%"=="" if "%arg1%"=="" (
        echo Downloading required bcpkix-fips jar : bcpkix-fips-%BCPKIX_FIPS_VERSION%
	    curl %arg2%/org/bouncycastle/bcpkix-fips/%BCPKIX_FIPS_VERSION%/bcpkix-fips-%BCPKIX_FIPS_VERSION%.jar -o %CARBON_HOME%/repository/components/lib/bcpkix-fips-%BCPKIX_FIPS_VERSION%.jar
        FOR /F "tokens=*" %%G IN ('certutil -hashfile "%CARBON_HOME%\repository\components\lib\bcpkix-fips-%BCPKIX_FIPS_VERSION%.jar" SHA1 ^| FIND /V ":"') DO SET "ACTUAL_CHECKSUM_BCPKIX_FIPS=%%G"
        if "%ACTUAL_CHECKSUM_BCPKIX_FIPS%"=="%EXPECTED_BCPKIX_FIPS_CHECKSUM%" (
            echo Checksum verified: The downloaded bcpkix-%BCPKIX_FIPS_VERSION%.jar is valid.
        ) else (
            echo Checksum verification failed: The downloaded bcpkix-%BCPKIX_FIPS_VERSION%.jar may be corrupted.
        )
	)
	if "%arg1%"=="" if "%arg2%"=="" (
	    echo Downloading required bcpkix-fips jar : bcpkix-fips-%BCPKIX_FIPS_VERSION%
	    curl https://repo1.maven.org/maven2/org/bouncycastle/bcpkix-fips/%BCPKIX_FIPS_VERSION%/bcpkix-fips-%BCPKIX_FIPS_VERSION%.jar -o %CARBON_HOME%/repository/components/lib/bcpkix-fips-%BCPKIX_FIPS_VERSION%.jar
        FOR /F "tokens=*" %%G IN ('certutil -hashfile "%CARBON_HOME%\repository\components\lib\bcpkix-fips-%BCPKIX_FIPS_VERSION%.jar" SHA1 ^| FIND /V ":"') DO SET "ACTUAL_CHECKSUM_BCPKIX_FIPS=%%G"
        if "%ACTUAL_CHECKSUM_BCPKIX_FIPS%"=="%EXPECTED_BCPKIX_FIPS_CHECKSUM%" (
            echo Checksum verified: The downloaded bcpkix-fips-%BCPKIX_FIPS_VERSION%.jar is valid.
        ) else (
            echo Checksum verification failed: The downloaded bcpkix-fips-%BCPKIX_FIPS_VERSION%.jar may be corrupted.
        )
    )
)
set temp_file=%CARBON_HOME%\repository\components\default\configuration\org.eclipse.equinox.simpleconfigurator\temp.info
findstr /v /c:%bcprov_text% /c:%bcpkix_text% %bundles_info% > !temp_file!
move /y !temp_file! %bundles_info% > nul
goto printRestartMsg

:verifyFipsMode
set verify=true
if exist "%CARBON_HOME%\repository\components\plugins\bcprov-jdk15on*.jar" (
	set location=
	for /f "delims=" %%i in ('dir /b /s "%CARBON_HOME%\repository\components\plugins\bcprov-jdk15on*.jar" ^| findstr /i /c:".jar"') do (
		set "location=%%i"
		goto :verifyBcFipsLocation
	)
	:verifyBcFipsLocation
	if not "%location%"=="" (
		set verify=false
		echo Found bcprov-jdk15on_%BCPROV_JDK15ON_VERSION%.jar in plugins folder. This jar should be removed.
	)
)
if exist "%CARBON_HOME%\repository\components\plugins\bcpkix-jdk15on*.jar" (
	set location=
	for /f "delims=" %%i in ('dir /b /s "%CARBON_HOME%\repository\components\plugins\bcpkix-jdk15on*.jar" ^| findstr /i /c:".jar"') do (
		set "location=%%i"
		goto :verifyBcPkixFipsLocation
	)
	:verifyBcPkixFipsLocation
	if not "%location%"=="" (
		set verify=false
		echo Found bcpkix-jdk15on_%BCPKIX_JDK15ON_VERSION%.jar in plugins folder. This jar should be removed.
	)
)
if exist "%CARBON_HOME%\repository\components\lib\bc-fips*.jar" (
	if not exist "%CARBON_HOME%\repository\components\lib\bc-fips-%BC_FIPS_VERSION%.jar" (
		set verify=false
		echo There is an update for bc-fips. Run the script again to get updates.
    )
)  else (
    set verify=false
    echo can not be found bc-fips_%BC_FIPS_VERSION%.jar in components/lib folder. This jar should be added.
)

if exist "%CARBON_HOME%\repository\components\lib\bcpkix-fips*.jar" (
	if not exist "%CARBON_HOME%\repository\components\lib\bcpkix-fips-%BCPKIX_FIPS_VERSION%.jar" (
		set verify=false
		echo There is an update for bcpkix-fips. Run the script again to get updates.
    )
) else (
    set verify=false
    echo can not be found bc-fips_%BC_FIPS_VERSION%.jar in components/lib folder. This jar should be added.
)

findstr /i /c:"%bcprov_text%" "%bundles_info%" >nul
if %errorlevel%==0 (
	set verify=false
	echo Found text "%bcprov_text%" in bundles.info. This should be removed.
)

findstr /i /c:"%bcpkix_text%" "%bundles_info%" >nul
if %errorlevel%==0 (
	set verify=false
	echo Found text "%bcpkix_text%" in bundles.info. This should be removed.
)
if "%verify%"=="true" (
	echo Verified : Product is FIPS compliant.
) else (
	echo Verification failed : Product is not FIPS compliant.
)
goto end

:printRestartMsg
if "%server_restart_required%"=="true" (
    echo Please restart the server.
)

goto end

:noServerHome
echo CARBON_HOME is set incorrectly or CARBON could not be located. Please set CARBON_HOME.
goto end

:end
endlocal
