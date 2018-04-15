#!/bin/bash
case "$SHED_BUILD_MODE" in
    toolchain)
        sh Configure -des -Dprefix=/tools -Dlibs=-lm &&
        make -j $SHED_NUM_JOBS &&
        mkdir -pv "${SHED_FAKE_ROOT}/tools/bin" &&
        cp -v perl cpan/podlators/scripts/pod2man "${SHED_FAKE_ROOT}/tools/bin" &&
        mkdir -pv "${SHED_FAKE_ROOT}/tools/lib/perl5/${SHED_PKG_VERSION}" &&
        cp -Rv lib/* "${SHED_FAKE_ROOT}/tools/lib/perl5/${SHED_PKG_VERSION}"
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
                          -Dusethreads &&
        make -j $SHED_NUM_JOBS &&
        make DESTDIR="$SHED_FAKE_ROOT" install
        ;;
esac
