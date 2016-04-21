#
# Cookbook Name:: db2
# Recipe:: install
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ------------------------------------------------------
# Check required attribute.
# ------------------------------------------------------
unless node['db2']['installer_url']
  Chef::Application.fatal!("The installer url attribute is required.")
end

installer_url = node['db2']['installer_url']
work_dir      = node['db2']['working_dir']
response_file = "#{work_dir}/db2expc.rsp"

# ------------------------------------------------------
# Install required module.
# ------------------------------------------------------
package 'libstdc++.so.5'
package 'libaio.so.1'
package 'libstdc++.so.6'
package 'pam.i686'
package 'libaio'
package 'libaio-devel'
package 'sg3_utils'

# ------------------------------------------------------
# Install DB2 Express-C.
# ------------------------------------------------------
directory "#{work_dir}" do
  action :create
end

execute 'install-db2' do
  action :nothing
  command <<-EOH
    #{work_dir}/expc/db2setup -r #{response_file} -l #{node['db2']['installer_log']}
  EOH
end

template "#{response_file}" do
  owner 'root'
  group 'root'
  mode "0644"
end

ark "expc" do 
  url "#{installer_url}"
  path "#{work_dir}"
  owner 'root'
  group 'root'
  action :put 
  notifies :run, "execute[install-db2]", :immediately
end

# ------------------------------------------------------
# Delete tmp file.
# ------------------------------------------------------
directory "#{work_dir}" do
  recursive true
  action :delete
end

file "#{Chef::Config[:file_cache_path]}/expc.tar.gz" do
  action :delete
end