USAGE="Usage: -c CONFIGURATION -s SDK -w WORKSPACE_PATH -a ACTIONS -h SCHEME -p BUILD_PARAMETERS"

BUILD_PARAMETERS="TEST=t"
CONFIGURATION=Release
SDK=iphoneos
WORKSPACE_PATH="./dphHermes-workspace.xcworkspace"
ACTIONS="clean build"
SCHEME="dphHermes"

while getopts 'p:c:s:a:w:h:' OPTION
do
case $OPTION in
p)	BUILD_PARAMETERS="$OPTARG"
;;
c)	CONFIGURATION="$OPTARG"
;;
s)	SDK="$OPTARG"
;;
w)	WORKSPACE_PATH="$OPTARG"
;;
a)	ACTIONS="$OPTARG"
;;
h)	SCHEME="$OPTARG"
;;
?)	printf "error: ${USAGE}"
exit 2
;;
esac
done

shift $(($OPTIND - 1))

echo "BUILD_PARAMETERS=${BUILD_PARAMETERS}"
echo "CONFIGURATION=${CONFIGURATION}"
echo "SDK=${SDK}"
echo "ACTIONS=${ACTIONS}"
echo "WORKSPACE_PATH=${WORKSPACE_PATH}"
echo "SCHEME=${SCHEME}"


/usr/bin/xcodebuild -workspace "${WORKSPACE_PATH}" -sdk "${SDK}" -configuration "${CONFIGURATION}" -scheme "${SCHEME}" ${ACTIONS} "${BUILD_PARAMETERS}"

