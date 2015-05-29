Name:           rippled
Version:        0.28.1
Release:        1%{?dist}
Summary:        rippled daemon

License:        MIT
URL:            http://ripple.com/
Source0:        %{name}-%{version}.tar.xz
Patch0:		build-against-ripple-libs.patch

BuildRequires:  scons ripple-boost-devel protobuf-devel ripple-openssl-devel
Requires:       ripple-openssl-libs

%description
rippled

%prep
%setup -q
%patch0 -p 1

%build
OPENSSL_ROOT=/opt/ripple/openssl BOOST_ROOT=/opt/ripple/boost/ scons %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
install -D doc/rippled-example.cfg ${RPM_BUILD_ROOT}/etc/rippled/rippled.cfg
install -D build/gcc.release/rippled ${RPM_BUILD_ROOT}/%{_bindir}/rippled

%files
%doc README.md LICENSE
%{_bindir}/rippled
%{_sysconfdir}/rippled/

%changelog
