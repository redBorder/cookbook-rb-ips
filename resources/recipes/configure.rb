#
# Cookbook Name:: ips
# Recipe:: configure
#
# Copyright 2022, redborder
#
# AFFERO GENERAL PUBLIC LICENSE V3
#

# Services configuration

extend Rb_ips::Helpers

# ips services
ips_services = ips_services()

ip_regex = /^([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])$/
###resolv_dns_dg = Chef::DataBagItem.load("rBglobal", "resolv_dns")   rescue resolv_dns_dg={}
###monitors_dg   = Chef::DataBagItem.load("rBglobal", "monitors")     rescue monitors_dg={}
domain_db     = Chef::DataBagItem.load("rBglobal", "publicdomain") rescue domain_db={}

sensor_id = node["redborder"]["sensor_id"].to_i rescue 0

if sensor_id>0
  if node.name.start_with?"rbipscp-"
    node.run_list(["role[ipscp-sensor]", "role[rBsensor-#{sensor_id}]", "role[ipscp-sensor]"])
  elsif node.name.start_with?"rbipsv2-"
    node.run_list(["role[ipsv2-sensor]", "role[rBsensor-#{sensor_id}]", "role[ipsv2-sensor]"])
  else
    node.run_list(["role[ips-sensor]", "role[rBsensor-#{sensor_id}]", "role[ips-sensor]"])
  end
end

geoip_config "Configure GeoIP" do
    action (ips_services["geoip"] ? :add : :remove)
end

snmp_config "Configure snmp" do
    hostname node["hostname"]
    cdomain node["redborder"]["cdomain"]
    action (ips_services["snmp"] ? :add : :remove)
end
  
ntp_config "Configure NTP" do
    action (ips_services["ntp"] ? :add : :remove)
end
  
# rsyslog_config "Configure rsyslog" do
#     vault_nodes node["redborder"]["sensors_info_all"]["vault-sensor"]
#     action (ips_services["rsyslog"] ? [:add] : [:remove])
# end

if node["redborder"]["chef_enabled"].nil? or node["redborder"]["chef_enabled"]
    groups_in_use = get_groups_in_use_info

    snort_config "Configure Snort" do
        sensor_id sensor_id
        groups groups_in_use
        action ((ips_services["snort"] and !node["redborder"]["snort"]["groups"].empty? and sensor_id>0 and node["redborder"]["segments"] and node["cpu"] and node["cpu"]["total"] ) ? :add : :remove)
    end

    barnyard2_config "Configure Barnyard2" do
      sensor_id sensor_id
      groups groups_in_use
      action ((ips_services["barnyard2"] and !node["redborder"]["snort"]["groups"].empty? and sensor_id>0 and node["redborder"]["segments"] and node["cpu"] and node["cpu"]["total"] ) ? :add : :remove)
    end
    
    if sensor_id>0 and node["redborder"] and node["redborder"]["segments"]
        #Activate bypass on unused segments
        node["redborder"]["segments"].keys.each do |s|
          next unless s =~ /^bpbr[\d]+$/
          # Switch on bypass on those segments that are not in use
          if groups_in_use.select{|g| g["segments"].include?s}.empty?
            execute "bypass_#{s}" do
              command "/usr/lib/redborder/bin/rb_bypass.sh -b #{s} -s on" 
              ignore_failure true
              action :run
            end # execute
          end # if !unsed
        end #do
      
        #Delete unnecesary files:
        groups = node["redborder"]["snort"]["groups"].keys.map{|x| x.to_i}
        [
          {:files => "/etc/sysconfig/snort-*", :regex => /\/snort-(\d+)$/}, 
          {:files => "/etc/sysconfig/barnyard2-*", :regex => /\/barnyard2-(\d+)$/}, 
          {:files => "/etc/snort/*", :regex => /\/(\d+)$/},
          {:files => "/var/log/snort/*", :regex => /\/(\d+)$/}
        ].each do |x|
          Dir.glob(x[:files]).each do |f|
            match = f.match(x[:regex])
            if match and !groups.include?(match[1].to_i)
              if File.directory?(f)
                directory f do 
                  recursive true
                  action :delete
                end #do
              else
                file f do 
                  action :delete
                end #do
              end #if File..      
            end # if match
          end #Dir.. do
        end # [..].each do
      
        # Clean rubish for snort and barnyard instances should not be running
        [ "snortd" , "barnyard2" ].each do |s|
          if File.exists?("/etc/init.d/#{s}") 
            execute "cleanstop_#{s}" do
              command "/etc/init.d/#{s} cleanstop" 
              ignore_failure true
              action :run
            end # execute
          end # if File.exists..
        end # [..].each do
      end # if sensor.id>0
end # if node

    # rbmonitor_config "Configure redborder-monitor" do
    #     name node["hostname"]
    #     monitors monitors_dg["monitors"]
    #     action ((ips_services["redborder-monitor"] and sensor_id > 0) ? :add : :remove)
    # end   
           
      ###template "/etc/rb_snmp_pass.yml" do
      ###  source "rb_snmp_pass.yml.erb"
      ###  cookbook "rb-ips"
      ###  owner "root"
      ###  group "root"
      ###  mode 0755
      ###  retries 2
      ###  variables(:monitors => monitors_dg["monitors"])
      ###  ###notifies :stop, "service[snmptrapd]", :delayed
      ###  ###notifies :restart, "service[snmpd]", :delayed
      ###  ###notifies :start, "service[snmptrapd]", :delayed
      ###end
      
      template "/etc/watchdog.conf" do
        source "watchdog.conf.erb"
        owner "root"
        group "root"
        mode 0644
        retries 2
        ###notifies :restart, "service[watchdog]"
      end
      
      ###template "/etc/watchdog.d/020-check-snort.sh" do
      ###  source "watchdog_020-check-snort.sh.erb"
      ###  owner "root"
      ###  group "root"
      ###  mode 0755
      ###  retries 2
      ###  ###notifies :reload, "service[watchdog]", :delayed 
      ###end

if !node["redborder"]["ipsrules"].nil? and !node["redborder"]["cloud"].nil? 
    node["redborder"]["ipsrules"].to_hash.each do |groupid, ipsrules| 
      if node["redborder"]["ipsrules"][groupid]["command"] and !node["redborder"]["ipsrules"][groupid]["command"].empty? and node["redborder"]["ipsrules"][groupid]["timestamp"].to_i > 0 and node["redborder"]["ipsrules"][groupid]["timestamp_last"].to_i < node["redborder"]["ipsrules"][groupid]["timestamp"].to_i and node["redborder"]["ipsrules"][groupid]["uuid"] and !node["redborder"]["ipsrules"][groupid]["uuid"].empty?
        command=node["redborder"]["ipsrules"][groupid]["command"].to_s.gsub!(/^sudo /, "").gsub(/;/, " ")
        if command.start_with?'/bin/env BOOTUP=none /usr/lib/redborder/bin/rb_get_sensor_rules.sh '
          execute "download_rules_#{groupid}" do 
            command "/usr/lib/redborder/scripts/rb_get_sensor_rules_cloud.rb -c '#{command}' -u #{node["redborder"]["ipsrules"][groupid]["uuid"].to_s}"
            ignore_failure true
            action :run
            notifies :create, "ruby_block[update_rule_timestamp_#{groupid}]", :immediately
          end
          ruby_block "update_rule_timestamp_#{groupid}" do
            block do
              node.set["redborder"]["ipsrules"][groupid]["timestamp_last"] = node["redborder"]["ipsrules"][groupid]["timestamp"]
            end
            action :nothing
          end
        end
      end
    end
end

template "/etc/cli_banner" do
    source "cli_banner.erb"
    cookbook "rb-ips"
    owner "root"
    owner "root"
    mode 0644
    retries 2
end

template "/etc/chef/role-sensor.json" do
    source "role-sensor.json.erb"
    cookbook "rb-ips"
    owner "root"
    group "root"
    mode 0644
    retries 2
    variables(:sensor_id => sensor_id)
end

template "/etc/chef/role-sensor-once.json" do
    source "role-sensor-once.json.erb"
    cookbook "rb-ips"
    owner "root"
    group "root"
    mode 0644
    retries 2
    variables(:sensor_id => sensor_id)
end

template "/etc/sudoers.d/redBorder" do
    source "redBorder.erb"
    cookbook "rb-ips"
    owner "root"
    group "root"
    mode 0440
    retries 2
end

template "/etc/sensor_id" do
    source "variable.erb"
    cookbook "rb-ips"
    owner "root"
    group "root"
    mode 0644
    retries 2
    variables(:variable => sensor_id )
end

# template "/opt/rb/etc/chef/uptime" do
#     source "variable.erb"
#     owner "root"
#     group "root"
#     mode 0644
#     retries 2
#     backup false
#     variables(:variable => Time.now.to_i)
# end

# template "/etc/ssh/sshd_config" do
#   source "sshd_config.erb"
#   owner "root"
#   group "root"
#   mode 0755
#   retries 2
#   notifies :restart, "service[sshd]", :delayed
# end

# template "/etc/pam.d/system-auth" do
#   source "system-auth.erb"
#   owner "root"
#   group "root"
#   mode 0755
#   retries 2
#   notifies :restart, "service[sshd]", :delayed
# end

# template "/etc/pam.d/password-auth" do
#   source "password-auth.erb"
#   owner "root"
#   group "root"
#   mode 0755
#   retries 2
#   notifies :restart, "service[sshd]", :delayed
# end


# service "bp_watchdog" do
#     service_name "bp_watchdog"
#     ignore_failure true
#     supports :status => true, :reload => true, :restart => true
#     node["redBorder"]["has_bypass"] ? action([:start, :enable]) : action([:stop, :disable])
# end

# service "watchdog" do
#     service_name node[:redBorder][:watchdog][:service]
#     ignore_failure true
#     supports :status => true, :reload => true, :restart => true
#     action([:start, :enable])
# end

# service "chef-client" do
#     service_name "chef-client"
#     ignore_failure true
#     supports :status => true, :reload => true, :restart => true
#     action([:enable])
# end

service "sshd" do
    service_name "sshd"
    ignore_failure true
    supports :status => true, :reload => false, :restart => true
    action [:start, :enable]
end

execute "force_chef_client_wakeup" do
    command "/usr/lib/redborder/bin/rb_wakeup_chef"
    ignore_failure true
    action ((sensor_id>0) ? :nothing : :run)
end

if File.exists?("/etc/init.d/rb-lcd")
    execute "rb-lcd" do
      lcd=!Dir.glob('/dev/ttyUSB*').empty?
      only_if "#{lcd}"
      command "/bin/env WAIT=1 /etc/init.d/rb-lcd start"
      ignore_failure true
      action :nothing
    end.run_action(:run)
end
  
