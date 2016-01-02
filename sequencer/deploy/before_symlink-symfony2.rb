Chef::Log.info(new_resource.params[:deploy_data])
Chef::Log.info(new_resource)


############## Symfony ####################

# devsite::composer_github_oauth
if node['vagrant']
    deploy_user_home = "/root"
    deploy_username = "root"
    deploy_groupname = "root"
else
    deploy_user_home = "/home/#{node[:opsworks][:deploy_user][:user]}"
    deploy_username = node[:opsworks][:deploy_user][:user]
    deploy_groupname = node[:opsworks][:deploy_user][:group]
end

directory "#{deploy_user_home}/.composer" do
    owner deploy_username
    group deploy_groupname
    mode 00664
    action :create
end

template "#{deploy_user_home}/.composer/config.json" do
    source "#{release_path}/deploy/composer_config.json.erb"
    local true
    mode 0644
end
# end devsite::composer_github_oauth


if !node['vagrant']
    # Set ACL rules to give proper permission to cache and logs
    script "update_symfony_acl" do
      interpreter "bash"
      user "root"
      cwd "#{release_path}/#{node[:symfony][:root]}"
      code <<-EOH
      mkdir -p app/cache app/logs app/cache/#{node[:symfony][:env]}/tmp
      setfacl -R -m u:#{node[:apache][:user]}:rwX -m m:rwX app/cache/ app/logs/ app/cache/#{node[:symfony][:env]}/tmp
      setfacl -dR -m u:#{node[:apache][:user]}:rwX -m m:rwX app/cache/ app/logs/ app/cache/#{node[:symfony][:env]}/tmp
      setfacl -R -m u:#{node[:apache][:user]}:rwX -m m:rwX /srv/www/#{new_resource.params[:app]}/shared/log
      setfacl -dR -m u:#{node[:apache][:user]}:rwX -m m:rwX /srv/www/#{new_resource.params[:app]}/shared/log

      EOH
    end
else
    # Set ACL rules to give proper permission to cache and logs
    script "update_var_lib_php_acl" do
      interpreter "bash"
      user "root"
      cwd "#{release_path}/#{node[:symfony][:root]}"
      code <<-EOH
      setfacl -R -m u:#{node[:apache][:user]}:rwX /var/lib/php/
      setfacl -dR -m u:#{node[:apache][:user]}:rwx /var/lib/php
      EOH
    end
end

case node[:platform]
    when 'debian', 'ubuntu'
      packages = [
      ]

    when 'centos', 'redhat', 'fedora', 'amazon'
      # TODO: Compile php-sqlite extension for RHEL based systems.
      packages = [
        "php-pdo",
        "php-sqlite3"
      ]
end


packages.each do |pkg|
    package pkg do
        action :install
    end
end

package "git" do
    action :install
end

package "sqlite" do
    action :upgrade
end

execute "vendors install" do
    cwd "#{release_path}/#{node[:symfony][:root]}"
    command "composer install --no-interaction"
    action :run
end

execute "propel build-model" do
    command "php app/console propel:model:build"
    cwd "#{release_path}/#{node[:symfony][:root]}"
    action :run
end

execute "propel migrate" do
    command "php app/console --env=#{node[:symfony][:env]} propel:migration:migrate"
    cwd "#{release_path}/#{node[:symfony][:root]}"
    action :run
end


execute "assets install" do
    command "php app/console assets:install --env=#{node[:symfony][:env]} #{release_path}/#{new_resource.params[:deploy_data][:document_root]}"
    cwd "#{release_path}/#{node[:symfony][:root]}"
    action :run
end

execute "assetic dump" do
    command "php app/console assetic:dump --env=#{node[:symfony][:env]} #{release_path}/#{new_resource.params[:deploy_data][:document_root]}"
    cwd "#{release_path}/#{node[:symfony][:root]}"
    action :run
end
###### end symfony2


###### grunt to compile bootstrap.css
#
# need to run this after symfony2 because symfony2 runs assetic:dump and we want to overwrite those resources
#

script "install less" do
    interpreter "bash"
    user "root"
    cwd "/"
    code <<-EOH
    npm --global install less
    npm --global install grunt-cli
    EOH
end

script "install node modules" do
    interpreter "bash"
    user "root"
    cwd "#{release_path}"
    code <<-EOH
    npm install --no-bin-links
    EOH
end

execute "compile less" do
    command "grunt less"
    user "root"
    cwd "#{release_path}"
end
###### end grunt


# install standard crons on all instances
template "/etc/cron.d/metabolon.standard" do
    source "#{release_path}/deploy/cron.standard.erb"
    local true
    mode '0644'
    owner "root"
    group "root"
    variables(
        :user => node[:apache][:user],
        :env => node[:symfony][:env],
        :symfonyroot => "#{release_path}/#{node[:symfony][:root]}"
    )
end

service "crond" do
    action :restart
end

#
### this is a symfony only app, so don't need to re-write the htaccess file
#
#script "write_htaccess" do
#    interpreter "bash"
#    user "root"
#    cwd "#{release_path}"
#    code <<-EOH
#      echo "RewriteEngine on" > #{new_resource.params[:deploy_data][:document_root]}/.htaccess
#      php app/console --env=#{node[:symfony][:env]} router:dump-apache #{node[:symfony][:frontend]} >> #{release_path}/#{new_resource.params[:deploy_data][:document_root]}/.htaccess
#    EOH
#    # add the line below if using wordpress
#    #       cat .htaccess-wordpress >> #{release_path}/#{new_resource.params[:deploy_data][:document_root]}/.htaccess
#end
