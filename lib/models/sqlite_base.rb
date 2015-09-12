class SqliteBase < ActiveRecord::Base
  self.logger = Logger.new(STDERR)
  self.logger.level = 3

  establish_connection(
          :adapter => 'sqlite3',
          :database => Vfwcash::Config[:database]
        )
  self.abstract_class = true
end