class DropGitoriousFieldFromApplicationSettings < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  # After the deploy the caches will be cold anyway
  DOWNTIME = false

  def up
    require 'yaml'

    yaml = connection.execute('SELECT import_sources FROM application_settings;').values[0][0]
    yaml = YAML.safe_load(yaml)
    yaml.delete 'gitorious'

    # No need for a WHERE clause as there is only one
    connection.execute("UPDATE application_settings SET import_sources = #{update_yaml(yaml)}")
  end

  def down
    # noop, gitorious still yields a 404 anyway
  end

  private

  def connection
    ActiveRecord::Base.connection
  end

  def update_yaml(yaml)
    connection.quote(YAML.dump(yaml))
  end
end
