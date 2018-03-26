Name:           artist-sdk
Version:        0.0.1 
Release:        1%{?dist}
Summary:        ARTist SDK for android instrumentation using ARTist

License:        ASL 2.0
URL:            https://github.com/Project-ARTist/ARTist-SDK
Source0:        https://github.com/Project-ARTist/ARTist-SDK/raw/master/artist-sdk-%{version}.tar.gz

BuildArch:      x86_64
ExclusiveArch:  x86_64
AutoReqProv: no
Requires:       make ncurses-compat-libs 

%description
ARTist is a flexible app instrumentation system for security researchers and developers based on the Android Runtime’s dex2oat on-device compiler. Its capabilities range from (policy-driven) arbitrary code injection to inline reference monitoring, trace-logging and code-stripping. In general, ARTist can arbitrarily modify an application’s java code. In contrast to existing byte-code-rewriting approaches, applying the instrumentation during compilation ensures to keep the original apk file untouched, solving a well-known problem of many existing systems. By leaving the unmodified apk file in place, Android’s same origin model that allows for seamless app updates stays intact. This SDK allows developers to build modules for ARTist.

# Disable stripping
%global __os_install_post %{nil}
%define debug_package %{nil}

%prep
%setup -q

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT

%files
%license LICENSE
/opt/%{name}

%changelog
* Thu Mar 22 2018 Parthipan Ramesh <parthipan.ramesh@cispa.saarland> DEV_0.0.1-1
- Initial version of the package
