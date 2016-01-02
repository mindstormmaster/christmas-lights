mysql2_chef_gem 'default' do
  action :install
end

mysql_connection_info = {
  :host     => 'localhost',
  :username => 'root',
  :password => node['mysql']['server_root_password']
}

node[:deploy].each do |application, deploy|

	if node['vagrant']
    mysql_database_user deploy[:database][:username] do
        connection mysql_connection_info
        password   deploy[:database][:password]
        action     :create
    end

    log "create the development schema."
    mysql_database deploy[:database][:database] do
        connection mysql_connection_info
        action     :create
    end

    mysql_database_user deploy[:database][:username] do
        connection    mysql_connection_info
        password      deploy[:database][:password]
        database_name deploy[:database][:database]
        host          deploy[:database][:host]
        privileges    [:all]
        action        :grant
    end

    log "create starting point schema from #{deploy[:deploy_to]}/symfony/app/propel/sql/base_database.sql"
    mysql_database deploy[:database][:database] do
        connection mysql_connection_info
        sql { ::File.open("#{deploy[:deploy_to]}/symfony/app/propel/sql/base_database.sql").read }
        action :query

        only_if do
          File.exists?("#{deploy[:deploy_to]}/symfony/app/propel/sql/base_database.sql")
        end
    end
  end
end
