if [ $# -lt 1 ]
then
        echo "Usage: $0 <tag>"
        exit
fi

TAG="$1"

set -e

(cd $APP_CHECKOUT_DIR &&
 git fetch --tags &&
 git checkout $TAG &&
 git submodule update --init &&
 ./build.sh)

log_msg=[`date '+%y-%m-%e %H:%M'`]\ \ $1
echo $log_msg >> build_log.txt

mkdir -p builds
cp $LOCAL_WAR builds/$1.war
