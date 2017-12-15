#!/bin/bash
if [ ! -r /etc/hosts ]; then
    echo "127.0.0.1 localhost $(hostname)" > /etc/hosts
fi
export BUILD_ZLIB=False
export BUILD_BZIP2=0
sh Configure -des -Dprefix=/usr                 \
                  -Dvendorprefix=/usr           \
                  -Dman1dir=/usr/share/man/man1 \
                  -Dman3dir=/usr/share/man/man3 \
                  -Dpager="/usr/bin/less -isR"  \
                  -Duseshrplib                  \
                  -Dusethreads
make -j $SHED_NUMJOBS
make DESTDIR=${SHED_FAKEROOT} install
unset BUILD_ZLIB BUILD_BZIP2
