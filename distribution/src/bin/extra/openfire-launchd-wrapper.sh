#!/bin/bash
export OPENFIRE_HOME="/usr/local/openfire"
export JAVA_HOME=$(/usr/libexec/java_home -v 17)

function shutdown() 
{
	date
	echo "Shutting down Openfire"
    kill -s TERM $(ps auxww | grep -v wrapper | awk '/openfire/ && !/awk/ {print $2}')
}

date
echo "Starting Openfire"

OPENFIRE_OPTS=""
OPENFIRE_OPTS="$OPENFIRE_OPTS -DopenfireHome=$OPENFIRE_HOME"
OPENFIRE_OPTS="$OPENFIRE_OPTS -Dopenfire.lib.dir=$OPENFIRE_HOME/lib"
OPENFIRE_OPTS="$OPENFIRE_OPTS -Djava.security.properties=$OPENFIRE_HOME/resources/security/java.security"
OPENFIRE_OPTS="$OPENFIRE_OPTS -Djdk.tls.server.enableStatusRequestExtension=true"
OPENFIRE_OPTS="$OPENFIRE_OPTS -Dcom.sun.security.enableCRLDP=true"


JAVA_CMD_OPTS=""
JAVA_CMD_OPTS="$JAVA_CMD_OPTS -Dlog4j.configurationFile=$OPENFIRE_HOME/lib/log4j2.xml"
JAVA_CMD_OPTS="$JAVA_CMD_OPTS -Dlog4j2.formatMsgNoLookups=true"
JAVA_CMD_OPTS="$JAVA_CMD_OPTS -Djdk.tls.ephemeralDHKeySize=matched"
JAVA_CMD_OPTS="$JAVA_CMD_OPTS -Djsse.SSLEngine.acceptLargeFragments=true"
JAVA_CMD_OPTS="$JAVA_CMD_OPTS -Djava.net.preferIPv6Addresses=system"

/usr/bin/java $JAVA_CMD_OPTS -server $OPENFIRE_OPTS -jar "$OPENFIRE_HOME/lib/startup.jar" &

OPENFIRE_PID=$(ps auxww | grep -v wrapper | awk '/openfire/ && !/awk/ {print $2}')

# allow any signal which would kill a process to stop Openfire
trap shutdown HUP INT QUIT ABRT KILL ALRM TERM TSTP

echo "Waiting for `cat $OPENFIRE_PID`"
wait `cat $OPENFIRE_PID`
