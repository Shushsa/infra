

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