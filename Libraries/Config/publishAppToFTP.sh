USAGE="Usage: -s PATH_TO_IPA -n IPA_NAME -p PRODUCT_NAME -a APP_TYPE [-c(publish to customer) YES/NO] -k CUSTOMER_FTP_FOLDER_NAME [-d(publish to dph) YES/NO] [-e(environment) TEST/PROD]"

SOURCE="UNKNOWN_PATH_TO_IPA"
IPA_NAME="IPA_NAME_UNKNOWN"
VERSION="UNKNOWN_VERSION"
CUSTOMER_FTP_FOLDER_NAME="UNKNOWN_CUSTOMER_FTP_FOLDER_NAME"
SHOULD_PUBLISH_CUSTOMER="NO"
SHOULD_PUBLISH_DPH="NO"
PRODUCTIVE_ENV="TEST"
PRODUCT_NAME="dphHermes"
APP_TYPE="Hermes"


while getopts 's:n:c:k:d:e:p:a:' OPTION
do
case $OPTION in
s)	SOURCE="$OPTARG"
;;
n)  IPA_NAME="$OPTARG"
;;
c)	SHOULD_PUBLISH_CUSTOMER="$OPTARG"
;;
k)  CUSTOMER_FTP_FOLDER_NAME="$OPTARG"
;;
d)  SHOULD_PUBLISH_DPH="$OPTARG"
;;
e)	PRODUCTIVE_ENV="$OPTARG"
;;
p)	PRODUCT_NAME="$OPTARG"
;;
a)	APP_TYPE="$OPTARG"
;;
?)	printf "error: ${USAGE}"
exit 2
;;
esac
done




shift $(($OPTIND - 1))

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "./${PRODUCT_NAME}-Info.Plist")
CURRENT_DIR="`pwd`"

echo "-----------------------------------"
echo "Received parameters:"
echo "Current directory: ${CURRENT_DIR}"
echo "SOURCE=${SOURCE}"
echo "APP_TYPE=${APP_TYPE}"
echo "PRODUCT_NAME=${PRODUCT_NAME}"
echo "IPA_NAME=${IPA_NAME}"
echo "VERSION=${VERSION}"
echo "SHOULD_PUBLISH_CUSTOMER=${SHOULD_PUBLISH_CUSTOMER}"
echo "CUSTOMER_FTP_FOLDER_NAME=${CUSTOMER_FTP_FOLDER_NAME}"
echo "SHOULD_PUBLISH_DPH=${SHOULD_PUBLISH_DPH}"
echo "PRODUCTIVE_ENV=${PRODUCTIVE_ENV}"
echo "-----------------------------------"


if [ -z "${SOURCE}" ] || [ -z "${IPA_NAME}" ] || [ -z "${CUSTOMER_FTP_FOLDER_NAME}" ]
then
printf "error: ${USAGE}"
exit 2
fi


ENVIRONMENT="t" #test system
if [ "${PRODUCTIVE_ENV}" == "PROD" ]
then
ENVIRONMENT="p"

fi
CUSTOMER_FTP_ENV_FOLDER="${CUSTOMER_FTP_FOLDER_NAME}_${ENVIRONMENT}"


#application version
IPA_ABSOLUTE_PATH="${SOURCE}/${IPA_NAME}.ipa"
PATH_TO_PLIST="${SOURCE}/${IPA_NAME}.plist"
PLIST_CONTENT_DPH="<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"><plist version=\"1.0\"><dict><key>items</key><array><dict><key>assets</key><array><dict><key>kind</key><string>software-package</string><key>url</key><string>https://ftp.dataphone.ch/dph/dph_p/${APP_TYPE}/${APP_TYPE}.ipa</string></dict><dict><key>kind</key><string>full-size-image</string><key>needs-shine</key><false/><key>url</key><string>https://ftp.dataphone.ch/dph/dph_p/${APP_TYPE}/${APP_TYPE}_104.png</string></dict><dict><key>kind</key><string>display-image</string><key>needs-shine</key><false/><key>url</key><string>https://ftp.dataphone.ch/dph/dph_p/${APP_TYPE}/${APP_TYPE}_52.png</string></dict></array><key>metadata</key><dict><key>bundle-identifier</key><string>ch.dataphone.${PRODUCT_NAME}</string><key>bundle-version</key><string>${VERSION}</string><key>kind</key><string>software</string><key>title</key><string>${APP_TYPE}</string></dict></dict></array></dict></plist>"

PLIST_CONTENT_CUSTOMER="<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"><plist version=\"1.0\"><dict><key>items</key><array><dict><key>assets</key><array><dict><key>kind</key><string>software-package</string><key>url</key><string>https://ftp.dataphone.ch/${CUSTOMER_FTP_FOLDER_NAME}/${CUSTOMER_FTP_ENV_FOLDER}/${APP_TYPE}/${APP_TYPE}.ipa</string></dict><dict><key>kind</key><string>full-size-image</string><key>needs-shine</key><false/><key>url</key><string>https://ftp.dataphone.ch/${CUSTOMER_FTP_FOLDER_NAME}/${CUSTOMER_FTP_ENV_FOLDER}/${APP_TYPE}/${APP_TYPE}_104.png</string></dict><dict><key>kind</key><string>display-image</string><key>needs-shine</key><false/><key>url</key><string>https://ftp.dataphone.ch/${CUSTOMER_FTP_FOLDER_NAME}/${CUSTOMER_FTP_ENV_FOLDER}/${APP_TYPE}/${APP_TYPE}_52.png</string></dict></array><key>metadata</key><dict><key>bundle-identifier</key><string>ch.dataphone.${PRODUCT_NAME}</string><key>bundle-version</key><string>${VERSION}</string><key>kind</key><string>software</string><key>title</key><string>${APP_TYPE}</string></dict></dict></array></dict></plist>"

echo "Preparing to publishing..."
echo "ENVIRONMENT=${ENVIRONMENT}"
echo "IPA_ABSOLUTE_PATH=${IPA_ABSOLUTE_PATH}"
echo "PATH_TO_PLIST=${PATH_TO_PLIST}"
echo "CUSTOMER_FTP_ENV_FOLDER=${CUSTOMER_FTP_ENV_FOLDER}"
echo "-----------------------------------"

STATUS=0;

if [ "${SHOULD_PUBLISH_CUSTOMER}" == "YES" ]
then
DESTINATION="ftp://dataphone:Data8Phone@ftp.dataphone.ch:21/${CUSTOMER_FTP_FOLDER_NAME}/${CUSTOMER_FTP_ENV_FOLDER}/${APP_TYPE}/"
rm "${PATH_TO_PLIST}"
echo "Generating plist at ${PATH_TO_PLIST}"
echo "${PLIST_CONTENT_CUSTOMER}" >> "${PATH_TO_PLIST}"
echo "Publishing ipa and plist (version=${VERSION}) from ${IPA_ABSOLUTE_PATH} and ${SOURCE}/${IPA_NAME}.plist to FTP ${DESTINATION}"
cd "${SOURCE}"
ftp -u "${DESTINATION}" "${IPA_NAME}.plist" "${IPA_NAME}.ipa"
cd "${CURRENT_DIR}"
if [ $? -eq 0 ];then
echo "Published IPA and PLIST files successfully."
else
STATUS=1
echo "Failed publishing IPA and PLIST files."
fi
fi

if [ "${SHOULD_PUBLISH_DPH}" == "YES" ]
then
DESTINATION="ftp://dataphone:Data8Phone@ftp.dataphone.ch:21/dph/dph_p/${APP_TYPE}/"
rm "${PATH_TO_PLIST}"
echo "Generating plist at ${PATH_TO_PLIST}"
echo "${PLIST_CONTENT_DPH}" >> "${PATH_TO_PLIST}"
echo "Publishing ipa and plist (version=${VERSION}) from ${IPA_ABSOLUTE_PATH} and ${SOURCE}/${IPA_NAME}.plist to FTP ${DESTINATION}"
cd "${SOURCE}"
ftp -u "${DESTINATION}" "${IPA_NAME}.plist" "${IPA_NAME}.ipa"
cd "${CURRENT_DIR}"
if [ $? -eq 0 ];then
echo "Published IPA and PLIST files successfully."
else
STATUS=1
echo "Failed publishing IPA and PLIST files."
fi
fi

if [ "${SHOULD_PUBLISH_DPH}" == "NO" ] && [ "${SHOULD_PUBLISH_CUSTOMER}" == "NO" ]
then
echo "Nothing published. Done."
fi

exit ${STATUS}
