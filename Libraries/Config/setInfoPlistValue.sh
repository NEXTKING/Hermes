USAGE="Usage: -e SETTINGS_ENTRY_ID [-r]"

MODE="SET"

while getopts 'e:r' OPTION
do
case $OPTION in
e)	SETTINGS_ENTRY_ID="$OPTARG"
;;
r)	MODE="RESET"
;;
?)	printf "error: ${USAGE}"
exit 2
;;
esac
done

shift $(($OPTIND - 1))






#application version
TMP=`git rev-parse --short HEAD`
REVISION=`echo "$TMP" | tr 'a-z' 'A-Z'`
PATH_TO_ROOTPLIST="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"

if [ "${MODE}" = "RESET" ]
then
    REVISION="Unset"
fi

/usr/libexec/PlistBuddy -c "Set :$SETTINGS_ENTRY_ID $REVISION" "${PATH_TO_ROOTPLIST}"

echo "Revision ${REVISION} set in the entry ${SETTINGS_ENTRY_ID} of the path ${PATH_TO_ROOTPLIST}"

exit 0
