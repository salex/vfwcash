require 'active_record'
require 'sqlite3'
require "prawn/table"
require "prawn"
require 'yaml'

module Vfwcash
  class Controller
    attr_accessor  :config, :cash
    def initialize(date)
      @config = Vfwcash.config
      require_relative './sqlite_base'
      @date = date
      Dir.glob(File.join(LibPath,'models/*')).each do |file|
        require file
      end
      @cash = Gcash.new(@config)
      unless @cash.dates.include?(@date)
        puts "No transactions exist for #{@date.beginning_of_month}"
        exit(0)
      end
    end

    def profit_loss(options)
      report =  @cash.profit_loss(options)
      pdf = ProfitLoss.new(report)
      filename = "#{PWD}/pdf/pl_#{report['options'][:from]}_#{report['options'][:to]}.pdf"
      pdf.render_file(filename)
      open_pdf(filename)
    end

    def between(from,to)
      pdf = Between.new(@date,@cash,from,to)
      filename = "#{PWD}/pdf/between_#{from}_#{to}.pdf"
      pdf.render_file(filename)
      open_pdf(filename)
    end

    def ledger
      pdf = Ledger.new(@date,@cash)
      filename = "#{PWD}/pdf/ledger_#{Vfwcash.yyyymm(@date)}.pdf"
      pdf.render_file(filename)
      open_pdf(filename)
    end

    def summary
      pdf = Summary.new(@cash)
      filename = "#{PWD}/pdf/ledger_summary.pdf"
      pdf.render_file(filename)
      open_pdf(filename)
    end


    def register
      pdf = Register.new(@date,@cash)
      filename = "#{PWD}/pdf/register_#{Vfwcash.yyyymm(@date)}.pdf"
      pdf.render_file(filename)
      open_pdf(filename)
    end

    def split
      pdf = SplitLedger.new(@date,@cash)
      filename = "#{PWD}/pdf/split_#{Vfwcash.yyyymm(@date)}.pdf"
      pdf.render_file(filename)
      open_pdf(filename)
    end

    def audit
      pdf = Audit.new(@date,@cash)
      filename = "#{PWD}/pdf/audit_#{Vfwcash.yyyymm(@date.beginning_of_quarter)}.pdf"
      pdf.render_file(filename)
      open_pdf(filename)
    end

    def balance
      pdf = Balance.new(@date,@cash)
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