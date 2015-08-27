Heroku buildpack: Runnable Jar
==============================

This is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpack) for JVM apps built as runnable fat JARs.
It has no opinions about or dependencies on build tools or application frameworks so is compatible with any JVM server application conforming to its CLI (see below).

This buildpack differs from most others in that it doesn't require your entire source tree to be pushed to Heroku in order to work. Instead you simply need to supply two files via git:
* manifest.sh - configuration values indicating the location of the JAR to be installed, hints about how to download it and a deployment counter (more on this below).
* Procfile - the usual Heroku Procfile for starting the app.

An advantage of this approach is that you can create a throwaway orphaned git branch containing just these two files per deployment and push this to Heroku,
massively reducing the amount of data transfer and time required.

## Usage

1. Specify the Java version to be used as per [these instructions](https://devcenter.heroku.com/articles/java-support#specifying-a-java-version).
2. Configure your build process to produce an all-in-one (fat) JAR containing your app. If using Maven, the Shade plugin will do this for you, if using Gradle, the ShadowJar plugin.
3. Ensure that the main() method used to start your app exhibits the following behaviour: if called with no args, start the
  app as usual. If the first parameter is 'pre-deploy', run any pre-deployment steps you need to such as DB migration, then exit, setting the exit status to non-zero if the task(s) failed.
4. Add a [Procfile](https://devcenter.heroku.com/articles/procfile) to your project defining how to launch the app.

The `bin` directory of the installed JDK is placed on the `PATH` for process execution (i.e. the `java` command is available to start the app).