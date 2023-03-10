#!/bin/bash

RAIDNAME="Media"
PUSHOVER_APP_TOKEN=""
PUSHOVER_USER_TOKEN=""

RESULT="$(diskutil appleRaid list -plist | plutil -convert json -r -o - -- - | jq '.AppleRAIDSets[] | select(.Name | contains("'$RAIDNAME'"))')"

STATUS="$(jq '.Members[].MemberStatus' <<< "$RESULT"  | tr -dc '[:alnum:]\n\r')"

ONLINE=$'Online\nOnline\nOnline\nOnline'

# echo $STATUS
# echo $ONLINE

if [ "$STATUS" = "$ONLINE" ]; then
        echo "$RAIDNAME is ONLINE"
        syslog -s -k Facility com.apple.console \
             Level Info \
             Sender Raidalert \
             Message "$RAIDNAME is ONLINE"
        exit 0;
else
        syslog -s -k Facility com.apple.console \
             Level Warning \
             Sender Raidalert \
             Message "$RAIDNAME is DEGRADED"

        curl -s \
            --form-string $PUSHOVER_APP_TOKEN \
            --form-string $PUSHOVER_USER_TOKEN \
            --form-string "message=$RAIDNAME is DEGRADED" \
            https://api.pushover.net/1/messages.json\n
fi
