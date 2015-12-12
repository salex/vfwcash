class SqliteBase < ActiveRecord::Base
  self.logger = Logger.new(STDERR)
  self.logger.level = 3
  establish_connection(
          :adapter => 'sqlite3',
          :database => ENV['VFWCASHDATABASE'] # Vfwcash.config[:database]
        )
  self.abstract_class = true
end