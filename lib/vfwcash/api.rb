
module Vfwcash
  class Api
    attr_accessor  :config, :cash
    def initialize(date=nil)
      @date = date
      require_relative '../models/sqlite_base'
      @config = Vfwcash::Config
      Dir.glob(File.join(LibPath,'models/*')).each do |file|
        require file
      end
      @cash = Gcash.new(@config)
      unless @cash.dates.include?(@date)
        puts "No transactions exist for #{@date.beginning_of_month}"
        exit(0)
      end
    end

    def between(from,to)
      pdf = Pdf::Between.new(@date,@cash,from,to)
    end

    def ledger
      pdf = Pdf::Ledger.new(@date,@cash)
    end

    def summary
      pdf = Pdf::Summary.new(@cash)
    end

    def register
      pdf = Pdf::Register.new(@date,@cash)
    end

    def split
      pdf = Pdf::SplitLedger.new(@date,@cash)
    end

    def split_response
      date = Vfwcash.set_date(@date).beginning_of_month
      @cash.get_fund_balances(@date,@date.end_of_month)
      @cash.response = @cash.split_ledger_api(@date)
      @cash
    end

    def audit
      pdf = Pdf::Audit.new(@date,@cash)
    end

    def balance
      pdf = Pdf::Balance.new(@date,@cash)
    end

  end
end