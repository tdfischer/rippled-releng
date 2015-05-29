set -e

sudo yumdownloader --source boost
rpm -ivh boost-*.src.rpm
rpmbuild -ba boost.spec --without=mpich --without=openmpi
