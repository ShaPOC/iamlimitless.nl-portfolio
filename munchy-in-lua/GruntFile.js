/**
 *   __  __             _
 *  |  \/  |___ _ _  __| |_ ___ _ _
 *  | |\/| / _ \ ' \(_-<  _/ -_) '_|
 *  |_|  |_\___/_||_/__/\__\___|_|
 *  |  \/  |_  _ _ _  __| |_ (_)___ ___
 *  | |\/| | || | ' \/ _| ' \| / -_|_-<
 *  |_|  |_|\_,_|_||_\__|_||_|_\___/__/
 *
 *  --------------------------------------------------------
 *
 *  @package    Monster Munchies
 *  @author     Jimmy Aupperlee <jimmy@galaxyraiders.net>
 *  @copyright  2014 Jimmy Aupperlee
 *  @license    http://moustachegames.net/code-license
 *  @version    0.1.0
 *  @since      File available since Release 0.1.0
 */

'use strict';

module.exports = function(grunt) {

	// Config initialisation
	var grunt_config = {};

	/**
	 * -----------------------------------------------------
	 *  BUILD
	 * -----------------------------------------------------
	 */

	grunt.loadNpmTasks('grunt-exec');
	grunt_config["exec"] = {

		"ios-project-build" : {
			"cmd" : function() {
				try {
					var config = require("./platforms/iOS/config.json");
				} catch(err) {
					grunt.fail.fatal("There seems to be something wrong with your iOS config.json file. Error given; " + err);
				}
				this.log.writeln("Building iOS project.");
				return "sudo APP_NAME='"+config.app_name+"' APP_ID='"+config.app_id+"' APP_VERSION='"+config.app_version+"' -E -H -k sh -c \"./vendor/moai/bin/create-projects-ios.sh --disable-adcolony --disable-billing --disable-chartboost --disable-crittercism --disable-facebook --disable-push --disable-tapjoy --disable-twitter ../../src\"";
			},
			"stdout": false,
			"stderr": false
		},
		"ios-post-project-build" : {
			"cmd" : function() {
				this.log.writeln("Finishing up iOS.");
				return "chown -R " + process.env.SUDO_UID + ":" + process.env.SUDO_GID + " ./vendor/moai/cmake/projects/moai-ios; rm -rf ./build/iOS; mkdir -p ./build; ln -s ../vendor/moai/cmake/projects/moai-ios/ ./build/iOS";
			},
			"stdout": false,
			"stderr": false
		},
		"android-pre-project-build" : {
			"cmd" : function() {
				try {
					var config = require("./platforms/Android/config.json");
					if(!config.ANDROID_NDK_PATH) {
						throw( 'NDK_PATH was not set, or was set incorrectly' );
					}
				} catch(err) {
					grunt.fail.fatal("There seems to be something wrong with your Android config.json file. Error given; " + err);
				}
				this.log.writeln("Building Android project. (Warning: this may take a while!)");
				return "sudo ANDROID_NDK='"+config.ANDROID_NDK_PATH+"' -E sh -H -c \"./vendor/moai/bin/build-android.sh ../../src\"";
			},
			"stdout": false,
			"stderr": false
		},
		"android-post-project-build" : {
			"cmd" : function() {
				this.log.writeln("Finishing up iOS.");
				return "chown -R " + process.env.SUDO_UID + ":" + process.env.SUDO_GID + " ./vendor/moai/release/android; rm -rf ./build/Android; mkdir -p ./build; ln -s ../vendor/moai/release/android/ ./build/Android";
			},
			"stdout": false,
			"stderr": false
		}
	};

	/**
	 * -----------------------------------------------------
	 *  COPY
	 * -----------------------------------------------------
	 */

	grunt.loadNpmTasks('grunt-contrib-copy');
	grunt_config["copy"] = {
		"ios-pre-build" : {
			files: [
				{
					mode: true,
					expand: true,
					cwd: "./platforms/iOS/",
					src: '*.sh',
					dest: './vendor/moai/bin/',
					filter: 'isFile'
				},
				{
					mode: true,
					expand: true,
					cwd: "./platforms/iOS/",
					src: '*.plist',
					dest: './vendor/moai/cmake/host-ios/',
					filter: 'isFile'
				},
				{
					mode: true,
					expand: true,
					flatten: true,
					cwd: "./platforms/iOS/Resources",
				    src: '*.png',
				    dest: './vendor/moai/src/host-ios/',
				    filter: 'isFile'
				},
				{
					mode: true,
					expand: true,
					cwd: "./platforms/iOS/Host",
					src: '*.mm',
					dest: './vendor/moai/src/host-ios/Classes',
					filter: 'isFile'
				},
				{
					mode: true,
					expand: true,
					cwd: "./platforms/iOS/Config",
					src: '*.h',
					dest: './vendor/moai/src/config-default',
					filter: 'isFile'
				},
			]
		},
		"android-pre-project-build" : {
			files: [
				{
					mode: true,
					expand: true,
					cwd: "./platforms/Android/",
					src: '*.sh',
					dest: './vendor/moai/bin/',
					filter: 'isFile'
				}
			]
		},
		"android-pre-build" : {
			files: [
				{
					mode: true,
					expand: true,
					cwd: "./platforms/Android/Stage",
					src: '*',
					dest: './vendor/moai/release/android/host'
				}
			]
		}
	};

	/**
	 * -----------------------------------------------------
	 *  CLEAN
	 * -----------------------------------------------------
	 */

	grunt.loadNpmTasks('grunt-contrib-clean');
	grunt_config["clean"] = {
		"ios-pre-project-build" : ["./vendor/moai/cmake/projects"],
		"android-pre-project-build" : ["./vendor/moai/release/android"]
	};

	/**
	 * -----------------------------------------------------
	 *  CLEAN EMPTY
	 * -----------------------------------------------------
	 */

	grunt.loadNpmTasks('grunt-cleanempty');
	grunt_config["cleanempty"] = {
		options: {
	      	force: true,
	    },
	    "mid-build": {
	      	options: {
	        	files: false,
	      	},
	      	src: ['./build']
	    },
	    "android-pre-project-build": {
	    	options: {
	        	files: false,
	      	},
	      	src: ['./vendor/moai/release']
	    }
	};

	/**
	 * -----------------------------------------------------
	 */

	// Default task.
	grunt.initConfig(grunt_config);
	grunt.task.registerTask('build', 'Build your Moai Project.', function(os) {

		if(process.env.USER != "root") {
			grunt.fail.fatal("Please run this grunt as root! It's required to build stuff.");
		}

		if( os == 'ios' ) {
			grunt.task.run(["clean:ios-pre-project-build","copy:ios-pre-build","exec:ios-project-build","cleanempty:mid-build","exec:ios-post-project-build"]);
		} else if (os == 'android') {
			grunt.task.run(["clean:android-pre-project-build", "copy:android-pre-project-build", "cleanempty:android-pre-project-build", "exec:android-pre-project-build"]);
		} else if (typeof os == 'undefined') {
			grunt.task.run(["clean:ios-pre-project-build","copy:ios-pre-build","exec:ios-project-build","cleanempty:mid-build","exec:ios-post-project-build"]);
		} else {
			grunt.fail.fatal("Unknown command inserted. OS: " + os + " not implemented.");
		}
	});
};
