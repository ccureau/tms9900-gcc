FROM centos:6

ENV BINUTILS_VERSION binutils-2.19.1
ENV GCC_VERSION gcc-4.4.0
ENV GMP_VERSION=gmp-4.1.4
ENV MPFR_VERSION=mpfr-2.4.2

ENV PREFIX /opt/tms9900/$GCC_VERSION
ENV TARGET tms9900
ENV ENABLE_LANGUAGES c
ENV PATH=$PATH:$PREFIX/bin

RUN yum update -y && yum install -y texinfo wget unzip gcc patch make srecord

ADD files /tmp/patch

RUN bash \
  && mkdir /tmp/downloads && cd /tmp/downloads \
  && wget https://ftp.gnu.org/pub/gnu/binutils/$BINUTILS_VERSION.tar.bz2 \
  && wget https://ftp.gnu.org/pub/gnu/gcc/$GCC_VERSION/$GCC_VERSION.tar.bz2 \
  && wget https://ftp.gnu.org/gnu/gmp/$GMP_VERSION.tar.gz \
  && wget https://ftp.gnu.org/gnu/mpfr/$MPFR_VERSION.tar.gz \
  && mkdir /tmp/build && cd /tmp/build \
  && tar jxf ../downloads/$BINUTILS_VERSION.tar.bz2 \
  && pushd $BINUTILS_VERSION && patch -p1 </tmp/patch/binutils-2.19.1-tms9900-1.7.patch && popd \
  && tar jxf ../downloads/$GCC_VERSION.tar.bz2 \
  && pushd $GCC_VERSION && patch -p1 </tmp/patch/gcc-4.4.0-tms9900-1.19.patch && popd \
  && tar zxf ../downloads/$MPFR_VERSION.tar.gz && mv $MPFR_VERSION /tmp/build/$GCC_VERSION/mpfr \
  && tar zxf ../downloads/$GMP_VERSION.tar.gz && mv $GMP_VERSION /tmp/build/$GCC_VERSION/gmp \
  && rm -v /tmp/downloads/* /tmp/patch/* \
  &&  mkdir /tmp/build/binutils-obj && cd /tmp/build/binutils-obj \
  && ../$BINUTILS_VERSION/configure --prefix=$PREFIX --target=$TARGET --disable-build-warnings \
  && make \
  && make install \
  && mkdir /tmp/build/gcc-obj && cd /tmp/build/gcc-obj \
  && ../$GCC_VERSION/configure --prefix=$PREFIX --target=$TARGET --enable-languages=$ENABLE_LANGUAGES --disable-libmudflap --disable-libssp --disable-libgomp --disable-libstdcxx-pch --disable-threads --disable-nls --disable-libquadmath --with-gnu-as --with-gnu-ld --without-headers \
  && make all-gcc all-target-libgcc \
  && make install \
  && cd /tmp/build/gcc-obj \
  && make all-target-libgcc \
  && make install-target-libgcc \
  && rm -rf /tmp/build /tmp/downloads
