[![Build Status](https://travis-ci.org/mumuki/mumuki-bibliotheca-api.svg?branch=master)](https://travis-ci.org/mumuki/mumuki-bibliotheca-api)

# Mumuki Bibliotheca API
> Storage and formatting API for guides

## About

Bibliotheca is a service for storing Mumuki guides. Its main persistent media is MongoDB, but it is also capable of importing and exporting guides from a Github repository. Features:

* REST API
* Importing and exporting to a Github repository
* Listing and upserting guides in JSON format
* Pemissions validation
* Optional changes notifications to Aheneum

## Installing

### TL;DR install

1. Install [Vagrant](https://www.vagrantup.com/downloads.html) and [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. Run `curl https://raw.githubusercontent.com/mumuki/mumuki-development-installer/master/install.sh | bash`
3. `cd mumuki && vagrant ssh` and then - **inside Vagrant VM** - `cd /vagrant/bibliotheca`
4. Go to step 5

### 1. Install essentials and base libraries

> First, we need to install some software: MongoDB and some common Ruby on Rails native dependencies

1. Follow [MongoDB installation guide](https://docs.mongodb.com/v3.2/tutorial/install-mongodb-on-ubuntu/)
2. Run: 

```bash
sudo apt-get install autoconf curl git build-essential libssl-dev autoconf bison libreadline6 libreadline6-dev zlib1g zlib1g-dev
```

### 2. Install rbenv

> [rbenv](https://github.com/rbenv/rbenv) is a ruby versions manager, similar to rvm, nvm, and so on.

```bash
curl https://raw.githubusercontent.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc # or .bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bashrc # or .bash_profile
```

### 3. Install ruby

> Now we have rbenv installed, we can install ruby and [bundler](http://bundler.io/)

```bash
rbenv install 2.3.1
rbenv global 2.3.1
rbenv rehash
gem install bundler
gem install escualo
```

### 4. Set development variables

```bash
echo "MUMUKI_ATHENEUM_URL=... \
      MUMUKI_ATHENEUM_CLIENT_SECRET=... \
      MUMUKI_ATHENEUM_CLIENT_ID=... \
      MUMUKI_BOT_USERNAME=... \
      MUMUKI_BOT_EMAIL=... \
      MUMUKI_BOT_API_TOKEN=... \
      MUMUKI_AUTH0_CLIENT_ID=... \
      MUMUKI_AUTH0_CLIENT_SECRET=... \" >> ~/.bashrc # or .bash_profile
```

### 5. Clone this repository

> Because, err... we need to clone this repostory before developing it :stuck_out_tongue:

```bash
git clone https://github.com/mumuki/mumuki-bibliotheca
cd mumuki-bibliotheca
```

### 6. Install and setup database

```bash
bundle install
```

## Running

```bash
bundle exec rackup
```

## Running tests

```bash
bundle exec rspec
```

## Running tasks

```bash
# import guides from a github organization
bundle exec rake guides:import[<a github organization>]

# import languages from http://thesaurus.mumuki.io
bundle exec rake languages:import

# running migrations

# migration_name is the name of the migration file in ./migrations/, without extension and the "migrate_" prefeix
bundle exec rake db:migrate[<migration_name>]
```
## Authentication Powered by Auth0

<a width="150" height="50" href="https://auth0.com/" target="_blank" alt="Single Sign On & Token Based Authentication - Auth0"><img width="150" height="50" alt="JWT Auth for open source projects" src="http://cdn.auth0.com/oss/badges/a0-badge-dark.png"/></a>
