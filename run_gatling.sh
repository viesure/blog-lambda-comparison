# Call with ./run_gatling <baseurl> <targetValue> <repeats> <pace>
# Will use default values for testing locally on osx without parameters

GATLING_DIR="`pwd`/gatling"

host=${1:-"http://host.docker.internal:3000"}
targetValue=${2:-100}
repeats=${3:-5}
pace=${4:-5}

PARAMS="-DtargetValue=$targetValue -Drepeats=$repeats -Dpace=$pace -Dhost=$host"

echo "Waiting for docker daemon to initialize..."
timeout 30 sh -c "until docker info; do echo  -n '.'; sleep 1; done"

docker run --rm -v $GATLING_DIR/conf:/opt/gatling/conf -v $GATLING_DIR/user-files:/opt/gatling/user-files -v $GATLING_DIR/results:/opt/gatling/results -e JAVA_OPTS="$PARAMS" denvazh/gatling
