#!/bin/sh

# This stuff will be ignored by systems that don't use chkconfig.
# chkconfig: 345 87 13
# description: H2 database
# pidfile: /opt/h2/server/bin/h2.pid
# config: 

### BEGIN INIT INFO
# Provides:          H2-Server
# Required-Start:    
# Required-Stop:
# Default-Start:     3 5
# Default-Stop:      0 1 2 6
# Short-Description: H2-Server
# Description:       H2 database service
### END INIT INFO

# Starts and stops the h2 database

# Some general variables
APPLICATION_NAME=h2
H2_VERSION=1.4.193 # Important! Set your version!
H2_HOME=/opt/h2
H2_SERVER=/opt/h2/server
H2_STORE=/opt/h2/store
H2_BACKUP=/opt/h2/backup
H2_TCPPORT=9092
PID_FILE=$H2_SERVER/bin/h2.pid
#JVM_OPTS="-DfunctionsInSchema=true"
JVM_OPTS=""

# starts h2 server
h2_start () {

     if [ -e $H2_SERVER/bin/h2.pid ]; then
        echo $APPLICATION_NAME "is still running"
        exit 1
     fi

     cd $H2_SERVER/bin

     # this will start h2 server with allowed tcp connection
     # you can find more info in h2 tutorials
     #java -Xms256m -Xmx768m -cp h2-$H2_VERSION.jar $JVM_OPTS org.h2.tools.Server -tcp -tcpPort 9092 -tcpAllowOthers -web -webAllowOthers -baseDir $H2_STORE/superbowl $1 > $H2_HOME/h2.log 2>&1 &
     java -Xms256m -Xmx768m -cp h2-$H2_VERSION.jar $JVM_OPTS org.h2.tools.Server -tcp -tcpPort $H2_TCPPORT -baseDir $H2_STORE/superbowl $1 > $H2_HOME/h2.log 2>&1 &

     echo $! > $H2_SERVER/bin/h2.pid
     #sleep 3
     #echo "H2-$H2_VERSION started. Setting multithreaded"
     echo "$APPLICATION_NAME database server started. Running on Port" $H2_TCPPORT "- Success"

     # Just set multi threaded on my database with name superbowl 
     #java -cp h2-$H2_VERSION.jar $JVM_OPTS org.h2.tools.Shell -url "jdbc:h2:tcp://localhost/SB" -user sa -password -sql "SET MULTI_THREADED 1"
     #java -cp h2-$H2_VERSION.jar $JVM_OPTS org.h2.tools.Shell -url "jdbc:h2:tcp://localhost/opt/h2/store/superbowl" -user sa -password

}

# stops h2
h2_stop () {
  if [ -e $H2_SERVER/bin/h2.pid ]; then
    PID=$(cat $H2_SERVER/bin/h2.pid)
    kill -TERM ${PID}
    echo SIGTERM sent to process ${PID}
    rm $H2_SERVER/bin/h2.pid
    echo "${APPLICATION_NAME} database server stopped - Success"
  else
    echo File $H2_SERVER/bin/h2.pid not found!
  fi
}

# h2 databse server version
h2_version () {
  echo "H2-$H2_VERSION"
}

# Just to remove pid file in case you killed h2 manually 
# and want to start it by script, but he thinks
# that h2 is already running
h2_zap () {
     rm $H2_SERVER/bin/h2.pid
}

# Backups specified database to a given path 
backup () {
     echo Backing up database to $1
     cd $H2_HOME/backup

     java -cp $H2_SERVER/bin/h2-1.4.193.jar org.h2.tools.Script -url "jdbc:h2:tcp://localhost/superbowlDB" -user sa -script $H2_HOME"/backup/"$1 -options compression zip
     #java -cp $H2_SERVER/bin/h2-1.4.193.jar org.h2.tools.Script -url "jdbc:h2:tcp://localhost/opt/h2/store/superbowl/superbowlDB"
     #java -cp $H2_SERVER/bin/h2-1.4.193.jar org.h2.tools.Script -url "jdbc:h2:tcp://localhost/opt/h2/store/superbowl/superbowlDB" -user sa -password -script $1
     #java -cp h2-$H2_VERSION.jar $JVM_OPTS org.h2.tools.Script -url "jdbc:h2:tcp://localhost/opt/h2/store/superbowl/superbowlDB" -user sa -password -script "$1" -options compression zip
}

# Restores specified database from the given path
restore () {
     echo Restoring database from $1
     cd $H2_HOME/backup

     java -cp $H2_SERVER/bin/h2-1.4.193.jar org.h2.tools.RunScript -url "jdbc:h2:tcp://localhost/superbowlDB;create=true" -user sa -script $H2_HOME"/backup/"$1 -showResults -options compression zip
     #java -cp $H2_SERVER/bin/h2-1.4.193.jar org.h2.tools.RunScript -url "jdbc:h2:tcp://localhost/superbowlDB;create=true" -user sa -password -script "$1" -continueOnError
     #java -cp h2-$H2_VERSION.jar $JVM_OPTS org.h2.tools.RunScript -url "jdbc:h2:tcp://localhost/opt/h2/store/superbowl/superbowlDB;create=true" -user sa -password -script "$1" -continueOnError -options compression zip
}

status() {
    if [ -f ${PID_FILE} ]; then
        echo "${APPLICATION_NAME} database server running"
    else
        echo "${APPLICATION_NAME} database server not running"
    fi
}

clean() {
	rm -f ${PID_FILE}
}

case "$1" in
    init)
      h2_start
      ;;
    start)
      h2_start -ifExists
      ;;
    stop)
      h2_stop
      ;;
    zap)
      h2_zap
      ;;
    restart)
      h2_stop
      sleep 5
      h2_start -ifExists
      ;;
    backup)
      backup $2
      ;;
    restore)
      restore $2
      ;;
    status)
      status
      ;;
    version)
      h2_version
      ;;
    clean)
      clean
      ;;
    *)
      #echo "Usage: /etc/init.d/h2 {init|start|stop|restart|backup|restore|version|status}"
      echo "Usage: ./h2-daemon.sh {init|start|stop|restart|backup|restore|version|status}"
      exit 1
      ;;
esac

exit 0
