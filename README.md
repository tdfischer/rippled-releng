# Rippled Release Tools

This repository contains various tools for packaging up rippled in our various
supported formats.

## Debian

```
$ docker run -t -i -v ~/.gnupg:/root/.gnupg tdfischer/rippled-packager
```

To work on the rippled package:

```
$ docker run -t -i -v ~/.gnupg:/root/.gnupg --entrypoint /bin/bash -u $UID tdfischer/rippled-packager
```

### Testing the repo

```
$ docker run -t -i tdfischer/rippled-apt-tester
```
