#!/bin/bash
# chkconfig: 345 20 80
# description: Superbowl web application start/shutdown script
# processname: java
#
# Installation:
# copy file to /etc/init.d
# chmod +x /etc/init.d/ninja

# chkconfig --add /etc/init.d/ninja
# chkconfig ninja on
#     OR on a Debian system
# sudo update-rc.d ninja defaults

#
# Usage: (as root)
# service superbowl start
# service superbowl stop
# service superbowl status
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Path to the application
APPLICATION_SUPERBOWL=Superbowl
APPLICATION_NAME=superbowl
APPLICATION_PATH=/opt/${APPLICATION_NAME}/bin
APPLICATION_JAR=superbowl.jar

PID_FILE=/var/run/${APPLICATION_NAME}.pid
PORT=9000

# Path to the JVM
JAVA_BIN=/usr/lib/jvm/java-8-openjdk-i386/bin/java
PARAMS="-Dninja.port=${PORT} -jar ${APPLICATION_PATH}/${APPLICATION_JAR}"

# User running the Ninja process
#USER=ninja
USER=mbsusr01

RETVAL=0

start() {
    if [ -f ${PID_FILE} ]; then
        echo "Ninja application ${APPLICATION_SUPERBOWL} already running"
    else
        DAEMON_START_LINE="start-stop-daemon --chdir=${APPLICATION_PATH} --make-pidfile --pidfile ${PID_FILE} --chuid ${USER} --exec ${JAVA_BIN} --background --start -- ${PARAMS}"
        ${DAEMON_START_LINE}
        RETVAL=$?
        echo -n "Starting Ninja Application: ${APPLICATION_SUPERBOWL}"


            if [ $RETVAL -eq 0 ]; then
                echo " - Success"
            else
                echo " - Failure"
            fi
        #echo
    fi
    #echo

}
stop() {
    kill -9 `cat ${PID_FILE}`
    RETVAL=$?
    rm -rf ${PID_FILE}
    echo -n "Stopping Ninja application: ${APPLICATION_SUPERBOWL}"

    if [ $RETVAL -eq 0 ]; then
        echo " - Success"
    else
        echo " - Failure"
    fi
        #echo
    }

status() {
    if [ -f ${PID_FILE} ]; then
        echo "Ninja application ${APPLICATION_SUPERBOWL} running"
    else
        echo "Ninja application ${APPLICATION_SUPERBOWL} not running"
    fi
    #echo

}

clean() {
        rm -f ${PID_FILE}
}

case "$1" in
    start)
    start
    ;;
    stop)
    stop
    ;;
    restart|reload)
    stop
    sleep 10
    start
    ;;
    status)
    status
    ;;
    clean)
    clean
    ;;
*)
echo "Usage: $0 {start|stop|restart|status}"
esac
