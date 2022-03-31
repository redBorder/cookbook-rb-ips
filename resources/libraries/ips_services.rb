class Chef
    class Recipe
      def ips_services()
        ips_services  = {}
        node["redborder"]["services"].each { |k,v| ips_services[k] = v if (v==true or v==false) } if !node["redborder"]["services"].nil?
        
        # changing default values in case of the user has modify them
        node["redborder"]["services"]["overwrite"].each { |k,v| ips_services[k] = v if (v==true or v==false) } if !node["redborder"]["services"]["overwrite"].nil?
        
        return ips_services
      end
    end
  end