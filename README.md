# Motor
Motor is my second attempt at making an osu! server hybrid (soom:tm:) in V.

It aims for stability and performance. There'll be benchmarks soon.

# Setup
This has been tested on a Ubuntu 18.04.1

You'll need [V](https://github.com/vlang/v), [TCC (for dev)](https://zoomadmin.com/HowToInstall/UbuntuPackage/tcc), [GCC (for prod)](https://linuxize.com/post/how-to-install-gcc-compiler-on-ubuntu-18-04/) and [Git](https://linuxize.com/post/how-to-install-git-on-ubuntu-18-04/).
```
$ git clone https://github.com/barrack-obama/Motor
...

$ cd Motor
Motor$ git submodule init && git submodule update

// for development
Motor$ make dev 

// for production
Motor$ make prod
```

# More
more information will come soon.
