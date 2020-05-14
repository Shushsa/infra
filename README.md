
# Infrastructure

Kira Full Stack Development, Deployment, Testing and Automation Tools

# Prerequisites

_NOTE: Because many users might have access to this repository or apply changes to this repository that might compromise your environment, it is mandatory for everyone to utilise VM as your working environment._

## Workstation Setup

_NOTE: To maintain consistency among all working environments we will utilise `Ubuntu 20.04 LTS` as a mandatory OS for your workstation_

For the purpose of setting up development environment we will 

1. Install [VMWare Workstation 15.5+](https://www.vmware.com/products/workstation-player/workstation-player-evaluation.html)
2. Download [Ubuntu 20.04 LTS](https://releases.ubuntu.com/20.04/)
3. Boot your machine, open terminal and setup your environment

```
sudo -s

rm -frv $HOME/kira && mkdir -p $HOME/kira && cd $HOME/kira && wget https://raw.githubusercontent.com/KiraCore/infra/master/workstation/setup.sh && chmod -R 777 $HOME/kira && ./setup.sh && /etc/profile
```

_NOTE: `setup.sh` script is used to ensure your working environment has all necessary dependencies to fetch the latest changes to the infa repository and deploy the local infrastructure._

