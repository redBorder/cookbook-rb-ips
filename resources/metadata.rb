name            'rb-ips'
maintainer      'Miguel Negron'
maintainer_email 'manegron@redborder.com'
license          'All rights reserved'
description      'Installs/Configures redborder ips'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.3'

depends 'geoip'
depends 'snmp'
depends 'rbmonitor'
depends 'rsyslog'
depends 'snort'
depends 'barnyard2'
depends 'rb-selinux'
#depends 'ohai'
depends 'cron'
depends 'rbcgroup'
