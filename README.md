
# Infrastructure

Kira Full Stack Development, Deployment, Testing and Automation Tools

# Prerequisites

> _NOTE: Because many users might have access to this repository or apply changes to this repository that might compromise your environment, it is mandatory for everyone to utilise VM as your working environment._

## Workstation Setup

> _NOTE: To maintain consistency among all working environments we will utilise `Ubuntu 20.04 LTS` as a mandatory OS for your workstation_

For the purpose of setting up development environment we will 

1. Install [VMWare Workstation 15.5+](https://www.vmware.com/products/workstation-player/workstation-player-evaluation.html)
   
2. Download and Install [Ubuntu 20.04 LTS](https://releases.ubuntu.com/20.04/) with VMWare
   * Recommended VM Setup
     * CPU: 4 virtualized cores
     * RAM: 8 GB
     * Disk: 64 GB (SSD or NVMe)
3. Boot your machine, and ensure latest updates are applied using `Software Updater`

* ![picture 1](https://i.imgur.com/7SX2g7y.png)

4. Restart your VM & Open terminal to execute following command that will launch a setup script


    > _NOTE: You will be prompted to input branch names you are working with as well as email address where you will receive notifications_

```
sudo -s

cd /tmp && rm -f ./init.sh && wget https://raw.githubusercontent.com/KiraCore/infra/v0.0.1/workstation/init.sh -O ./init.sh && chmod 777 ./init.sh && ./init.sh
```

5. Allow launching of KIRA-MANAGER and setup your working environment

  * ![picture 1](https://i.imgur.com/4EKLdEh.png)

   > _NOTE: If you want to stay 100% safe, you should create a new gmail account if you want to work with and receive notifications from Kira's virtual environment_

   i. Click on the `KIRA-MANAGER` icon to start it & setup desired branches that you want to work with

   ii. (OPTIONAL) Define email where you want to receive build notifications

   iii. (OPTIONAL) [Enable SMTP](https://www.youtube.com/watch?v=D-NYmDWiFjU) and [less secure apps](https://web.archive.org/save/https://hotter.io/docs/email-accounts/secure-app-gmail/) in your gmail account, then provide your login and password as SMTP credentials

   iv.  In your github go to [Account Settings](https://github.com/settings/profile) -> [SSH and PGP keys](https://github.com/settings/keys) -> [New SSH Key](`https://github.com/settings/ssh/new`) and add new ssh key using provided to you by the `KIRA-MANAGER` PUBLIC ssh key (or create new one and provide PRIVATE ssh key to the `KIRA-MANAGER`)
   
   > _NOTE: If you want to stay 100% safe, you should create a new github account, and request access to `sekai` and all other repositories you want to interact with_

# Issues

Problems or issues that might occur during testing


> Problem: Visual Studio code might not be oppening folder due to memory corruption
```
# Solution: (remove working directory)

rm -rfv /usr/code && mkdir -p /usr/code
```

 