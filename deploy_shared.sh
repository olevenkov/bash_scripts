if [ $# -lt 2 ]
then
        echo "Usage: $0 <env> <tag>|restart <user>"
        exit
fi

if [ $# -lt 3 ] && [[ $1 = prod ]]
then
        echo "Supply a user to deploy to prod"
        exit
fi

case "$1" in
    dev) 
	DOMAIN=dev.ninfram.net
	SERVERS="app01"
	SUDO=""
	USER=root
	;;
    qa) 
	DOMAIN=qa.ninfram.net
	SERVERS="app01 app02"
	SUDO=""
	USER=root
	;;
    qa2)
	APP_NAME=${APP_NAME}2
	DOMAIN=qa.ninfram.net
        SERVERS="app01 app02"
        SUDO=""
        USER=root
	;;
    prod)
	DOMAIN=teacher.ninfram.net
	SERVERS="app01 app02"
	SUDO="sudo "
	USER="$3"
	;;
    *)
esac

TAG="$2"

if [[ $TAG = restart ]]
then
    for server in $SERVERS; do
	ssh ${USER}@${server}.${APP_NAME}.${DOMAIN} ${SUDO} /etc/init.d/tomcat-6 restart
    done
    exit
fi

set -e

(cd $APP_CHECKOUT_DIR &&
 git fetch --tags &&
 git checkout $TAG &&
 git submodule update --init &&
 ./build.sh)

if [[ $1 = prod ]]
then
    echo "**********************************************************"
    echo "You wil be asked for your ldap sudo password, and then the"
    echo "builds@builds.ninfram.net passwords"
fi

for server in $SERVERS; do
    if [[ $1 = prod ]]
    then
	ssh -t ${USER}@${server}.${APP_NAME}.${DOMAIN} ${SUDO} rsync builds@builds.ninfram.net:${DIR}/${LOCAL_WAR} ${REMOTE_WAR}
    else
        scp ${LOCAL_WAR} root@${server}.${APP_NAME}.${DOMAIN}:${REMOTE_WAR}
    fi
done

log_msg=[`date '+%y-%m-%e %H:%M'`]\ \ $1\ \ $2
echo $log_msg >> deploy_log.txt

