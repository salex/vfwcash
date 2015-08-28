require 'active_record'
require 'sqlite3'
require "prawn/table"
require "prawn"
require 'yaml'
require "yaml/store"



module Vfwcash
  class Controller
    attr_accessor  :config, :cash
    def initialize(date)
      store = YAML::Store.new("#{PWD}/config/data.yml")
      store.transaction do
        store[:config] = YAML.load_file(File.join(PWD,'config/config.yml'))
        @config = store[:config]
      end
      @date = date
      ActiveRecord::Base.logger = Logger.new(STDERR)
      ActiveRecord::Base.logger.level = 3
      Dir.glob(File.join(LibPath,'models/*')).each do |file|
        require file
      end
      ActiveRecord::Base.establish_connection(
        :adapter => 'sqlite3',
        :database => @config[:database]
      )
      store.transaction do
        @cash = Cash.new(store)
      end
      # @cash.get_balances
    end

    def ledger(summary)
      if summary
        pdf = Pdf::Summary.new(@cash)
        filename = "#{PWD}/pdf/ledger_summary.pdf"
        pdf.render_file(filename)
      else
        pdf = Pdf::Ledger.new(@date,@cash)
        filename = "#{PWD}/pdf/ledger_#{Vfwcash.yyyymm(@date)}.pdf"
        pdf.render_file(filename)
      end
      open_pdf(filename)
    end

    def register(split)
      if split
        pdf = Pdf::SplitLedger.new(@date,@cash)
        filename = "#{PWD}/pdf/split_register_#{Vfwcash.yyyymm(@date)}.pdf"
        pdf.render_file(filename)
      else
        pdf = Pdf::Register.new(@date,@cash)
        filename = "#{PWD}/pdf/register_#{Vfwcash.yyyymm(@date)}.pdf"
        pdf.render_file(filename)
      end
      open_pdf(filename)
    end

    def audit
      pdf = Pdf::Audit.new(@date,@cash)
      filename = "#{PWD}/pdf/audit_#{Vfwcash.yyyymm(@date.beginning_of_quarter)}.pdf"
      pdf.render_file(filename)
      open_pdf(filename)
    end

    def balance
      pdf = Pdf::Balance.new(@date,@cash)
      filename = "#{PWD}/pdf/balance_#{Vfwcash.yyyymm(@date)}.pdf"
      pdf.render_file(filename)
      open_pdf(filename)
    end

    def open_pdf(filename)
      if Gem::Platform.local.os == 'darwin'
        `open #{filename}`
      else
        `start #{filename}`
      end
    end

  end
end