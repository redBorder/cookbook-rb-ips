name            'rb-ips'
maintainer      'Miguel Negron'
maintainer_email 'manegron@redborder.com'
license          'All rights reserved'
description      'Installs/Configures redborder ips'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.4'

depends 'geoip'
depends 'snmp'
depends 'rbmonitor'
depends 'ntp'
depends 'rsyslog'