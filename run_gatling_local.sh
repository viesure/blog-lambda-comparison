GATLING_DIR="`pwd`/gatling"

iterations=100
repeats=5
pace=5
host="http://host.docker.internal:3000"

PARAMS="-Diterations=$iterations -Drepeats=$repeats -Dpace=$pace -Dhost=$host"

docker run --rm -v $GATLING_DIR/conf:/opt/gatling/conf -v $GATLING_DIR/user-files:/opt/gatling/user-files -v $GATLING_DIR/results:/opt/gatling/results -e JAVA_OPTS="$PARAMS" denvazh/gatling
