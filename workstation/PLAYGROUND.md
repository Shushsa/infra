> File copy     #${KIRA_REGISTRY}/${IMAGE_NAME}
# docker cp validator-1:/self/logs/init_script_output.txt .
# docker cp validator-1:/self/logs/init_script_output.txt .
# docker cp validator-1:/self/home/success_end .

> Useful References

* https://stackoverflow.com/questions/46032392/docker-compose-does-not-allow-to-use-local-images


> Stopping container
* docker container kill 477dfbee3b8a67ba8531a234716f7c5d9677879c63a895dbace05d450ba3c803

> Removing container
* docker rm 477dfbee3b8a67ba8531a234716f7c5d9677879c63a895dbace05d450ba3c803

> Remove all images (cleanup)
* docker rmi $(docker images -q) -f || echo "Failed to delete all images"

> Creating Shortcuts
 
```
$ cat shortcut-for-my-script.desktop
[Desktop Entry]
Type=Application
Terminal=true
Name=Click-Script
Icon=utilities-terminal
Exec=gnome-terminal -e "bash -c './script.sh;$SHELL'"
Categories=Application;
```

dconf write /org/gnome/shell/favorite-apps "['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'google-chrome.desktop', 'test.desktop']"

su - $SUDO_USER -c "dconf write \"/org/gnome/shell/favorite-apps\" \"['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'google-chrome.desktop', 'test.desktop']\""


# /usr/bin/gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'google-chrome.desktop', 'test.desktop']"

su - $SUDO_USER -c "gsettings set org.gnome.shell favorite-apps \"['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'google-chrome.desktop', 'test.desktop']\""


su - $SUDO_USER gnome-terminal -- bash -c "gsettings set org.gnome.shell favorite-apps \"['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'google-chrome.desktop', 'test.desktop']\" && sleep 10"


SETTINGS="['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'google-chrome.desktop', 'test.desktop']"


su - $SUDO_USER -c gnome-terminal -- bash -c "gsettings set org.gnome.shell favorite-apps \"${SETTINGS}\" && sleep 10"
su - $SUDO_USER -c "gnome-terminal -- bash -c \"echo nim && sleep 10\""



# apt-get install libssl1.0.2
# CDHelper email send --from="noreply.example.email@gmail.com" --to="asmodat@gmail.com" --subject="test" --body="hello"





dconf read /org/gnome/shell/favorite-apps


name="test"
application="'${name}.desktop'"
favourites="/org/gnome/shell/favorite-apps"
dconf write ${favourites} \
  "$(dconf read ${favourites} \
  | sed "s/, ${application}//g" \
  | sed "s/${application}//g" \
  | sed -e "s/]$/, ${application}]/")"


dconf read /org/gnome/shell/favorite-apps


rm -fv /home/$SUDO_USER/.local/share/applications/test.desktop
cp /home/asmodat/Desktop/test.desktop /home/$SUDO_USER/.local/share/applications && \
 chmod 777 /home/$SUDO_USER/.local/share/applications/test.desktop


################################################

rm -fv /usr/share/applications/test.desktop
cp /home/asmodat/Desktop/test.desktop /usr/share/applications && chmod 777 /usr/share/applications/test.desktop




################################################

/usr/bin/gsettings reset org.gnome.shell favorite-apps "['ubiquity.desktop', 'firefox.desktop', 'org.gnome.Nautilus.desktop', 'test.desktop']"

################################################

rm -fv /usr/share/applications/test.desktop
cp /home/asmodat/Desktop/test.desktop /usr/share/applications && chmod 777 /usr/share/applications/test.desktop

gsettings set org.gnome.shell.extensions.dash-to-dock

# /usr/bin/gsettings set Click-Script favorite-apps

> To send email: (this method i snot working bc ISP blocing)
```
https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-postfix-as-a-send-only-smtp-server-on-ubuntu-14-04
KIRA_SETUP_MAIL="$KIRA_SETUP/mail-v0.0.1" 
if [ ! -f "$KIRA_SETUP_MAIL" ] ; then
    echo "Installing SMTP server..."
    # apt-get install libssl1.0.2
    apt remove --purge mailutils -y || echo "Failed to remove old mailutils version"
    apt remove --purge fuser -y || echo "Failed to remove old fuser version"
    apt remove --purge postfix -y || echo "Failed to remove old postfix version"

    POSTFIX_HOSTNAME=infra.kiracore.com
    hostnamectl set-hostname $POSTFIX_HOSTNAME
    apt-get install -y fuser

    # Config location: /etc/postfix/main.cf
    debconf-set-selections <<< "postfix postfix/inet_interfaces string loopback-only"
    debconf-set-selections <<< "postfix postfix/mailname string ${POSTFIX_HOSTNAME}"
    debconf-set-selections <<< "postfix postfix/myhostname string ${POSTFIX_HOSTNAME}"
    debconf-set-selections <<< "postfix postfix/destinations string '${POSTFIX_HOSTNAME}, localhost'"
    debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
    DEBIAN_FRONTEND=noninteractive && apt-get install -y --assume-yes mailutils postfix

    CDHelper text lineswap --text="inet_interfaces = loopback-only" --prefix="inet_interfaces" --input=/etc/postfix/main.cf
    service postfix restart
    service postfix status

    # test
    # Test Example: echo foo > bla && mail -s "bla" asmodat@gmail.com< ./bla
    # SMTP_SECRET='{"host":"infra.kiracore.com","port":"25","ssl":false,"login":"","password":""}'
    # SMTP_SECRET='{"host":"localhost","port":"25","ssl":false,"login":"","password":""}'
    # CDHelper email send --from="test@root" --to="asmodat@gmail.com" --subject="test" --body="hello"

    touch $KIRA_SETUP_MAIL
else
    echo "SMTP server was already installed."
    service postfix status
fi
```
```
apt-get install mpack
mpack -s "file you wanted" ./ble asmodat@gmail.com
```


