#!/bin/bash -xe

# Thanks to:
# https://github.com/opensciencegrid/htcondor-ce/tree/master/tests

OS_VERSION=$1
PY_VER=$2
ROOT_VER=$3

echo OS_VERSION $OS_VERSION
echo PY_VER $PY_VER
echo ROOT_VER $ROOT_VER

sudo yum -y install man

uname -a
whoami

export BUILD_HOME=/home/daqbuild
export DATA_PATH=/data

# set up ROOT
len=${#ROOT_VER}
gccver=${ROOT_VER:$((${len}-3)):3}
rootver=${ROOT_VER:0:$((${len}-7))}

cd /opt/root/${rootver}-gcc${gccver}/root
ls -lZ
. ./bin/thisroot.sh

cd ${BUILD_HOME}/gem-plotting-tools

pyexec=$(which ${PY_VER})
echo Trying to test with ${pyexec}
if [ -f "$pyexec" ]
then
    virtualenv ~/virtualenvs/${PY_VER} -p ${pyexec} --system-site-packages
    . ~/virtualenvs/${PY_VER}/bin/activate
    numver=$(python -c "import distutils.sysconfig;print(distutils.sysconfig.get_python_version())")
    pip install -U pip importlib
    pip install -U setuptools
    pip install -U codecov
    pip install -U -r requirements.txt
    pip install -U root_numpy

    # coverage run python
    # codecov
    # bash <(curl -s https://codecov.io/bash) && echo "Uploaded code coverage"

    ## make tarballs and binaries
    make
    make rpm
    tar tf rpm/*.tar.gz
    tar tf rpm/*.tbz2
    rpm -q --filesbypkg -p rpm/*.rpm

    # leave virtualenv
    deactivate
fi

exit 0
