

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


# /usr/bin/gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'google-chrome.desktop', 'test.desktop']"

su - $SUDO_USER -c "gsettings set org.gnome.shell favorite-apps \"['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'google-chrome.desktop', 'test.desktop']\""


su - $SUDO_USER gnome-terminal -- bash -c "gsettings set org.gnome.shell favorite-apps \"['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'google-chrome.desktop', 'test.desktop']\" && sleep 10"


SETTINGS="['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'google-chrome.desktop', 'test.desktop']"


su - $SUDO_USER -c gnome-terminal -- bash -c "gsettings set org.gnome.shell favorite-apps \"${SETTINGS}\" && sleep 10"
su - $SUDO_USER -c "gnome-terminal -- bash -c \"echo nim && sleep 10\""






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
apt-get install -y fuser
echo y | fuser -vik /var/cache/debconf/config.dat
debconf-set-selections <<< "postfix postfix/mailname string $SUDO_USER@local"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
DEBIAN_FRONTEND=noninteractive && apt-get install -y --assume-yes mailutils postfix
echo "test message" | mailx -s 'test subject' asmodat@gmail.com
```
```
apt-get install mpack
mpack -s "file you wanted" ./ble asmodat@gmail.com
```


