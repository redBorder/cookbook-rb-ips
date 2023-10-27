# ips Cookbook

Cookbook to configure a redborder ips

## Requirements

depends 'kafka', '0.0.1'
depends 'zookeeper', '0.0.1'

### Platforms

- Rocky Linux 9

### Chef

- Chef 12.0 or later

# BUILDING

- Build rpm package for redborder platform:
  * git clone https://github.com/redborder/cookbook-rb-ips.git
  * cd cookbook-rb-ips
  * make
  * RPM packages is under packaging/rpm/pkgs/

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

## License
GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007

## Authors
Miguel Negrón <manegron@redborder.com>
David Vanhoucke <dvanhoucke@redborder.com>
