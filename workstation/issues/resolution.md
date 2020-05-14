
# Screen is not stretching to the full window view on the Windows 10 Host

> This solution does not work

```
KIRA_SETUP_VMTOOLS="$KIRA_SETUP/vm-tools-v0.0.1" 
if [ ! -f "$KIRA_SETUP_VMTOOLS" ] ; then
    echo "Install VM Tools"
    apt purge open-vm-tools -y || echo "Open vm tools not found"
    apt update
    apt install open-vm-tools open-vm-tools-desktop -y
    systemctl daemon-reload
    systemctl restart open-vm-tools.service || echo "VM Tools service is not present"
    touch $KIRA_SETUP_VMTOOLS
else
    echo "VM Tools were already installed."
fi
```
> This solution does not work

```
systemctl edit open-vm-tools.service  

[Unit]
Requires=graphical.target
After=graphical.target
```

> What works is drag and stretch the window / hit to the top corner of the host screen 