#!/bin/sh
dir=$(dirname "/opt/h2/server/bin/h2-1.4.193.jar")
echo "$dir"
command=$1
echo "$command"
if [ "$command" = "go" ]
then
	echo Startup H2 Database Server...
	java -cp "$dir/h2-1.4.193.jar:$H2DRIVERS:$CLASSPATH" org.h2.tools.Server -tcp -tcpPort 9092
elif [ "$command" = "fin" ]
then
	echo Shutdown H2 Database Server...
	java -cp "$dir/h2-1.4.193.jar:$H2DRIVERS:$CLASSPATH" org.h2.tools.Server -tcpShutdown tcp://localhost:9092
fi
exit 0

