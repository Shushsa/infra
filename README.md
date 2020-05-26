
# Infrastructure

Kira Full Stack Development, Deployment, Testing and Automation Tools

# Prerequisites

_NOTE: Because many users might have access to this repository or apply changes to this repository that might compromise your environment, it is mandatory for everyone to utilise VM as your working environment._

## Workstation Setup

_NOTE: To maintain consistency among all working environments we will utilise `Ubuntu 20.04 LTS` as a mandatory OS for your workstation_

For the purpose of setting up development environment we will 

1. Install [VMWare Workstation 15.5+](https://www.vmware.com/products/workstation-player/workstation-player-evaluation.html)
   
2. Download and Install [Ubuntu 20.04 LTS](https://releases.ubuntu.com/20.04/) with VMWare
   * Recommended VM Setup
     * CPU: 2 virtualized cores
     * RAM: 8 GB
     * Disk: 64 GB (SSD or NVMe)
3. Boot your machine, and ensure latest updates are applied using `Software Updater`

   ![picture 1](https://i.imgur.com/7SX2g7y.png)

4. Reboot & Open terminal to execute following command


    _NOTE: You will be prompted to input branch names you are working with as well as email address where you will receive notifications_

```
cd /tmp && wget -O - https://raw.githubusercontent.com/KiraCore/infra/master/workstation/init.sh | sudo bash
```

5. (OPTIONAL) If you want to receive email notifications you can edit `nano /etc/profile` and edit `SMTP_SECRET` environment variable by defining your SMTP auth secrets. If you are using gmail you will have to setup 2FA and [enable less secure apps](https://support.google.com/accounts/answer/6010255?hl=en).


# [ Local ] Kira Network

## Test Accounts

_NOTE: Nodes are seeded with existing accounts and demo tokens. Test accounts can be used for general purpose, consensus or governance tests. Default password is `1234567890`_

* test-1: `kira1ufak8sc7g6w7pnlmalq9adqmj7cktcrk073ctz`
* test-2: `kira14fx5q9su3h2ptevmxv7y3lnmn07dfdkdlujdd9`
* test-3: `kira1cda90gj4etquxlhmptpvwrxy0clmqhye8tjp2l`
* test-4: `kira1zhjn2493ez43hwsd5n45yxv88qmruy79lptftf`

* faucet: `kira17329rnrg8uwc0lgvnc25tynh8vemjmd799hvtl`

* validator-1: `kira1l35kjmuupwhn4tevfm4ykj9hgrfvmpwjazpqft`
* validator-2: `kira1v72chlsvgckt6d9r2379kpq0ce0r2uzltpp8x0`
* validator-3: `kira1y0ulj7emawx9ry09c4kuktq04ugkgf5z4hhe64`
* validator-4: `kira1dyscprnsg6gef5enpyzqg69mdc2mcegq89def5`

## Test Node Keys

_NOTE: Nodes are seeded with existing node keys to enable custom networking and consistent testing_

* node-key-1: `fe3b878a9878d2448b6b04470bf53a697ea7f4cc`
* node-key-2: `957db00b77d9da860378027b44f1c7acc631fc34`
* node-key-3: `624c8e3e750b963e2839729cae0e4ffb0668a039`
* node-key-4: `99fe36e27d676711892798d9aacd58d2ddb90df5`

## Signing Keys

_NOTE: Nodes are seeded with existing validator signing keys and can be used to test features such as double signing_

* signing-1
* signing-2
* signing-3
* signing-4
