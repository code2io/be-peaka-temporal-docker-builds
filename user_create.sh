GROUP="temporal"
USER="allianz_temporal"
GROUP_FILE="/etc/group"

# Create user
echo "$USER:x:1000920000:1000920000::/home/allianz_temporal:" >> /etc/passwd
echo "$USER:!:$(($(date +%s) / 60 / 60 / 24)):0:99999:7:::" >> /etc/shadow

# Add user to group temporal
awk -F: -v grp="$GROUP" -v usr="$USER" 'BEGIN {OFS=FS}
$1 == grp {
    if ($NF == "") {
        $NF = usr
    } else {
        split($NF, members, ",")
        found=0
        for (m in members) if (members[m] == usr) found=1
        if (!found) $NF = $NF "," usr
    }
}
{print}
' "$GROUP_FILE" > "${GROUP_FILE}.tmp" && mv "${GROUP_FILE}.tmp" "$GROUP_FILE"

mkdir /home/$USER && chown $USER: /home/$USER
