# frozen_string_literal: true

name             'rb-ips'
maintainer       'Eneo Tecnología S.L.'
maintainer_email 'git@redborder.com'
license          'AGPL-3.0'
description      'Installs/Configures redborder ips'
version          '2.2.2'

depends 'rb-common'
depends 'geoip'
depends 'snmp'
depends 'rbmonitor'
depends 'rsyslog'
depends 'snort'
depends 'barnyard2'
depends 'rb-selinux'
depends 'cron'
depends 'rbcgroup'
depends 'rb-clamav'
depends 'rb-chrony'
depends 'rb-exporter'
depends 'rb-firewall'
