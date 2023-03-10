# Introduction
Enables Monitoring of Apple Raid Status and Pushover Notifications in case of Degradation.
Launchctl runs a job every 10 Minutes to check the status of the Apple Software Raid.
If the output detected is other then Online, it pushes a notification to your pushover account.

# Configuration:
##Pushover:
https://pushover.net

Create a User account and an Application. You will get a User and App Token.
Install the Pushover App on your devices and login and configure the Notifications accordingly.

## Macos:
Be sure you have the following packages installed:
diskutil
plutil
jq
tr

jq you can install from homebrew. Be sure to upgrade the :
`brew install jq`

## launched.appleraid.status.plist
Edit the file and configure the following parameters:

ThrottleInterval in seconds. This defines the intervall it runs the status script. (default: 10min)
```
    <key>ThrottleInterval</key>
    <integer>600</integer>
```

Path to check: Change the mountpoint (default: /Volumes/Media) according to your Raid Volume Mount point.
The script runs only if the Volume is mounted at the given Path
```
    <key>PathState</key>
        <dict>
            <key>/Volumes/Media</key>
            <true/>
        </dict>
    </dict>
```

##test-raid.sh
Edit the file and configure the following parameters:

Change the RAIDNAME according to your Raid Volume Name (default: Media). Also add the Pushover App Token and the Pushover User Token accordingly to your configuration on the pushover website.

```
RAIDNAME="Media"
PUSHOVER_APP_TOKEN=""
PUSHOVER_USER_TOKEN=""
```

The amount of Online lines is very important because it is the baseline against the check runs.
If your Raidset for instance contains four slices (Raid10 with four mirrored slices, you need to have four Online\n in the line)

Check with the command by substituting RAIDNAME for your Raid Name:
`diskutil appleRaid list -plist | plutil -convert json -r -o - -- - | jq '.AppleRAIDSets[] | select(.Name | contains("RAIDNAME"))'`

You should get the JSON of back and int the Members Array you will see the amount of members you have. For each MemberStatus, you have to provide a Online\n in the line.

For example, if you have a Raid 10 with four mirrored slices aka 8 Disks with the name "Media" yours would look like this:
```
ONLINE=$'Online\nOnline\nOnline\nOnline'
```

## Installation:

Edit the files and then install the script:
```
sudo cp test-raid.sh /usr/local/bin/
sudo chown root: /usr/local/bin/test-raid.sh
sudo chmod 700 /usr/local/bin/test-raid.sh
```
Install the plist:
```
sudo cp launched.appleraid.status.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/launched.appleraid.status.plist
sudo launchctl load -w /Library/LaunchDaemons/launched.appleraid.status.plist
```

## Verification:
You can tail the err and log output. It should print "RAIDNAME is ONLINE"
```
tail -f /private/tmp/appleraid.log
tail -f /private/tmp/appleraid.err
```
To verify if push messages work, just change the ONLINE Line in the script to something like that:
`sudo vi /usr/local/bin/test-raid.sh`

```
ONLINE=$'Online\nOnline\nOnline\nOnlineSomething so it dont match'
```

You should now get Push messages all 10 Minutes. Be sure to change it back after you verified.




