# Rippled package builder

An ugly hack for automating building of rippled packages inside docker.

## Usage

```
$ docker run tdfischer/rippled-deb-packager
```

## Configuration

The following properties can be tweaked with the builder:

* GIT_NAME - An environment variable for the name used when tagging the build in
  git. Defaults to "Ripple Labs Release Engineering"
* GIT_EMAIL - Environment variable for the email used when tagging the build in
  git. Defaults to releng@ripple.com
* GIT_BRANCH - Environment variable to specifiy the git branch to build.
  Defaults to 'debian'

By default, the image clones rippled into /root/build/rippled. To prevent this,
use ``-v /your/local/rippled:/root/src/rippled`` in your docker run command.
