#!/bin/bash
declare -A SHED_PKG_LOCAL_OPTIONS=${SHED_PKG_OPTIONS_ASSOC}
SHED_PKG_LOCAL_PREFIX='/usr'
if [ -n "${SHED_PKG_LOCAL_OPTIONS[toolchain]}" ]; then
    SHED_PKG_LOCAL_PREFIX='/tools'
fi
# Patch
# Fix in-place editing file handle issue in 5.28.0, remove for 5.28.1 and later
patch -Np1 -i "${SHED_PKG_PATCH_DIR}/0001-perl-133314-always-close-the-directory-handle-on-cle.patch" || exit 1
# Configure, Build and Install
if [ -n "${SHED_PKG_LOCAL_OPTIONS[toolchain]}" ]; then
    sh Configure -des -Dprefix=${SHED_PKG_LOCAL_PREFIX} \
                      -Dlibs=-lm \
                      -Uloclibpth \
                      -Ulocincpth &&
    make -j $SHED_NUM_JOBS &&
    mkdir -pv "${SHED_FAKE_ROOT}${SHED_PKG_LOCAL_PREFIX}/bin" &&
    cp -v perl cpan/podlators/scripts/pod2man "${SHED_FAKE_ROOT}${SHED_PKG_LOCAL_PREFIX}/bin" &&
    mkdir -pv "${SHED_FAKE_ROOT}${SHED_PKG_LOCAL_PREFIX}/lib/perl5/${SHED_PKG_VERSION}" &&
    cp -Rv lib/* "${SHED_FAKE_ROOT}${SHED_PKG_LOCAL_PREFIX}/lib/perl5/${SHED_PKG_VERSION}" || exit 1
else
    # HACK: Perl depends on the presence of a hosts file
    if [ ! -e /etc/hosts ]; then
        echo "127.0.0.1 localhost $(hostname)" > /etc/hosts
    fi
        export BUILD_ZLIB=False
        export BUILD_BZIP2=0
        sh Configure -des -Dprefix=${SHED_PKG_LOCAL_PREFIX} \
                          -Dvendorprefix=${SHED_PKG_LOCAL_PREFIX} \
                          -Dman1dir=${SHED_PKG_LOCAL_PREFIX}/share/man/man1 \
                          -Dman3dir=${SHED_PKG_LOCAL_PREFIX}/share/man/man3 \
                          -Dpager="/usr/bin/less -isR" \
                          -Duseshrplib \
                          -Dusethreads &&
        make -j $SHED_NUM_JOBS &&
        make DESTDIR="$SHED_FAKE_ROOT" install || exit 1
fi
