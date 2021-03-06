
module Vfwcash
  class Api
    attr_accessor  :config, :cash
    def initialize(date=nil)
      @date = Vfwcash.set_date(date)
      @config = Vfwcash.config
      require_relative './sqlite_base'
      Dir.glob(File.join(LibPath,'models/*')).each do |file|
        require file
      end
      @cash = Gcash.new(@config)
      unless @cash.dates.include?(@date)
        puts "No transactions exist for #{@date.beginning_of_month}"
      end
    end

    def between(from,to)
      pdf = Between.new(@date,@cash,from,to)
    end

    def profit_loss(report)
      pdf = ProfitLoss.new(report)
    end

    def ledger
      pdf = Ledger.new(@date,@cash)
    end

    def summary
      pdf = Summary.new(@cash)
    end

    def register_pdf
      pdf = RegisterPdf.new(@date,@cash)
    end

    def split
      pdf = SplitLedger.new(@date,@cash)
    end

    def audit
      pdf = Audit.new(@date,@cash)
    end

    def balance
      pdf = Balance.new(@date,@cash)
    end

  end
end