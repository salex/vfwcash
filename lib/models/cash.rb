require "yaml/store"

module Vfwcash

  class Cash
    # Cash is the primary interface to the GNUCash database
    # The initializer sets attributes based on data in the db and from the config file
    # that is common to all reports.
    # Balance are computed and stored in a YAML::Store file and only updted if a new transaction
    # is added to db.

    # API calls provide informtion needed for specific reports.

    attr_accessor  :balances, :checking, :savings, :checking_funds,:savings_funds,
    :dates, :bmonth, :checking_acct, :savings_acct, :tmonths, :config, :store

     def initialize(store)
      @store = store
      @config = store[:config]
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

    def get_balances
      @store.transaction do
        last_entry = Tran.order(:enter_date).last.enter_date
        if @store[:balances].present? && last_entry <= @config[:last_entry]
          @balances = @store[:balances]
          # puts "STORE"
        else
          get_acct_balances
          @balances[:checking] = set_parent_balance(@checking_funds)
          @balances[:savings] = set_parent_balance(@savings_funds)
          @store[:balances] = balances
          @config[:last_entry] = last_entry
          # Update last_entry and save the config.yml file
          File.open(File.join(Dir.pwd,'config/config.yml'), 'w+') {|f| f.write(@config.to_yaml)}
          # puts "LOAD"
        end
        @checking = @balances[:checking]
        @savings = @balances[:savings]
      end
    end

    def get_acct_balances
      @balances = {}
      accts = @checking_funds + @savings_funds
      accts.each do |f|
        acct = CashAccount.find_by(name:f)
        @balances[f] = acct.balances(@dates.first,@dates.last)
      end
    end

    def set_parent_balance(funds)
      results = {}
      @tmonths.each do |m|
        results[m] = {bbalance:0,diff:0,debits:0,credits:0,ebalance:0}
        funds.each do |f|
          @balances[f][m].each do |k,v|
            results[m][k] += v
          end
        end
      end
      results
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
      get_balances
      yyyymm = []

      0.upto(2) do |i|
        yyyymm[i] = Vfwcash.yyyymm(boq+i.months)
      end
      rbalances = {}
      @checking_funds.each do |f|
        rbalances[f] = {bbalance:@balances[f][yyyymm.first][:bbalance],ebalance:@balances[f][yyyymm.last][:ebalance]}
        db = 0
        cr = 0
        yyyymm.each do |m|
          db += @balances[f][m][:debits]
          cr += @balances[f][m][:credits]
        end
        rbalances[f][:debits] = db
        rbalances[f][:credits] = cr
      end
      rbalances["Savings"] = {bbalance:@savings[yyyymm.first][:bbalance],ebalance:@savings[yyyymm.last][:ebalance]}
      db = 0
      cr = 0
      yyyymm.each do |m|
        db += @savings[m][:debits]
        cr += @savings[m][:credits]
      end
      rbalances["Savings"][:debits] = db
      rbalances["Savings"][:credits] = cr
      rbalances["Checking"] = {bbalance:@checking[yyyymm.first][:bbalance],ebalance:@checking[yyyymm.last][:ebalance],debits:0,credits:0}
      rbalances["Cash"] = {bbalance:100000,ebalance:100000,debits:0,credits:0}
      rbalances[:dates] = {boq:boq,eoq:eoq, report_date:date}
      rbalances
    end

    def split_ledger_api(date)
      response = {rows:split_ledger(date)}
      response[:balances] = {checking:@checking[@bmonth]}
      response[:month] = @bmonth
      return response
    end

    def split_ledger(date)
      @bmonth = Vfwcash.yyyymm(date)
      trans = Tran.month_transactions(date)
      lines = []
      b = @checking[@bmonth][:bbalance]
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
        fund_bal[f] = @balances[f][@bmonth]
      end
      response[:balances] = {savings:@savings[@bmonth],checking:@checking[@bmonth],funds:fund_bal}
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