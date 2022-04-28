module Rb_ips
    module Helpers
      #
      # Returns the groups that are in use with more info (cpu_list..)
      # 
      def get_groups_in_use_info()
        used_segments = []
        groups_info = []
        node["redborder"]["snort"]["groups"].each do |id, original_group|
          group = node["redborder"]["snort"]["groups"][id].to_hash.clone
        
          name = (group["name"].nil? ? "default" : group["name"].to_s)
          group["name"]     = name 
          group["segments"] = node["redborder"]["segments"].keys  if group["segments"].nil?
          group["cpu_list"] = 0.upto(node["cpu"]["total"]-1).to_a if group["cpu_list"].nil?
          group["cpu_list"] = (group["cpu_list"].map { |x| x.to_i }).sort.uniq
          group["segments"] = group["segments"].sort.uniq
          group["instances_group"] = id.to_i
          group["segments"] = group["segments"].select{ |x| !used_segments.include?(x) }
         
          # Skip non used groups
          next if group["cpu_list"].size==0 or group["segments"].size==0 or group["bindings"].nil? or group["bindings"].size==0
          
          used_segments = used_segments + group["segments"]

          force_span=false
          group["segments"].each do |x|
            if node["redborder"]["segments"][x] and node["redborder"]["segments"][x]["interfaces"]
              force_span=true if node["redborder"]["segments"][x]["interfaces"].keys.size<=1
            end
          end
          group["mode"] = "IDS_SPAN" if force_span

          groups_info.push(group)
        end
        
        return groups_info
      end
    end
  end