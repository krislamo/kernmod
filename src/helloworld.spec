Name: helloworld
Version: 0.1
Release: 1%{?dist}
Summary: hello, world
BuildArch: noarch

License: 0BSD
Source0: %{name}-%{version}.tar.gz
Requires: dkms

%description
hello, world example

%prep
%setup -q
%build
%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/%{_usrsrc}/%{name}-%{version}
mkdir -p $RPM_BUILD_ROOT/etc
cp -r usr/src/* $RPM_BUILD_ROOT/%{_usrsrc}/%{name}-%{version}
cp -r etc/* $RPM_BUILD_ROOT/etc

%clean
rm -rf $RPM_BUILD_ROOT

%files
%{_usrsrc}/%{name}-%{version}/dkms.conf
%{_usrsrc}/%{name}-%{version}/helloworld.c
%{_usrsrc}/%{name}-%{version}/Makefile
/etc/modules-load.d/%{name}.conf

%post
dkms add -m %{name} -v %{version}
dkms build -m %{name} -v %{version}
dkms install -m %{name} -v %{version}
modprobe %{name}
