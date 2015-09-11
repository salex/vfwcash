require "yaml/store"

module Vfwcash

  class Gcash
    # gcash is the primary interface to the GNUCash database
    # The initializer sets attributes based on data in the db and from the config file
    # that is common to all reports.

    # API calls provide informtion needed for specific reports.

    attr_accessor  :balances, :checking, :savings, :checking_funds,:savings_funds,
    :dates, :bmonth, :checking_acct, :savings_acct, :tmonths, :config

     def initialize(config)
      @config = config
      @checking_acct = @config[:checking_acct]
      @savings_acct = @config[:savings_acct]
      @checking_funds = CashAccount.find_by(name:@checking_acct).children.pluck(:name)
      @savings_funds = CashAccount.find_by(name:@savings_acct).children.pluck(:name)
      @dates = Vfwcash.transaction_range
      set_tmonths 
    end
  # COMMON Methods
    def set_tmonths
      @tmonths = []
      first = @dates.first
      last = @dates.last
      curr = first
      while curr < last do
        @tmonths << "#{curr.year}#{curr.month.to_s.rjust(2,'0')}"
        curr += 1.month
      end
    end

    def get_fund_balances(bdate,edate)
      @balances = {}
      @balances[:checking] =  {bbalance:0,diff:0,debits:0,credits:0,ebalance:0}
      @balances[:savings] =  {bbalance:0,diff:0,debits:0,credits:0,ebalance:0}
      accts = @checking_funds + @savings_funds
      accts.each do |f|
        acct = CashAccount.find_by(name:f)
        @balances[f] = acct.balances_between(bdate,edate)
        if @checking_funds.include?(f)
          sum_from_to(@balances[f],@balances[:checking])
        else
          sum_from_to(@balances[f],@balances[:savings])
        end
      end
      @checking = @balances[:checking]
      @savings = @balances[:savings]
    end

    def sum_from_to(ffund,tfund)
      ffund.each do |k,v|
        tfund[k] += v
      end
    end

    def get_all_balances
      balances = {checking:{},savings:{}}
      accts = @checking_funds + @savings_funds
      accts.each do |f|
        acct = CashAccount.find_by(name:f)
        balances[f] = {}
        tmonths.each do |m|
          bom = Date.parse(m+"01")
          eom = bom.end_of_month
          balances[f][m] = get_fund_balances(bom,eom)
          balances[:checking][m] = @checking
          balances[:savings][m] = @savings
        end
      end
      @balances = balances
      @checking = @balances[:checking]
      @saving = @balances[:savings]
    end

  # REPORT Specific Methods
    def between_balance(from,to)
      between = {}
      accts = @checking_funds + @savings_funds
      accts.each do |f|
        acct = CashAccount.find_by(name:f)
        between[f] = acct.balances_between(from,to)
      end
      between
    end

    def audit_api(report_date)
      date = Vfwcash.set_date(report_date)
      boq = date.beginning_of_quarter
      eoq = boq.end_of_quarter
      if eoq.month >= date.month
        boq = (boq - 1.month).beginning_of_quarter
        eoq = boq.end_of_quarter
      end
      get_fund_balances(boq,eoq)
      rbalances = @balances
      rbalances["Cash"] = {bbalance:100000,ebalance:100000,debits:0,credits:0}
      rbalances[:dates] = {boq:boq,eoq:eoq, report_date:date}
      rbalances
    end

    def split_ledger_api(date)
      response = {rows:split_ledger(date)}
      response[:balances] = {checking:@checking}
      response[:month] = @bmonth
      return response
    end

    def split_ledger(date)
      @bmonth = Vfwcash.yyyymm(date)
      trans = Tran.month_transactions(date)
      lines = []
      b = @checking[:bbalance]
      trans.each do |t|
        date = Date.parse(t.post_date)
        line = {date: date.strftime("%m/%d/%Y"),num:t.num,desc:t.description,
          checking:{db:0,cr:0},details:[],balance:0, memo:nil,r:nil}
        t.splits.each do |s|
          details = s.details
          if details[:name].include?("#{@checking_acct}:")
            line[:checking][:db] += details[:db]
            line[:checking][:cr] += details[:cr]
            b += (details[:db] - details[:cr])
            line[:balance] = b
            line[:r] = details[:r]
          else
            line[:balance] = b
            if line[:memo].nil?
              line[:memo] = details[:name]
            else
              line[:memo] = "- Split Transaction -"
            end
          end
          line[:details] << details
        end
        lines << line
      end
      lines
    end

    def month_ledger_api(date)
      response = {rows:month_ledger(date)}
      fund_bal = {}
      @checking_funds.each do |f|
        fund_bal[f] = @balances[f]
      end
      response[:balances] = {savings:@savings,checking:@checking,funds:fund_bal}
      response[:funds] = {savings:@savings_funds,checking:@checking_funds}
      response[:month] = @bmonth
      return response
    end

    def month_ledger(date)
      @bmonth = Vfwcash.yyyymm(date)
      trans = Tran.month_transactions(date)
      lines = []
      trans.each do |t|
        date = Date.parse(t.post_date)
        line = {date: date.strftime("%m/%d/%Y"),num:t.num,r:nil,desc:t.description,checking:{db:0,cr:0}}
        @checking_funds.each do |f|
          line[f] = {db:0,cr:0}
        end
        line[:savings] = {db:0,cr:0}
        t.splits.each do |s|
          details = s.details
          if details[:name].include?("#{@checking_acct}:")
            line[details[:fund]][:db] += details[:db]
            line[details[:fund]][:cr] += details[:cr]
            line[:checking][:db] += details[:db]
            line[:checking][:cr] += details[:cr]
            line[:r] = details[:r]
          elsif details[:name].include?("#{@savings_acct}:")
            line[:savings][:db] += details[:db]
            line[:savings][:cr] += details[:cr]
            line[:r] = details[:r]
          end
        end

        lines << line
      end
      lines
    end

  end

end