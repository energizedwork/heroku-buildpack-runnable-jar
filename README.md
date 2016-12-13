Heroku buildpack: Runnable Jar
==============================

This is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpack) for JVM apps built as runnable fat JARs.
It has no opinions about or dependencies on build tools or application frameworks so is compatible with any JVM server application conforming to its CLI (see below).

This buildpack differs from most others in that it doesn't require your entire source tree to be pushed to Heroku in order to work. Instead you simply need to supply two files via git:
* `manifest.sh` - configuration values indicating the location of the JAR to be installed.
* `Procfile` - the usual Heroku Procfile for starting the app.

An advantage of this approach is that you can create a throwaway orphaned git branch containing just these two files per deployment and push this to Heroku,
massively reducing the amount of data transfer and time required.

It is highly advised to use this buildpack together with [Heroku Buildpack Runnable Jar Gradle plugin](https://github.com/energizedwork/heroku-buildpack-runnable-jar-gradle-plugin) which automates the process of creating necessary files and pushing them to a Heroku git repository to perform a deployment.

## General usage

Configure your build process to produce an all-in-one (fat) JAR containing your app. 
If using Maven, the Shade plugin will do this for you, if using Gradle, the ShadowJar plugin.

Ensure that the main() method used to start your app exhibits the following behaviour: 
* if called with no args, start the app as usual,
* if the first parameter is 'pre-deploy', run any pre-deployment steps you need to such as DB migration, then exit, setting the exit status to non-zero if the task(s) failed; the pre-deploy step can be disabled - see description of `NO_PRE_DEPLOY` in the section on [config vars](#config-vars).

When you push to a Heroku git repository for an application which uses this buildpack then a runnable jar is downloaded based on the configuration as described in the next section and the `bin` directory of the installed JDK is placed on the `PATH` for process execution (i.e. the `java` command is available to start the app).

## Configuration

There are two sources of configuration for this buildpack: files pushed to Heroku git repository and a set of [config vars](https://devcenter.heroku.com/articles/config-vars).

###  Files pushed on deployment

The following files can be used to control behaviour of the buildpack when pushing to Heroku git repositories:

| Path | Required | Description |
| --- | --- | --- |
| `manifest.sh` | Yes | A shell script that can set `ARTIFACT_URL` variable to a url from which the runnable jar being deployed is to be downloaded from. If the variable is not set no download will be performed which is useful when the artifact is included with the deployment files. |
| `Procfile` | Yes | A regular [Heroku Procfile](https://devcenter.heroku.com/articles/procfile). Note that the jar is stored as `application.jar` after downloading regardless of the file name used in `ARTIFACT_URL` variable set by `manifest.sh` file. |
| `system.properties` | No | Can be used to specify the JVM version as per [these instructions](https://devcenter.heroku.com/articles/java-support#specifying-a-java-version). The latest JVM version avialable in Heroku will be used if this file does not exist. |
| `application.jar` | No | If you wish not to download the artifact but include it in the pushed git repository then you can include it as `application.jar` and not set `ARTIFACT_URL` variable in `manifest.sh`. |
| `application.zip` | No | If you wish not to download the artifact that should be unzipped but include it in the pushed git repository then you can include it as `application.jar` and not set `ARTIFACT_URL` variable in `manifest.sh`. |

**Note:** You don't have to create any of the above files if you are using [Heroku Buildpack Runnable Jar Gradle plugin](https://github.com/energizedwork/heroku-buildpack-runnable-jar-gradle-plugin) as it will do this for you based on how you configure it.

### Config Vars

The following [config vars](https://devcenter.heroku.com/articles/config-vars) can be used to configure behaviour of the buildpack:

| Name | Description |
| --- | --- |
| `DOWNLOAD_FROM` | If the url you are downloading from requires authentication then set this variable to `snap` to use basic HTTP authentication when downloading an artifact from Snap-CI or `github-releases` to use GitHub access token when downloading from GitHub Releases. |
| `HTTP_USER` | User to be used with basic HTTP authentication when `DOWNLOAD_FROM` is set to `snap`. |
| `HTTP_PASSWORD` | User to be used with basic HTTP authentication when `DOWNLOAD_FROM` is set to `snap`. |
| `GITHUB_ACCESS_TOKEN` | GitHub access token to be used when `DOWNLOAD_FROM` is set to `github-releases`. |
| `NO_PRE_DEPLOY` | Set this var to `true` if you wish to skip the pre-deployment step where application is called with `pre-deployment` passed as the first argument. |
| `UNZIP_ARTIFACT` | Set this var to `true` if you wish to unzip the downloaded artifact. If this config var is set then the artifact is downloaded as `application.zip` and unzipped in-place. |