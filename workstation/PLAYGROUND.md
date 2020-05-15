

> Useful References

* https://stackoverflow.com/questions/46032392/docker-compose-does-not-allow-to-use-local-images


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