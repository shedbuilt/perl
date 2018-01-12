#!/bin/bash
case "$SHED_BUILDMODE" in
    toolchain)
        sh Configure -des -Dprefix=/tools -Dlibs=-lm || return 1
        make -j $SHED_NUMJOBS || return 1
        mkdir -pv "${SHED_FAKEROOT}/tools/bin"
        cp -v perl cpan/podlators/scripts/pod2man "${SHED_FAKEROOT}/tools/bin"
        mkdir -pv "${SHED_FAKEROOT}/tools/lib/perl5/5.26.1"
        cp -Rv lib/* "${SHED_FAKEROOT}/tools/lib/perl5/5.26.1"
        ;;
    *)
        if [ ! -e /etc/hosts ]; then
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
                          -Dusethreads || return 1
        make -j $SHED_NUMJOBS || return 1
        make DESTDIR="$SHED_FAKEROOT" install || return 1
        ;;
esac
