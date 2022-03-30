Name: cookbook-rb-ips
Version: %{__version}
Release: %{__release}%{?dist}
BuildArch: noarch
Summary: redborder ips cookbook to install and configure the redborder environment

License: AGPL 3.0
URL: https://github.com/redBorder/cookbook-rb-ips
Source0: %{name}-%{version}.tar.gz

%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}/var/chef/cookbooks/rb-ips
cp -f -r  resources/* %{buildroot}/var/chef/cookbooks/rb-ips/
chmod -R 0755 %{buildroot}/var/chef/cookbooks/rb-ips
install -D -m 0644 README.md %{buildroot}/var/chef/cookbooks/rb-ips/README.md

%pre

%post
case "$1" in
  1)
    # This is an initial install.
    :
  ;;
  2)
    # This is an upgrade.
    su - -s /bin/bash -c 'source /etc/profile && rvm gemset use default && env knife cookbook upload rb-ips'
  ;;
esac

%files
%defattr(0755,root,root)
/var/chef/cookbooks/rb-ips
%defattr(0644,root,root)
/var/chef/cookbooks/rb-ips/README.md

%doc

%changelog
* Tue Mar 22 2022 Miguel Negron <manegron@redborder.com> - 0.0.1
- Initial release of ips
