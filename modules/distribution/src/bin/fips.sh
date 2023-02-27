#! /bin/bash
# ----------------------------------------------------------------------------
#  Copyright 2023 WSO2, LLC. http://www.wso2.org
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

BC_FIPS_VERSION=1.0.2.3;
BCPKIX_FIPS_VERSION=1.0.7;
BCPROV_JDK15ON_VERSION=1.70.0.wso2v1;
BCPKIX_JDK15ON_VERSION=1.70.0.wso2v1;

EXPECTED_BCPROV_CHECKSUM="261f41c52b6a664a5e9011ba829e78eb314c0ed8"
EXPECTED_BCPKIX_CHECKSUM="17db4aba24861e306427bdeff03b1c2fac57760f"
EXPECTED_BC_FIPS_CHECKSUM="da62b32cb72591f5b4d322e6ab0ce7de3247b534"
EXPECTED_BCPKIX_FIPS_CHECKSUM="fe07959721cfa2156be9722ba20fdfee2b5441b0"

# Get standard environment variables
PRGDIR=`dirname "$PRG"`

# Only set CARBON_HOME if not already set
[ -z "$CARBON_HOME" ] && CARBON_HOME=`cd "$PRGDIR/.." ; pwd`

ARGUMENT=$1;
bundles_info="$CARBON_HOME/repository/components/default/configuration/org.eclipse.equinox.simpleconfigurator/bundles.info";
bcprov_text="bcprov-jdk15on1,$BCPKIX_JDK15ON_VERSION,../plugins/bcprov-jdk15on_$BCPKIX_JDK15ON_VERSION.jar,4,true";
bcpkix_text="bcpkix-jdk15on1,$BCPROV_JDK15ON_VERSION,../plugins/bcpkix-jdk15on_$BCPROV_JDK15ON_VERSION.jar,4,true";
homeDir="$HOME"
sever_restart_required=false

if [ "$ARGUMENT" = "DISABLE" ] || [ "$ARGUMENT" = "disable" ]; then
    if [ -f $CARBON_HOME/repository/components/lib/bc-fips*.jar ]; then
	    sever_restart_required=true
   		echo "Remove existing bc-fips jar from lib folder."
   		rm rm $CARBON_HOME/repository/components/lib/bc-fips*.jar 2> /dev/null
		echo "Successfully removed bc-fips_$BC_FIPS_VERSION.jar Removed from component/lib."
   	fi
   	if [ -f $CARBON_HOME/repository/components/lib/bcpkix-fips*.jar ]; then
   	    sever_restart_required=true
   		echo "Remove existing bcpkix-fips jar from lib folder."
   		rm rm $CARBON_HOME/repository/components/lib/bcpkix-fips*.jar 2> /dev/null
   		echo "Successfully removed bcpkix-fips_$BCPKIX_JDK15ON_VERSION.jar  from component/lib."
   	fi
   	if [ -f $CARBON_HOME/repository/components/dropins/bc_fips*.jar ]; then
   	    sever_restart_required=true
   		echo "Remove existing bc-fips jar from dropins folder."
   		rm rm $CARBON_HOME/repository/components/dropins/bc_fips*.jar 2> /dev/null
   		echo "Successfully removed bc-fips_$BC_FIPS_VERSION.jar from component/dropins."
   	fi
   	if [ -f $CARBON_HOME/repository/components/dropins/bcpkix_fips*.jar ]; then
   	    sever_restart_required=true
   		echo "Remove existing bcpkix_fips jar from dropins folder."
   		rm rm $CARBON_HOME/repository/components/dropins/bcpkix_fips*.jar 2> /dev/null
		echo "Successfully removed bcpkix_fips_$BCPKIX_JDK15ON_VERSION.jar from component/dropins."
   	fi
	if [ ! -e $CARBON_HOME/repository/components/plugins/bcprov-jdk15on*.jar ]; then
	    sever_restart_required=true
	    if [ -f "$homeDir/.wso2-bc/backup/bcprov-jdk15on_$BCPROV_JDK15ON_VERSION.jar" ]; then
		    mv "$homeDir/.wso2-bc/backup/bcprov-jdk15on_$BCPROV_JDK15ON_VERSION.jar" "$CARBON_HOME/repository/components/plugins"
		    echo "Moved bcprov-jdk15on_$BCPROV_JDK15ON_VERSION.jar from $homeDir/.wso2-bc/backup to components/plugins"
	    else
		    echo "Downloading required bcprov-jdk15on jar : bcprov-jdk15on-$BCPROV_JDK15ON_VERSION"
		    curl https://maven.wso2.org/nexus/content/repositories/releases/org/wso2/orbit/org/bouncycastle/bcprov-jdk15on/$BCPROV_JDK15ON_VERSION/bcprov-jdk15on-$BCPROV_JDK15ON_VERSION.jar -o $CARBON_HOME/repository/components/plugins/bcprov-jdk15on_$BCPROV_JDK15ON_VERSION.jar
	        ACTUAL_CHECKSUM=$(sha1sum $CARBON_HOME/repository/components/plugins/bcprov-jdk15on*.jar | cut -d' ' -f1)
	        if [ "$EXPECTED_BCPROV_CHECKSUM" = "$ACTUAL_CHECKSUM" ]; then
  		        echo "Checksum verified: The downloaded bcprov-jdk15on-$BCPROV_JDK15ON_VERSION.jar is valid."
	        else
  		        echo "Checksum verification failed: The downloaded bcprov-jdk15on-$BCPROV_JDK15ON_VERSION.jar may be corrupted."
	        fi
	    fi
	fi
	if [ ! -e $CARBON_HOME/repository/components/plugins/bcpkix-jdk15on*.jar ]; then
	    sever_restart_required=true
	    if [ -f "$homeDir/.wso2-bc/backup/bcpkix-jdk15on_$BCPKIX_JDK15ON_VERSION.jar" ]; then
		    mv "$homeDir/.wso2-bc/backup/bcpkix-jdk15on_$BCPKIX_JDK15ON_VERSION.jar" "$CARBON_HOME/repository/components/plugins"
		    echo "Moved bcpkix-jdk15on_$BCKIX_JDK15ON_VERSION.jar from $homeDir/.wso2-bc/backup to components/plugins"

	    else
		    echo "Downloading required bcpkix-jdk15on jar : bcplix-jdk15on-$BCPKIX_JDK15ON_VERSION"
		    curl https://maven.wso2.org/nexus/content/repositories/releases/org/wso2/orbit/org/bouncycastle/bcpkix-jdk15on/$BCPKIX_JDK15ON_VERSION/bcpkix-jdk15on-$BCPKIX_JDK15ON_VERSION.jar -o $CARBON_HOME/repository/components/plugins/bcpkix-jdk15on_$BCPKIX_JDK15ON_VERSION.jar
	        ACTUAL_CHECKSUM=$(sha1sum $CARBON_HOME/repository/components/plugins/bcpkix-jdk15on*.jar | cut -d' ' -f1)
	        if [ "$EXPECTED_BCPKIX_CHECKSUM" = "$ACTUAL_CHECKSUM" ]; then
  		        echo "Checksum verified: The downloaded bcpkix-jdk15on-$BCPKIX_JDK15ON_VERSION.jar is valid."
	        else
  		        echo "Checksum verification failed: The downloaded bcpkix-jdk15on-$BCPKIX_JDK15ON_VERSION.jar may be corrupted."
	        fi
	    fi
	fi

	if ! grep -q "$bcprov_text" "$bundles_info" ; then
		echo  $bcprov_text >> $bundles_info;
		sever_restart_required=true
	fi
	if ! grep -q "$bcpkix_text" "$bundles_info" ; then
		echo  $bcpkix_text >> $bundles_info;
		sever_restart_required=true
	fi

elif [ "$ARGUMENT" = "VERIFY" ] || [ "$ARGUMENT" = "verify" ]; then
	verify=true;
	if [ -f $CARBON_HOME/repository/components/plugins/bcprov-jdk15on*.jar ]; then
		location=$(find "$CARBON_HOME/repository/components/plugins/" -type f -name "bcprov-jdk15on*.jar" | head -1)
		verify=false
		echo "Found bcprov-jdk15on_$BCPROV_JDK15ON_VERSION.jar in plugins folder. This jar should be removed."
	fi
	if [ -f $CARBON_HOME/repository/components/plugins/bcprov-jdk15on*.jar ]; then
		location=$(find "$CARBON_HOME/repository/components/plugins/" -type f -name "bcpkix-jdk15on*.jar" | head -1)
		verify=false
		echo "Found bcpkix-jdk15on_$BCPKIX_JDK15ON_VERSION.jar in plugins folder. This jar should be removed."
	fi
	if [ -f $CARBON_HOME/repository/components/lib/bc-fips*.jar ]; then
	    if [ ! -f $CARBON_HOME/repository/components/lib/bc-fips-$BC_FIPS_VERSION.jar ]; then
			verify=false
			echo "There is an update for bc-fips. Run the script again to get updates."
		fi
	else
		verify=false
		echo "Can not be found bc-fips_$BC_FIPS_VERSION.jar in components/lib folder. This jar should be added."
	fi
	if [ -f $CARBON_HOME/repository/components/lib/bcpkix-fips*.jar ]; then
	    if [ ! -f $CARBON_HOME/repository/components/lib/bcpkix-fips-$BCPKIX_FIPS_VERSION.jar ]; then
	    	verify=false
	    	echo "There is an update for bcpkix-fips. Run the script again to get updates."

		fi
	else
		verify=false
		echo "Can not be found bcpkix-fips_$BCPKIX_FIPS_VERSION.jar in components/lib folder. This jar should be added."

	fi
	if grep -q "$bcprov_text" "$bundles_info" ; then
		verify=false
		echo  "Found $bcprov_text in bundles.info. This should be removed";

	fi
	if grep -q "$bcpkix_text" "$bundles_info" ; then
		verify=false
		echo  "Found $bcpkix_text in bundles.info. This should be removed";
	fi

	if [ $verify = true ]; then
		echo "Verified : Product is FIPS compliant."
	else 	echo "Verification failed : Product is not FIPS compliant."
	fi

else
while getopts "f:m:" opt; do
  	case $opt in
    	f)
    		arg1=$OPTARG
      		;;
    	m)
      		arg2=$OPTARG
      		;;
    	\?)
      	echo "Invalid option: -$OPTARG" >&2
      	exit 1
      	;;
  	esac
	done
	echo "arg1: $arg1"
	echo "arg2: $arg2"


	if [ ! -d "$homeDir/.wso2-bc" ]; then
    		mkdir "$homeDir/.wso2-bc"
	fi
	if [ ! -d "$homeDir/.wso2-bc/backup" ]; then
    		mkdir "$homeDir/.wso2-bc/backup"
	fi
	if [ -f $CARBON_HOME/repository/components/plugins/bcprov-jdk15on*.jar ]; then
	    sever_restart_required=true
	    location=$(find "$CARBON_HOME/repository/components/plugins/" -type f -name "bcprov-jdk15on*.jar" | head -1)
	    echo "Remove existing bcpkix-jdk15on jar from plugins folder."
	    mv "$location" "$homeDir/.wso2-bc/backup"
   	    echo "Successfully removed bcprov-jdk15on_$BCPROV_JDK15ON_VERSION.jar from component/plugins."
	fi
	if [ -f $CARBON_HOME/repository/components/plugins/bcpkix-jdk15on*.jar ]; then
	   	sever_restart_required=true
   		echo "Remove existing bcpkix-jdk15on jar from plugins folder."
   		location=$(find "$CARBON_HOME/repository/components/plugins/" -type f -name "bcpkix-jdk15on*.jar" | head -1)
   		mv "$location" "$homeDir/.wso2-bc/backup"
   		echo "Successfully removed bcpkix-jdk15on_$BCPKIX_JDK15ON_VERSION.jar from component/plugins."
	fi

	if grep -q "$bcprov_text" "$bundles_info"; then
		sever_restart_required=true
		sed -i '/bcprov-jdk15on/d' $bundles_info
	fi
	if grep -q "$bcpkix_text" "$bundles_info"; then
		sever_restart_required=true
		sed -i '/bcpkix-jdk15on/d' $bundles_info
	fi

	if [ -e $CARBON_HOME/repository/components/lib/bc-fips*.jar ]; then
	    location=$(find "$CARBON_HOME/repository/components/lib/" -type f -name "bc-fips*.jar" | head -1)
		if [ ! $location = "$CARBON_HOME/repository/components/lib/bc-fips-$BC_FIPS_VERSION.jar" ]; then
		    sever_restart_required=true
   	    	echo "There is an update for bc-fips. Therefore Remove existing bc-fips jar from lib folder."
   		    rm rm $CARBON_HOME/repository/components/lib/bc-fips*.jar 2> /dev/null
		    echo "Successfully removed bc-fips_$BC_FIPS_VERSION.jar from component/lib."
		    if [ -f $CARBON_HOME/repository/components/dropins/bc_fips*.jar ]; then
   	            	sever_restart_required=true
   		        echo "Remove existing bc-fips jar from dropins folder."
   		        rm rm $CARBON_HOME/repository/components/dropins/bc_fips*.jar 2> /dev/null
   		        echo "Successfully removed bc-fips_$BC_FIPS_VERSION.jar from component/dropins."
   	        fi
		fi
	fi

	if [ ! -e $CARBON_HOME/repository/components/lib/bc-fips*.jar ]; then
		sever_restart_required=true
		if [ -z "$arg1" ] && [ -z "$arg2" ]; then
		    echo "both empty"
		    echo "Downloading required bc-fips jar : bc-fips-$BC_FIPS_VERSION"
		    curl https://repo1.maven.org/maven2/org/bouncycastle/bc-fips/$BC_FIPS_VERSION/bc-fips-$BC_FIPS_VERSION.jar -o $CARBON_HOME/repository/components/lib/bc-fips-$BC_FIPS_VERSION.jar
		    ACTUAL_CHECKSUM=$(sha1sum $CARBON_HOME/repository/components/lib/bc-fips*.jar | cut -d' ' -f1)
	    	if [ "$EXPECTED_BC_FIPS_CHECKSUM" = "$ACTUAL_CHECKSUM" ]; then
  		        echo "Checksum verified: The downloaded bc-fips-$BC_FIPS_VERSION.jar is valid."
	    	else
  		        echo "Checksum verification failed: The downloaded bc-fips-$BC_FIPS_VERSION.jar may be corrupted."
	   	    fi
	   	elif [ ! -z "$arg1" ] && [ -z "$arg2" ]; then
	        echo "2 empty"
	    	if [ ! -e $arg1/bcpkix-fips-$BCPKIX_FIPS_VERSION.jar ]; then
	    	    echo "Can not be found required bc-fips-$BC_FIPS_VERSION.jar in given file path : $arg1."
	    	else
			    cp "$arg1/bc-fips-$BC_FIPS_VERSION.jar" "$CARBON_HOME/repository/components/lib"
			    if [ $? -eq 0 ]; then
  				    echo "bc-fips JAR files copied successfully."
			    else
  				    echo "Error copying bc-fips JAR file."
			    fi
			fi
		else
		    echo "1 empty"
		    echo "Downloading required bc-fips jar : bc-fips-$BC_FIPS_VERSION"
		    curl $arg2/org/bouncycastle/bc-fips/$BC_FIPS_VERSION/bc-fips-$BC_FIPS_VERSION.jar -o $CARBON_HOME/repository/components/lib/bc-fips-$BC_FIPS_VERSION.jar
		    ACTUAL_CHECKSUM=$(sha1sum $CARBON_HOME/repository/components/lib/bc-fips*.jar | cut -d' ' -f1)
	    	if [ "$EXPECTED_BC_FIPS_CHECKSUM" = "$ACTUAL_CHECKSUM" ]; then
  		        echo "Checksum verified: The downloaded bc-fips-$BC_FIPS_VERSION.jar is valid."
	    	else
  		        echo "Checksum verification failed: The downloaded bc-fips-$BC_FIPS_VERSION.jar may be corrupted."
	   	    fi
	   	fi
	fi

	if [ -e $CARBON_HOME/repository/components/lib/bcpkix-fips*.jar ]; then
	    location=$(find "$CARBON_HOME/repository/components/lib/" -type f -name "bcpkix-fips*.jar" | head -1)
		if [ ! $location = "$CARBON_HOME/repository/components/lib/bcpkix-fips-$BCPKIX_FIPS_VERSION.jar" ]; then
		    sever_restart_required=true
   	    	echo "There is an update for bcpkix-fips. Therefore Remove existing bcpkix-fips jar from lib folder."
   		    rm rm $CARBON_HOME/repository/components/lib/bcpkix-fips*.jar 2> /dev/null
		    echo "Successfully removed bcpkix-fips_$BCPKIX_FIPS_VERSION.jar Removed from component/lib."
		    if [ -f $CARBON_HOME/repository/components/dropins/bcpkix-fips*.jar ]; then
   		        echo "Remove existing bcpkix-fips jar from dropins folder."
   		        rm rm $CARBON_HOME/repository/components/dropins/bcpkix_fips*.jar 2> /dev/null
   		        echo "Successfully removed bcpkix-fips_$BCPKIX_FIPS_VERSION.jar from component/dropins."
   	        fi
		fi
	fi

	if [ ! -e $CARBON_HOME/repository/components/lib/bcpkix-fips*.jar ]; then
	    sever_restart_required=true
	    if [ -z "$arg1" ] && [ -z "$arg2" ]; then
		    echo "Downloading required bcpkix-fips jar : bcpkix-fips-$BCPKIX_FIPS_VERSION"
		    curl https://repo1.maven.org/maven2/org/bouncycastle/bcpkix-fips/$BCPKIX_FIPS_VERSION/bcpkix-fips-$BCPKIX_FIPS_VERSION.jar -o $CARBON_HOME/repository/components/lib/bcpkix-fips-$BCPKIX_FIPS_VERSION.jar
		    ACTUAL_CHECKSUM=$(sha1sum $CARBON_HOME/repository/components/lib/bcpkix-fips*.jar | cut -d' ' -f1)
	   	    if [ "$EXPECTED_BCPKIX_FIPS_CHECKSUM" = "$ACTUAL_CHECKSUM" ]; then
  			    echo "Checksum verified: The downloaded bcpkix-fips-$BCPKIX_FIPS_VERSION.jar is valid."
	    	else
  			    echo "Checksum verification failed: The downloaded bcpkix-fips-$BCPKIX_FIPS_VERSION.jar may be corrupted."
	    	fi
	    elif [ ! -z "$arg1" ] && [ -z "$arg2" ]; then
	   	    echo "2 empty"
	   	    if [ ! -e $arg1/bcpkix-fips-$BCPKIX_FIPS_VERSION.jar ]; then
	   	    	echo "Can not be found required bcpkix-fips-$BCPKIX_FIPS_VERSION.jar in given file path : $arg1."
	   	    else
			    cp "$arg1/bcpkix-fips-$BCPKIX_FIPS_VERSION.jar" "$CARBON_HOME/repository/components/lib"
			    if [ $? -eq 0 ]; then
  				    echo "bcpkix-fips JAR files copied successfully."
			    else
  				    echo "Error copying bcpkix-fips JAR file."
			    fi
		    fi
		else
			echo "1 empty"
			echo "Downloading required bcpkix-fips jar : bcpkix-fips-$BCPKIX_FIPS_VERSION"
		    curl $arg2/org/bouncycastle/bcpkix-fips/$BCPKIX_FIPS_VERSION/bcpkix-fips-$BCPKIX_FIPS_VERSION.jar -o $CARBON_HOME/repository/components/lib/bcpkix-fips-$BCPKIX_FIPS_VERSION.jar
			ACTUAL_CHECKSUM=$(sha1sucam $CARBON_HOME/repository/components/lib/bc-fips*.jar | cut -d' ' -f1)
	    	if [ "$EXPECTED_BC_FIPS_CHECKSUM" = "$ACTUAL_CHECKSUM" ]; then
  		    	echo "Checksum verified: The downloaded bc-fips-$BC_FIPS_VERSION.jar is valid."
	    	else
  		    	echo "Checksum verification failed: The downloaded bc-fips-$BC_FIPS_VERSION.jar may be corrupted."
	   		fi
	   	fi
	fi
fi

if [ "$sever_restart_required" = true ] ; then
    echo "Please restart the server."
fi
