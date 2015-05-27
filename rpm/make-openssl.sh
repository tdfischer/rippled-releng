set -e

sudo yumdownloader --source openssl
rpm -ivh openssl-*.src.rpm
cp ec_curve.c ~/rpmbuild/SOURCES/ec_curve.c
rpmbuild -ba openssl.spec
