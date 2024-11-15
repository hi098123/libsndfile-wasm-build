#!/usr/bin/env bash

#TYPE YOUR EMSDK DIR
EMSDK_PATH='/home/hi098123/emsdk'
if ! [ -d $EMSDK_PATH ] 
then
    echo ''
    echo '[ERROR] TYPE YOUR EMSDK DIR IN SCRIPT FIRST'
    echo ''
    exit
fi

#Original url
#mpg123_tarbz2='https://downloads.sourceforge.net/project/mpg123/mpg123/1.32.9/mpg123-1.32.9.tar.bz2'
#lame_targz='https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz'
#opus_targz='https://downloads.xiph.org/releases/opus/opus-1.5.2.tar.gz'

#Github copied
mpg123_tarbz2='https://github.com/hi098123/libsndfile-wasm-build/raw/refs/heads/1.2.2/mpg123-1.32.9.tar.bz2'
lame_targz='https://github.com/hi098123/libsndfile-wasm-build/raw/refs/heads/1.2.2/lame-3.100.tar.gz'
opus_targz='https://github.com/hi098123/libsndfile-wasm-build/raw/refs/heads/1.2.2/opus-1.5.2.tar.gz'

BUILD_PATH=$PWD

cd $EMSDK_PATH
./emsdk install latest
./emsdk activate latest
source ./emsdk_env.sh

cd $BUILD_PATH

HI_INSTALL='mpg123-1.32.9'
if [ -d $HI_INSTALL ] 
then
    echo "==== 이미 설치됨($HI_INSTALL) ===="
else
    echo "==== 복제 시작($HI_INSTALL) ===="
    ## https://mpg123.org/ https://sourceforge.net/projects/mpg123/
    wget -O mpg123-1.32.9.tar.bz2 $mpg123_tarbz2
    tar -jxvf mpg123-1.32.9.tar.bz2
    rm mpg123-1.32.9.tar.bz2
    cd mpg123-1.32.9
    CFLAGS="-sUSE_SDL=2" emconfigure ./configure --with-cpu=generic --enable-static=yes --enable-shared=no
    emmake make
    unset CFLAGS

    cd ..
    echo "==== 복제 성공($HI_INSTALL) ===="
fi

unset HI_INSTALL
HI_INSTALL='lame-3.100'
if [ -d $HI_INSTALL ] 
then
    echo "==== 이미 설치됨($HI_INSTALL) ===="
else
    echo "==== 복제 시작($HI_INSTALL) ===="
    # https://lame.sourceforge.io/download.php
    wget -O lame-3.100.tar.gz $lame_targz
    tar -zxvf lame-3.100.tar.gz
    rm lame-3.100.tar.gz
    cd lame-3.100
    emconfigure ./configure --with-cpu=generic --enable-static=yes --enable-shared=no --disable-frontend
    emmake make
    mkdir include2
    mkdir include2/lame
    cp -r include/* include2/lame

    cd ..
    echo "==== 복제 성공($HI_INSTALL) ===="
fi

unset HI_INSTALL
HI_INSTALL='ogg'
if [ -d $HI_INSTALL ] 
then
    echo "==== Git 저장소: 이미 설치됨($HI_INSTALL) ===="
else
    echo "==== Git 저장소: 복제 시작($HI_INSTALL) ===="
    git clone --recursive -b 'v1.3.5' 'https://github.com/xiph/ogg' $HI_INSTALL
    cd $HI_INSTALL
    emcmake cmake .
    emmake make

    cd ..
    echo "==== Git 저장소: 복제 성공($HI_INSTALL) ===="
fi

unset HI_INSTALL
HI_INSTALL='opus-1.5.2'
if [ -d $HI_INSTALL ] 
then
    echo "==== 이미 설치됨($HI_INSTALL) ===="
else
    echo "==== 복제 시작($HI_INSTALL) ===="
    wget -O opus-1.5.2.tar.gz $opus_targz
    tar -zxvf opus-1.5.2.tar.gz
    rm opus-1.5.2.tar.gz
    cd opus-1.5.2
    emconfigure ./configure --host=wasm32 --enable-static=yes --disable-rtcd
    emmake make
    mkdir include2
    mkdir include2/opus
    cp -r include/* include2/opus

    cd ..
    echo "==== 복제 성공($HI_INSTALL) ===="
fi

unset HI_INSTALL
HI_INSTALL='vorbis'
if [ -d $HI_INSTALL ] 
then
    echo "==== Git 저장소: 이미 설치됨($HI_INSTALL) ===="
else
    echo "==== Git 저장소: 복제 시작($HI_INSTALL) ===="
    git clone --recursive -b 'v1.3.7' 'https://github.com/xiph/vorbis' $HI_INSTALL
    cd $HI_INSTALL
    emcmake cmake . -DOGG_INCLUDE_DIR=../ogg/include  -DOGG_LIBRARY=../ogg/libogg.a
    emmake make

    cd ..
    echo "==== Git 저장소: 복제 성공($HI_INSTALL) ===="
fi

unset HI_INSTALL
HI_INSTALL='flac'
if [ -d $HI_INSTALL ] 
then
    echo "==== Git 저장소: 이미 설치됨($HI_INSTALL) ===="
    #exit 
else
    echo "==== Git 저장소: 복제 시작($HI_INSTALL) ===="
    git clone --recursive -b '1.4.3' 'https://github.com/xiph/flac' $HI_INSTALL
    cd $HI_INSTALL
    emcmake cmake . -DOGG_INCLUDE_DIR=../ogg/include  -DOGG_LIBRARY=../ogg/libogg.a -DINSTALL_MANPAGES=OFF -DBUILD_PROGRAMS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_TESTING=OFF -DWITH_STACK_PROTECTOR=OFF
    emmake make

    cd ..
    echo "==== Git 저장소: 복제 성공($HI_INSTALL) ===="
fi

if ! command -v emcc &> /dev/null
then
    echo '[emcc] could not be found (먼저 emsdk활성화 필요)

https://emscripten.org/docs/getting_started/downloads.html

(EX)
cd emsdk
./emsdk install latest
./emsdk activate latest
source ./emsdk_env.sh
'
    exit
fi

GIT_DIR='libsndfile'

if [ -d $GIT_DIR ] 
then
    echo "==== Git 저장소: 이미 설치됨 ===="
else
    echo "==== Git 저장소: 복제 시작 ===="
    git clone --recursive -b '1.2.2' 'https://github.com/libsndfile/libsndfile' $GIT_DIR
    echo "==== Git 저장소: 복제 성공 ===="
fi

cd $GIT_DIR

LDFLAGS="
  -O3\
  -s EXPORTED_RUNTIME_METHODS=['callMain','FS']\
  -s WASM=1\
  -s ALLOW_MEMORY_GROWTH=1\
  -s INVOKE_RUN=0\
  -lworkerfs.js\
"
export LDFLAGS

emcmake cmake \
    -DENABLE_EXTERNAL_LIBS=ON -DBUILD_TESTING=OFF \
    -DFLAC_INCLUDE_DIR=../flac/include -DFLAC_LIBRARY=../flac/src/libFLAC/libFLAC.a \
    -DOGG_INCLUDE_DIR=../ogg/include  -DOGG_LIBRARY=../ogg/libogg.a\
    -DOPUS_INCLUDE_DIR=../opus-1.5.2/include2 -DOPUS_LIBRARY=../opus-1.5.2/.libs/libopus.a\
    -DVorbis_Vorbis_INCLUDE_DIR=../vorbis/include -DVorbis_Vorbis_LIBRARY=../vorbis/lib/libvorbis.a \
    -DVorbis_Enc_INCLUDE_DIR=../vorbis/include -DVorbis_Enc_LIBRARY=../vorbis/lib/libvorbisenc.a \
    -DVorbis_File_INCLUDE_DIR=../vorbis/include -DVorbis_File_LIBRARY=../vorbis/lib/libvorbisfile.a \
    -DMP3LAME_INCLUDE_DIR=../lame-3.100/include2 -DMP3LAME_LIBRARY=../lame-3.100/libmp3lame/.libs/libmp3lame.a\
    -Dmpg123_INCLUDE_DIR=../mpg123-1.32.9/src/include -Dmpg123_LIBRARY=../mpg123-1.32.9/src/libmpg123/.libs/libmpg123.a

emmake make VERBOSE=1