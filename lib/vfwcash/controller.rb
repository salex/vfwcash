require 'active_record'
require 'sqlite3'
require "prawn/table"
require "prawn"
require 'yaml'

module Vfwcash
  class Controller
    attr_accessor  :config, :cash
    def initialize(date)
      @config = YAML.load_file(File.join(PWD,'config/config.yml'))
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
      @cash = Gcash.new(@config)
      unless @cash.dates.include?(@date)
        puts "No transactions exist for #{@date.beginning_of_month}"
        exit(0)
      end
    end

    def between(from,to)
      pdf = Pdf::Between.new(@date,@cash,from,to)
      filename = "#{PWD}/pdf/between_#{from}_#{to}.pdf"
      pdf.render_file(filename)
      open_pdf(filename)
    end

    def ledger
      pdf = Pdf::Ledger.new(@date,@cash)
      filename = "#{PWD}/pdf/ledger_#{Vfwcash.yyyymm(@date)}.pdf"
      pdf.render_file(filename)
      open_pdf(filename)
    end

    def summary
      pdf = Pdf::Summary.new(@cash)
      filename = "#{PWD}/pdf/ledger_summary.pdf"
      pdf.render_file(filename)
      open_pdf(filename)
    end


    def register
      pdf = Pdf::Register.new(@date,@cash)
      filename = "#{PWD}/pdf/register_#{Vfwcash.yyyymm(@date)}.pdf"
      pdf.render_file(filename)
      open_pdf(filename)
    end

    def split
      pdf = Pdf::SplitLedger.new(@date,@cash)
      filename = "#{PWD}/pdf/split_#{Vfwcash.yyyymm(@date)}.pdf"
      pdf.render_file(filename)
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