cron_d 'create_clean_logs_daily' do
  action :create
  minute '00'
  hour   '00'
  weekday '*'
  retries 2
  ignore_failure true
  command "/usr/lib/redborder/bin/rb_clean_logs_snort.sh"
end

#--------------------------Geoipupdate-------------------------#
cron_d 'geoipupdate' do
  comment "Update GeoIP and GeoLite Databases twice a week"
  action :create
  minute '41'
  hour   '17'
  weekday '1,4'
  retries 2
  ignore_failure true
  command "/usr/bin/geoipupdate"
end