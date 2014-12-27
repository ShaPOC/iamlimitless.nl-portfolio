# WARNING: This is an incomplete and non-functioning source!

All information provided below and in this repository is to show the progress made in this six-week project. Resources and information not made by me (Jimmy Aupperlee) is removed.
This repository exists solely for showcasing my work on [http://iamlimitless.nl](http://iamlimitless.nl).

# Munchy

All the necessary information for contributing to this project is displayed in this file. 

## Quick details ##

* Game version 0.1.0
* Lua version 5.1.5
* Moai version 1.5
* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo) to contribute to this readme.

## Project Setup ##

First and foremost, the path to your project may not contain any special characters; NOT EVEN SPACES!

### Grunt
We are using Grunt which requires node.js and NPM to run, so first install node.js and npm on your system. We will not be explaining this here, so we suggest you follow the instructions for your operating system on; [The website of node.js](http://nodejs.org/). 
In order to run grunt, we require some npm modules, which are stated in the package.json. Run:

    sudo npm install -g grunt-cli
    cd <the-project-directory>
    sudo npm install

and, provided you don't get any errors, you are done with installing grunt!

### Moai
This one is a bit trickier. First and foremost, you will need to install Moai as described here; [moai-dev GitHub](https://github.com/moai/moai-dev/blob/master/README.md).
Once you are done with this, we need to fetch the Moai Dev repository into our project directory for Grunt to use. This is quite easy to do, seeing as this is prepared for you. Just execute the following commands from the root of your project directory;

	git submodule init
	git submodule update

And update the sumbodules inside the moai clone as well

	cd ./vendor/moai
	git submodule init
	git submodule update

and, that's about it really...

## Compiling

## iOS

If you have correctly installed everything according to the Project Setup part of this readme. Then you should be all set and can easily compile your iOS xcode project files by typing in the following command;

	sudo grunt build:ios

All the other stuff is done for you automatically. Neat huh?

## Android (Under construction)

If you wish to build for Android, you are going to need a few more steps beforehand. But on the bright side, this will build the application immediately, without creating a project first.
First and foremost, you are going to need the [Android NDK available here](https://developer.android.com/tools/sdk/ndk/index.html). Extract the package suitable for your os somewhere where you like it to be.
Afterwards, set your NDK path in the config.json file included in the platforms/Android directory.

Now you can build the project if you'd like. But I'd reccomend you change the settings in each file present in the platforms/Android directory. Many personal Android related settings can be done here which
will be included in the final project build. When done with that just type;

	sudo grunt build:android

## Contribution guidelines ##

## Git Branches ###

When contributing to this repository please use the correct branch! We use [git-flow](http://nvie.com/posts/a-successful-git-branching-model/) for a successful branching model.

## Responsibility ##

* Lead developer - Jimmy Aupperlee (jimmy@moustachegames.net)
* Lead designer - Antonie Hogewoning (antonie@moustachegames.net)
* Lead artist - Ricardo Snoek (ricardo@moustachegames.net)
