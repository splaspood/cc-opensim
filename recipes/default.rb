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

directory node['opensim']['install_prefix'] do
  owner "opensim"
  group "root"
  mode "0755"
  action :create
end

remote_file "#{Chef::Config[:file_cache_path]}/opensim-#{node['opensim']['version']}.tar.gz" do
  source node[:opensim][:url]
  checksum node[:opensim][:checksum]
end

execute "tar zxf #{Chef::Config[:file_cache_path]}/opensim-#{node['opensim']['version']}.tar.gz" do
  cwd node['opensim']['install_prefix']
  creates "#{node['opensim']['install_prefix']}/opensim-#{node[:opensim][:version]}-bin"
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
