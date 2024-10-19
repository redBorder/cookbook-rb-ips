cookbook-rb-ips CHANGELOG
===============

## 2.0.0

  - Miguel Negrón
    - [4193508] Merge pull request #52 from redBorder/improvement/#18961_service_list_without_chef

## 1.2.0

  - Miguel Negrón
    - [639edd5] Merge pull request #48 from redBorder/bugfix/#18863_license_in_settings

## 1.1.0

  - Miguel Negron
    - [0fbc4cc] Fix name redborder-monitor instead of rb-monitor in sudoers file

## 1.0.1

  - Miguel Negrón
    - [575337d] Add pre and postun to clean the cookbook

## 1.0.0

  - Miguel Negrón
    - [2a1fa2d] Merge pull request #46 from redBorder/bugfix/18716_remove_sync_ip_from_hosts_file
    - [176323b] Merge pull request #44 from redBorder/development
    - [0b0e324] Merge pull request #42 from redBorder/development
    - [215b2b1] Merge pull request #34 from redBorder/development
    - [81600e3] Improvement/fix lint (#33)
    - [a6be77f] Merge pull request #32 from redBorder/development
  - Miguel Negrón
    - [e1b75f2] Pass lint
    - [e3047de] Change the way to check if cloud
    - [34179ba] Add comment to system health
    - [6ff442c] Update update hosts
    - [b4a2579] use role instead of reading yml file to know if proxy mode or manager mode
    - [b4735d1] Bump version
    - [1766bbe] Change configuration call for GeoIP
  - nilsver
    - [81a43e9] fix lint 2.0
    - [6032735] fix lint
    - [4ec2a52] fix duplication bug
    - [3ee8cc4] fix lint
    - [79f2a23] update hosts file
    - [5e106a1] Release 0.6.0
    - [488fa13] Merge pull request #39 from redBorder/feature/18019_add_chronyd_cookbook
    - [6657481] update format
    - [d4643f5] fix linter 1.1
    - [40ee6c8] fix linter
    - [786c54e] update hosts file
  - Luis Blanco
    - [a932601] update changelog migrate view raw
    - [837ba65] Merge pull request #43 from redBorder/feature/#18237_Add_View_Raw_functionality_in_IPS
    - [9630389] add clean operation in makefile
    - [b0adaa8] Merge branch 'master' into feature/#18237_Add_View_Raw_functionality_in_IPS
    - [68de4a6] update metadata
    - [4e0ebd2] Merge pull request #38 from redBorder/feature/17731_ips_ssh_version
    - [ac6f35a] Update system_health.rb
    - [e73d75f] Revert "remove redBorder user because is legacy"
    - [48fbb78] Revert "remove redBorder user because is legacy"
    - [5c3739c] remove redBorder user because is legacy
    - [a26f1c1] remove redBorder user because is legacy
    - [e8b73c3] Merge remote-tracking branch 'origin/master' into feature/17731_ips_ssh_version
    - [ec02f58] Merge pull request #37 from redBorder/development
  - JPeraltaNic
    - [196a877] Release 0.7.0
    - [45fe633] Merge pull request #41 from redBorder/feature/18393_update_hosts_file
    - [59adf2f] Merge branch 'master' into feature/18393_update_hosts_file
    - [e03ca54] Merge branch 'master' into feature/#18237_Add_View_Raw_functionality_in_IPS
  - jnavarrorb
    - [df69047] MergeFromMaster. Fix user template
    - [d834784] Merge branch 'master' into feature/#18237_Add_View_Raw_functionality_in_IPS
    - [2289d8e] Change user to redborder for NG. Fix template folders
    - [d9c6a39] Change user to redborder for NG. Fix template
    - [5eff8fd] Change user to redborder for NG
  - Miguel Álvarez
    - [4344eeb] Merge pull request #40 from redBorder/development
    - [28f7dcc] Update metadata.rb
    - [4c6bd59] Update CHANGELOG.md
    - [99100a4] Update configure.rb
    - [8db18ec] Update default.rb
    - [8bb737e] Update system_health.rb
    - [76a3d79] Update metadata.rb
    - [8c34884] Merge branch 'development' into feature/add_clamav
  - Miguel Alvarez
    - [d466315] Add chronyd
    - [35d2ee2] fix lint issues
    - [8ff38e9] Fix sys health
    - [5672755] Fix lint
    - [6d1f480] Fix motd when ssh version
    - [3b39cfa] Only create ssh user if not cloud registration
    - [fabdd03] Add rsa pub key
    - [01a3935] Configure redBorder user
    - [5832c9a] Fix services
    - [38ca49a] Fix merge conflicts
    - [b5c40f8] Add clamAV
  - Juan Soto
    - [3a862b1] Update CHANGELOG.md
    - [faebefc] Update CHANGELOG.md
    - [942281b] Merge pull request #36 from redBorder/feature/add_clamav
    - [e7be16c] Merge pull request #35 from redBorder/feature/#17747_rb_exporter
  - JuanSheba
    - [f4f19ce] Release 0.4.0
    - [deddb46] Release 0.4.0
  - David Vanhoucke
    - [2bdb85f] fix lint
    - [0c5d6f6] add exporter service to ips
  - vimesa
    - [e8b26a4] Release 0.3.3

## 0.7.1

  - Luis J Blanco Mier
    - [9630389] add clean operation in makefile
  - Jose Navarro
    - [2289d8e] Migrate view raw funtionality

## 0.7.0

  - nilsver
    - [786c54e] Adapt /etc/hosts to support manager external Virtual IPs

## 0.6.0

  - Miguel Alvarez
    - [d466315] Add chronyd

## 0.5.0

  - Miguel Álvarez
    - [8bb737e] Update system_health.rb
    - [6d1f480] Fix motd when ssh version
    - [3b39cfa] Only create ssh user if not cloud registration
    - [fabdd03] Add rsa pub key
    - [01a3935] Configure redBorder user

## 0.4.0

  - Miguel Álvarez
    - [76a3d79] Update metadata.rb
    - [5832c9a] Fix services
    - [38ca49a] Fix merge conflicts
    - [b5c40f8] Add clamAV
  - David Vanhoucke
    - [0c5d6f6] add exporter service to ips

## 0.3.3

  - Miguel Negrón
    - [81600e3] Improvement/fix lint (#33)

## 0.3.2

  - Miguel Negrón
    - [1766bbe] Change configuration call for GeoIP

## 0.3.1

  - David Vanhoucke
    - [812d8cb] add temporary variables in node.run_state
  - Miguel Negrón
    - [8df0ab4] Update rpm.yml
    - [ddfebf9] Update README.md

## 0.3.0

  - Miguel Negrón
    - [8fdea69] Update metadata.rb
    - [2ba50d5] Add full kernel release info in motd
  - Miguel Álvarez
    - [ed25c00] Update system_health.rb
    - [7f6383c] Use proper names
    - [fc069e5] Redir stdout to dev null
    - [57c69b0] Update system_health.rb
    - [acd5a35] Rename recipe name
    - [1339106] Add health check forr non-systemd services

## 0.2.0

  - Miguel Negrón
    - [4c0db88] Add configure common cookbook call (#25)

## 0.1.11

  - Miguel Negrón
    - [9d042ae] Call rb_get_sensor_rules_cloud.rb using rvm


## 0.1.10

  - Miguel Álvarez
    - [5642a49] Check if service is excluded from mem services
    - [1acecd7] Dont pass excluded mem services here
    - [9616b49] Update default.rb
    - [8bb941b] Update prepare_system.rb
    - [7f9f710] Update default.rb

0.0.9
-----
- [David Vanhoucke <dvanhoucke@redborder.com>]
  - Fix missing country.dat from GeoIP 

0.0.1
-----
- [Miguel Negrón <Miguel Negrón@redborder.com>]
  - Initial release of ips
