default['opensim']['install_prefix']  = "/usr/local/opensim"
default['opensim']['version']         = "0.7.2"
default['opensim']['checksum']        = "724787d3c2489fcb6e789e4168d9569fd0f30206"
default['opensim']['url']             = "http://opensimulator.org/dist/opensim-#{node['opensim']['version']}-bin.tar.gz"

default['opensim']['mode']            = "standalone"
default['opensim']['database']        = "mysql"

default['opensim']['admin']['first_name'] = 'Admin'
default['opensim']['admin']['last_name'] = 'User'

