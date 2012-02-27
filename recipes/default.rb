#
# Cookbook Name:: opensim
# Recipe:: default
#
# Copyright 2012, ParaVolve Development Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

package "mono-complete" do
  action :install
end

user "opensim" do
  home node['opensim']['install_prefix']
  shell "/bin/bash"
  action :create
end

directory "#{node['opensim']['install_prefix']}/config" do
  owner "opensim"
  group "root"
  mode "0755"
  action :create
  recursive true
end

remote_file "#{Chef::Config[:file_cache_path]}/opensim-#{node['opensim']['version']}.tar.gz" do
  source node[:opensim][:url]
  checksum node[:opensim][:checksum]
end

execute "rm -r #{node['opensim']['install_prefix']}/opensim-#{node['opensim']['version']}-bin/bin/config-include" do
  action :nothing
end

execute "tar zxf #{Chef::Config[:file_cache_path]}/opensim-#{node['opensim']['version']}.tar.gz" do
  cwd node['opensim']['install_prefix']
  creates "#{node['opensim']['install_prefix']}/opensim-#{node[:opensim][:version]}-bin"
  notifies :run, resources( :execute => "rm -r #{node['opensim']['install_prefix']}/opensim-#{node['opensim']['version']}-bin/bin/config-include" ), :immediately
end

link "#{node['opensim']['install_prefix']}/current" do
  to "#{node['opensim']['install_prefix']}/opensim-#{node[:opensim][:version]}-bin"
end

template "#{node['opensim']['install_prefix']}/current/bin/Regions/Regions.ini" do
  owner "opensim"
  mode "0644"
  variables( :regions => search( :opensim_regions ) )
  source "regions.ini.erb"
end

case node['opensim']['database']['type']
when "mysql"
  database_server = search( :node, "role:mysql-server AND recipe:opensim\\:\\:database AND chef_environment:#{node.chef_environment}" ).first || {}

  template "#{node['opensim']['install_prefix']}/config/config-include/StandaloneCommon.ini" do
    owner "opensim"
    mode "0644"
    variables(
      :database_type     => "mysql",
      :database_host     => database_server['ip_address'],
      :database_username => database_server['opensim']['database']['username'],
      :database_password => database_server['opensim']['database']['password'],
      :database_name     => database_server['opensim']['database']['name'] )
    source "StandaloneCommon.ini.erb"
  end
when "sqlite"
  template "#{node['opensim']['install_prefix']}/config/config-include/StandaloneCommon.ini" do
    owner "opensim"
    mode "0644"
    variables( :database_type => 'sqlite' )
    source "StandaloneCommon.ini.erb"
  end
else
  Chef::Log.error "Unknown database type specified!"
end

cookbook_file "#{node['opensim']['install_prefix']}/config/OpenSim.ini" do
  source "opensim.ini"
  owner "opensim"
  mode "644"
  action :create_if_missing
end

remote_directory "#{node['opensim']['install_prefix']}/config/config-include" do
  source "config-include"
  owner "opensim"
  files_mode "0644"
  mode "0755"
  overwrite false
end

%w{ config-include OpenSim.ini Asset.db  auth.db  avatars.db  friends.db  griduser.db  inventory.db  OpenSim.db  userprofiles.db }.each do |f|
  link "#{node['opensim']['install_prefix']}/current/bin/#{f}" do
    to "#{node['opensim']['install_prefix']}/config/#{f}"
  end
end


