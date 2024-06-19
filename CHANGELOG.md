cookbook-rb-ips CHANGELOG
===============

## 0.3.3

  - Miguel Negrón
    - [81600e3] Improvement/fix lint (#33)

## 0.3.2

  - Miguel Negron
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

  - Miguel Negron
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
- [Miguel Negrón <manegron@redborder.com>]
  - Initial release of ips
