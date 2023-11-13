# funding-frontend

## Running locally on Ubuntu WSL2

### Setting up WSL2 with Ubuntu

Firstly, check that WSL is on within Windows features.
Secondly, check that Hyper-V is on within Windows features.

Open a new windows terminal or powershell instance.

#### Install WSL 

`wsl --update --web-download`

#### Install Ubuntu 

This will install Ubuntu by default. 

Then run  

`wsl --install--web-download` 

Alternatively, list the available distros to install explicitly 

`wsl --list –online` 

`wsl –install –d Ubuntu` 

When installed.  Create a username and password (whatever you like) 

Then update: 

`sudo apt-get update` 

`sudo apt-get upgrade`

#### Allow WSL2 internet access 

Note for managed machines. To allow the virtual linux machine to access the internet, the DNS config will need to be amended to the address 8.8.8.8. This is because the local DNS server on managed machines does not work. 8.8.8.8 is Google's public DNS server. Run the commands below to amend the config and preserve it after the host machine is rebooted.

To prevent this, amend with: 

```bash 
sudo rm /etc/resolv.conf` 
sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf' 
sudo bash -c 'echo "[network]" > /etc/wsl.conf' 
sudo bash -c 'echo "generateResolvConf = false" >> /etc/wsl.conf' 
sudo chattr +i /etc/resolv.conf
```

Restart terminal to take effect.

### Install ZShell (optional) 


Z Shell is an extension of the Bourne Shell that supports custom plugins and customisation not possible with the given Bash Shell. It allows for the integration of git and other tools directly into the cmd line with oh-my-zsh.  

To install ZShell as the default terminal: 

`sudo apt-get install zsh` 

`sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" `

 
Configuring zsh/oh-my-zsh by adding the following line under the first comment of the `~/.bash.rc` file. 

Run:  

`vim  ~/.bashrc`  

and add 

```bash
if test -t 1; then 
  exec zsh 
fi 
```

Then restart your terminal instance. You should see a newly styled ZSH terminal. An example guide on how to customise the shell further to your needs can be found [here](https://blog.joaograssi.com/windows-subsystem-for-linux-with-oh-my-zsh-conemu/).  


### Install RVM

Follow the installation instructions at https://github.com/rvm/ubuntu_rvm

Follow the instructions at https://github.com/rvm/rvm for info on how to use RVM

You can test by writing some ruby

$ irb

$ puts("a string")


### Install and setup Postgres 

#### Installation 

If Postgres has been installed directly onto windows, consider removing.  It could reserve port 5432 for itself and  prevent the Ubuntu version from using the default port.  This means rails yml config would need to be changed, for your setup, to use the different port. 

See: https://learn.microsoft.com/en-us/windows/wsl/tutorials/wsl-database#install-postgresql 

To install: 

`sudo apt install postgresql postgresql-contrib` 

Then test with 

`psql –version`

Start postgres manually with the command below. There are instructions to automate later in this document.  See link for other commands:

`sudo service postgresql start`

#### Create a Postgres User  

The username should match your Ubuntu username, for which you installed Rails. 

`sudo -u postgres createuser -s <YOUR USER>`

Check the user by logging into psql with 

`sudo –u postgres psql`  

and running the list describe users cmd in the psql terminal 

```psql
 # \du; 
```

Then while still in PSQL, create the database 

```psql
 # create database funding_frontend_development;  
```

### Script startup services

These steps will sync your Ubuntu clock from the host machine, the start the postgres server when the host is started. 

Firstly allow the postgresql service and hwclock to run without sudo by navigating to the /etc/sudoers.d folder with

```
cd /etc/sudoers.d
```

Then create a new file with no full stop or tilda in the name:

```
Touch startupservices01
```

Edit the file and add the following lines.  The file must end with a new line.

```
%sudo ALL=(ALL) NOPASSWD: /usr/sbin/service postgresql *
%sudo ALL=(ALL) NOPASSWD: /usr/sbin/hwclock *
```

Next create a batch file, used by Windows startup, to start postgres and sync the clock.

First, press Windows+r, to open the run dialog, and enter:

```
shell:startup
```

This opens the startup folder.  Create a new txt file that contains:

```
wsl sudo hwclock --hctosys

wsl sudo service postgresql start
```

Save the file, then change the extension from txt to bat

Next time the host machine is started, this batch file will execute, and startupservices01 will negate the need for the user’s password.

### Installing & Running Rails

#### Postgres gem dependency

libpq-fe.h is needed to run the pg gem on Ubuntu.  These are psql devtools.

`sudo apt-get install libpq-dev`


#### bundler

`gem install bundler -v 2.3.11`

#### Rails

`gem install rails -v 7.0.6`


#### Spinning up FFE

Firstly, add the .env file.  Get this from another dev or from password manager.  Copy to the root of your cloned folder and ensure you have completed the database steps from the postres section above.

Next install gems

`bundle install`

Next install v16.14.2 of node so that the Yarn dependencies can be met

[Consider NVM](https://github.com/nvm-sh/nvm) as a way to manage and install node versions.

Next install npm if you haven't done so already

`sudo apt install nodejs npm`

Next install yarn

`sudo npm install -g yarn`

And run the yarn install:

`yarn install --check-files`

Next setup the database for FFE with

`bundle exec rails db:setup`

`bundle exec rails db:migrate`

Run `bundle exec rails db:seed` in your terminal. This will have the effect of populating
relevant database tables with the necessary rows to run the application.

Then run FFE with

`bundle exec rails server`

The application will now be running locally and can be accessed by navigating to https://localhost:3000 in your browser. Use 127.0.0.1:3000 if localhost doesn't resolve.

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

---

## Docker

If you are building the image locally, you need to change the `database.yml` file
so that `host:localhost` is commented out for the development environment:

```
development:
  <<: *default
  # comment out line below if you want to build the docker container locally.
  # host: localhost
```

Build a docker image with:

```
docker build -t [IMAGE NAME] --build-arg RAILS_RUNNING_USER=[USER NAME] .
```
If you want to push to Docker Hub, the name should be repo followed by description, then tag.  So
[IMAGE NAME] above could be myreponame/myappname:1 (where 1 is the tag).

The username must have a corresponding username on the database.

Run the image with:

```
docker run --env-file [ENV FILE FOR DOCKER] -p 3000:3000 [IMAGE NAME]

```

Docker is slightly stricter when parsing env files.

* .dockerignore
* .gitignore

will ignore a file called .dockersenv if you want a separate env
file for your docker container.

If you want to push the image to Docker Hub, ensure env files are not included, and use:

```
docker login
```

```
docker push [IMAGE NAME]
```