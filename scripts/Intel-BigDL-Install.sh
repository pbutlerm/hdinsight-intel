#! /bin/bash

#Variables 
BIGDL_TARFILEURI=https://bigdlhdinsightoffer.blob.core.windows.net/hdinsightbigdlv04a/dist-spark-2.2.0-scala-2.11.8-all-0.4.0-dist.zip
WEBWASB_TARFILE=dist-spark-2.2.0-scala-2.11.8-all-0.4.0-dist.zip
HOMEDIR=$(pwd)

#Functions 

#Execution 
##############################
if [ "$(id -u)" != "0" ]; then
    echo "[ERROR] The script has to be run as root."
    usage
fi

mkdir BigDL
cd BigDL

echo "Downloading webwasb tar file"
wget $WEBWASB_TARFILEURI 
    
echo "Unzipping webwasb-tomcat"
#tar -zxvf $WEBWASB_TARFILE -C /usr/share/
unzip $WEBWASB_TARFILE
rm $WEBWASB_TARFILE

echo "checking scala version"
scala -version

echo "checking java version"
java -version

echo "checking Spark vesrion"
spark-submit --version

export BIGDL_HOME=$HOMEDIR/BigDL
export SPARK_HOME=/usr/local/spark

echo "BIGDL_HOME " $BIGDL_HOME
echo "SPARK_HOME " $SPARK_HOME


USERID=$(echo -e "import hdinsight_common.Constants as Constants\nprint Constants.AMBARI_WATCHDOG_USERNAME" | python)

echo "USERID=$USERID"

PASSWD=$(echo -e "import hdinsight_common.ClusterManifestParser as ClusterManifestParser\nimport hdinsight_common.Constants as Constants\nimport base64\nbase64pwd = ClusterManifestParser.parse_local_manifest().ambari_users.usersmap[Constants.AMBARI_WATCHDOG_USERNAME].password\nprint base64.b64decode(base64pwd)" | python)

export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64

if [ -e $HUE_INSTALLFOLDER ]; then
    echo "Hue is already installed. Exiting ..."
    exit 0
fi

echo JAVA_HOME=$JAVA_HOME
