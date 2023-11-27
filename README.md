# funding-frontend

**HP Z-Book Set up**

**Install WSL** in windows terminal with the cmd:
```bash
wsl --update --web-download
```

This will install Ubuntu by default.

Then run

```bash
wsl –-install --web-download
```
Alternatively, list the available distros to install explicitly

```bash
wsl --list -–online

wsl –install –d Ubuntu
```

When installed. Create a username and password (whatever you like)

Then update:

```bash
sudo apt-get update

sudo apt-get upgrade
```

Note: if the distro has no internet access, see next section.

## **Allow WSL2 internet access**

To allow the virtual linux machine to access the internet, the DNS config will need to be amended to the address 8.8.8.8. This is because the local DNS server on managed machines does not work. 8.8.8.8 is Google's public DNS server. Run the commands below to amend the config and preserve it after the host machine is rebooted.

If you see 'rm: cannot remove '/etc/resolv.conf': Operation not permitted' go to: [https://support.tools/post/fix-stuck-resolv-conf/](https://support.tools/post/fix-stuck-resolv-conf/)

```bash
sudo rm /etc/resolv.conf
sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
sudo bash -c 'echo "[network]" > /etc/wsl.conf'
sudo bash -c 'echo "generateResolvConf = false" >> /etc/wsl.conf'
sudo chattr +i /etc/resolv.conf
```

Restart terminal to take affect

Then update again:

```bash
sudo apt-get update

sudo apt-get upgrade
```

## **Install Postgres**

If Postgres has been installed directly onto windows, consider removing. It could reserve port 5432 for itself and prevent the Ubuntu version from using the default port. This means FFE will not start – the app's rails yml config _can_ be changed to use the different port, but this yml should not be pushed to source control.

See: [https://learn.microsoft.com/en-us/windows/wsl/tutorials/wsl-database#install-postgresql](https://learn.microsoft.com/en-us/windows/wsl/tutorials/wsl-database#install-postgresql)

To install:

```bash
sudo apt install postgresql postgresql-contrib
```

Then test with

```bash
psql –version
```

Start postgres with the command below. There are instructions to automate later in this document. See link for other commands:

```bash
sudo service postgresql start
```

### **Create a Postgres User**

The username should match your Ubuntu username, for which you installed Rails.

```bash
$ sudo -u postgres createuser -s [YOUR USER]
```

Check the user by logging into psql with

```bash
psql postgres

\du
```

Then while still in PSQL, create the database

create database funding\_frontend\_development;

These articles also helped with the postgresql:

[https://stackoverflow.com/questions/65222869/how-do-i-solve-this-problem-to-use-psql-psql-error-fatal-role-postgres-d](https://stackoverflow.com/questions/65222869/how-do-i-solve-this-problem-to-use-psql-psql-error-fatal-role-postgres-d)

[https://kb.objectrocket.com/postgresql/how-to-completely-uninstall-postgresql-757](https://kb.objectrocket.com/postgresql/how-to-completely-uninstall-postgresql-757)

[https://www.postgresql.org/download/linux/ubuntu/](https://www.postgresql.org/download/linux/ubuntu/)

###

###

### **Script startup services**

These steps will sync your Ubuntu clock from the host machine, the start the postgres server when the host is started.

Firstly allow the postgresql service and hwclock to run without sudo by navigating to the /etc/sudoers.d folder with

```bash
cd /etc/sudoers.d
```

Then create a new file with no full stop or tilda in the name:

Touch startupservices01

Edit the file and add the following lines. The file **must** end with a new line.

%sudo ALL=(ALL) NOPASSWD: /usr/sbin/service postgresql \*

%sudo ALL=(ALL) NOPASSWD: /usr/sbin/hwclock \*

Next create a batch file, used by Windows startup, to start postgres and sync the clock.

First, press WIndows+r, to open the run dialog, and enter:

shell:startup

This opens the startup folder. Create a new txt file that contains:

wsl sudo hwclock --hctosys

wsl sudo service postgresql start

Save the file, then change the extension from txt to bat

Next time the host machine is started, this batch file will execute, and startupservices01 will negate the need for the user's password.

### **GIT**

Resources: [https://docs.github.com/en/authentication/connecting-to-github-with-ssh/checking-for-existing-ssh-keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/checking-for-existing-ssh-keys)

Ubuntu rolls out with Git installed. Following steps assume you are happy with the installed version of Git:

Update the global settings for Git:

```bash
git config --global user.name "Your name"

git config --global user.email "your git email"
```

Next, check for any existing ssh keys. You'll get a no such file/directory error if none exist:

```bash
ls –al /.ssh
```
If you have no keys, generate one (otherwise read resources above)

```bash
ssh-keygen -t ed25519 -C "your\_email.com"
```
Then start the ssh agent to add the key to:

```bash
$ eval "$(ssh-agent -s)"
```

Next add the key to the agent. You will be prompted for a passphrase here if your key uses one

```bash
$ ssh-add ~/.ssh/id\_ed25519
```

Next login to Github on your browser, and in setting for your user, add the contents of your public key. You can get this with:

```bash
$ cat ~/.ssh/id\_ed25519.pub
```

And save with a nice alias for your HP Z-book.

###

### **Download Docker Desktop**

Go here and download Docker Desktop for your machine: [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)

Select open on start-up and use wsl2 instead of Hyper-V then restart when prompted

Sign up to Docker Hub and ensure docker is installed by running 'docker' in your terminal.

**Set up Dev Containers in VSC**

Download the Remote Explorer Extension package in the extension manager. Id: ms-vscode.remote-explorer

In your VSC settings search 'WSL' and turn on the below:

Enable 'Execute in WSL' in the user settings:
 ![](RackMultipart20230908-1-p105f0_html_5b8a905a91bcfd26.png)

Start to build your dev container, use the ctrl p then:

' \> Dev Containers – Clone Repository in Container Volume '

Enter the url of the repo you want to clone - [https://github.com/heritagefund/funding-frontend.git](https://github.com/heritagefund/funding-frontend.git)

When building your dev container use the Ruby on Rails (Community) template image, choose 3.1 then 16 with the below addons:

(potentially add to this list)

POSTGRESQL

**Run FFE**

Make sure to add a .ENV file to the cloned repo in VSC.

The dev container should be connected to your local PostgreSQL by using the appropriate database.yml and .env files. Reach out to a colleague for these if you don't have them.

Then in the terminal use the command

```bash
Bundle install

rails db:setup
```

```bash
yarn install --check-files
```

You should then be able to run the rails server.

**SECURITY**

To ensure that we remain secure we recommend adding Talisman to your machine or to each repo depending on your preference. Talisman will scan your commit for any unwanted credentials or secrets. 

To add to your machine - https://github.com/thoughtworks/talisman#installation-as-a-global-hook-template (This does not persist on to dev containers, I would recommend adding it to each repo within a dev container also, once it has been added it should stay after rebuild) 

To add to a single repo - https://github.com/thoughtworks/talisman#installation-to-a-single-project (use this within dev containers) 

If you choose to set the $PATH later, please export TALISMAN_HOME=$HOME/.talisman/bin to the path. To set the path in a dev container put the below line in your Dockerfile and rebuild your container: 

ENV PATH="$PATH:/workspaces/funding-frontend/.git/hooks/bin" 

Potential Issue: 

If the .talismanrc file is not ignoring a file, run this command: 

```bash
talisman --checksum <filename> 
```

This will resync the checksum and allow the file to be ignored. 

You can also run talisman in interactive mode so that this is done automatically  

```bash
talisman -i -g pre-commit 
```

 >>> talisman >>> # Below environment variables should not be modified unless you know what you a$ export TALISMAN_HOME=/Users/jackdouglas/.talisman/bin alias talisman=$TALISMAN_HOME/talisman_darwin_amd64 export TALISMAN_INTERACTIVE=true # <<< talisman <<< 

**Tech\_Docs set up:**

Start to build your dev container, use the ctrl p then:

' \> Dev Containers – Clone Repository in Container Volume '

Enter the url of the repo you want to clone - [https://github.com/heritagefund/tech-docs.git](https://github.com/heritagefund/tech-docs.git)

The image is the basic Ruby image with Node.js added, if it fails on the first build rebuild it with the below devcontainer.json:.

Here is the devcontainer.json:

```bash
{

"name": "Ruby",

"image": "mcr.microsoft.com/devcontainers/ruby:1-3.0-buster",

"features": {

"ghcr.io/devcontainers/features/ruby:1": {

"version": "2.6.5"

},

"node": {

"version": "lts",

"nodeGypDependencies": true

}
```

Run:

gem install bundler:2.1.4 (must be this version of bundler)

bundle install

Initialise middleman and install dependencies

$ middleman init (When prompted to overwrite files, do not overwrite)

$ middleman build

Install all bundle dependencies

$ bundle install

Restart you terminal and run middleman server

$ bundle exec middleman server

Tech Docs middleman should now be running on [http://localhost:4567](http://localhost:4567/) in browser.

## Download CF Tools:

[https://github.com/cloudfoundry/cli/wiki/V8-CLI-Installation-Guide](https://github.com/cloudfoundry/cli/wiki/V8-CLI-Installation-Guide)

...first add the Cloud Foundry Foundation public key and package repository to your system

```bash
wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
```
...then, update your local package index, then finally install the cf CLI

```bash
sudo apt-get update
sudo apt-get install cf8-cli
```

Once logged in use the below command to install the conduit plugin

```bash
cf install-plugin -r CF-Community "conduit"
```

Cloud Foundry Commands:

Cloud Foundry commands:

login:

```bash
cf login -a api.london.cloud.service.gov.uk -u \<your email\>
```

connect via conduit:

```bash
cf conduit funding-frontend-research -- psql
```
Connect on different port

```bash
cf conduit funding-frontend-research --local-port 7081 -- psql
```

change target

```bash
cf target -s sandbox
```
get logs

```bash
cf logs funding-frontend-staging
```

**Misc:**

Tests must be run with the 'bundle exec' prefix – this seems to be the case with most commands within a dev container.

### Install RVM

Follow the installation instructions at https://github.com/rvm/ubuntu_rvm

Follow the instructions at https://github.com/rvm/rvm for info on how to use RVM

You can test by writing some ruby

$ irb

$ puts("a string")

To get past the open-ssl issue run this command

`sudo apt install libssl-dev=1.1.1l-1ubuntu1.4  openssl=1.1.1l-1ubuntu1.4`

## Running the automated test suite

### RSpec

Server-side code is tested using [RSpec](https://rspec.info).

To run the RSpec test suite, run `bundle exec rspec` in your terminal.

### Jest

Client-side code is tested using [Jest](https://jestjs.io).

To run the Jest test suite, run `yarn jest` in your terminal.

---

## Caching

Addresses are cached after searching by postcode so that they can be referred to later in the user journey. 
By default, Ruby-on-Rails in development mode runs with caching disabled. In order to see caching work in 
development, run `bundle exec rails dev:cache` in your terminal.

---

## Toggling feature flags

Some elements of functionality are sat behind feature flags, which have been implemented using 
[Flipper](https://github.com/jnunemaker/flipper).

To toggle functionality, a Flipper needs to exist. Flipper rows exist within the `flipper_features` and 
`flipper_gates` tables on the database. The `flipper_gates` are populated with a database migration. 
The `flipper_features` are populated at app runtime, provided rows exist in `flipper.rb`.

Update a `flipper_gates` row by running a SQL statement such as (after running 
`psql funding_frontend_development` in your terminal to connect to the database):

```postgresql
UPDATE flipper_gates SET value = true WHERE feature_key = '<key_name>';   
```

