#! /bin/bash

#Creating log file
mkdir -p /opt/intelbigdl/var/log
LOGFILE="/opt/intelbigdl/var/log/execution.log"
touch $LOGFILE
chmod 700 $LOGFILE

#Forcing all script output to log file
exec > >(tee -i $LOGFILE)
exec 2>&1
echo "Log Location should be: [ $LOGFILE ]"

#Variables 
BIGDL_TARFILEURI=https://bigdlhdinsightoffer.blob.core.windows.net/hdinsightbigdlv04a/dist-spark-2.1.1-scala-2.11.8-all-0.4.0-dist.zip
BIGDL_TARFILE=dist-spark-2.1.1-scala-2.11.8-all-0.4.0-dist.zip

# Parameters 
user_name=$1
echo "user_name:" $user_name 
HOMEDIR=/home/$user_name
echo "HOMEDIR" $HOMEDIR


#Functions 
usage() {
    echo ""
    echo "Usage: sudo -E bash Intel-BigDL-Install.sh";
    echo "This script needs the SSH User name as a parameter";
    exit 132;
}

#Execution 
##############################
echo "Staring : Intel-BigDL-Install.sh....";

# Check for Root
if [ "$(id -u)" != "0" ]; then
    echo "[ERROR] The script has to be run as root."
    usage
fi

# Check for Parameters (one required)
if [[ $# -eq 0 ]]; then
    echo '[ERROR] The script requires the SSH User name.'
    usage
fi


echo "creating directories for the SSH User"
echo $user_name
echo pwd
cd /home/$user_name
mkdir BigDL
cd BigDL
CURRENT_LOCATION=$(pwd)

echo "Downloading webwasb tar file into " $CURRENT_LOCATION
#wget $BIGDL_TARFILEURI 
#Re-Try + Backoff for Downloading of the file
for RETRY in 1 2 3 4 5 ; do
  wget  $BUNDLE_TGZ_URI 
  if [ "x$?" = "x0" ] ; then
    break
  fi
  sleep $RETRY
done
    
echo "Unzipping webwasb-tomcat"
#tar -zxvf $WEBWASB_TARFILE -C /usr/share/
unzip $BIGDL_TARFILE
rm $BIGDL_TARFILE

echo "Installing scala"
sudo apt-get install scala -y

echo "checking scala version"
scala -version

echo "checking java version"
java -version

echo "checking Spark vesrion"
spark-submit --version

export BIGDL_HOME=$HOMEDIR/BigDL
#export SPARK_HOME=/usr/local/spark #SPARK_HOME is already exported by default in HDInsight

#export "BIGDL_HOME"=$BIGDL_HOME 
echo "BIGDL_HOME="$BIGDL_HOME >> /etc/environment
echo "BIGDL_HOME " $BIGDL_HOME
echo "SPARK_HOME " $SPARK_HOME


USERID=$(echo -e "import hdinsight_common.Constants as Constants\nprint Constants.AMBARI_WATCHDOG_USERNAME" | python)

echo "USERID=$USERID"

PASSWD=$(echo -e "import hdinsight_common.ClusterManifestParser as ClusterManifestParser\nimport hdinsight_common.Constants as Constants\nimport base64\nbase64pwd = ClusterManifestParser.parse_local_manifest().ambari_users.usersmap[Constants.AMBARI_WATCHDOG_USERNAME].password\nprint base64.b64decode(base64pwd)" | python)

export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64

echo JAVA_HOME=$JAVA_HOME

exit 0
