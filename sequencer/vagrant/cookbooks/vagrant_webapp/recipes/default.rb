#
# Cookbook Name:: vagrant_webapp
# Recipe:: default
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apache2::mod_php5"

node[:deploy].each do |application, deploy|

	if node['vagrant']
		# put the www-data user into the vagrant group
		# so the Apache process can read things owned by vagrant
		group "vagrant" do
			action :modify
			members "apache"
			append true
		end

		directory "#{node[:apache][:dir]}/sites-available/"

		directory "#{node[:apache][:dir]}/sites-available/#{application}.conf.d"

		# put the localhost site in place
		web_app "#{application}" do
			server_name "localhost"
			server_aliases ['none']
			docroot "#{deploy[:deploy_to]}/#{deploy[:document_root]}"
			enable true
			allow_override "All"
			port '80'
			rewrite_config "#{node[:apache][:dir]}/sites-available/#{application}.conf.d/rewrite"
			local_config "#{node[:apache][:dir]}/sites-available/#{application}.conf.d/local"
			cookbook "vagrant_webapp"
		end

		#web_app "localhost-ssl" do
		#  server_name 'localhost'
		#  server_aliases ['none']
		#  docroot "/vagrant/wordpress"
		#  enable true
		#  allow_override "All"
		#  port '443'
		#  cookbook 'devsite'
		#end

	end
end
