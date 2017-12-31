require 'thor'
# require 'vfwcash/cli/register'
require 'chronic'
require 'active_support'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/date/calculations'


module Vfwcash

  class Checkbook < Thor
    map %w[--dates -d] => :__print_date_help

    desc "--dates, -d", "print date format options"
    def __print_date_help
      puts <<-DATE_HELP
        The DATE parameter is optional on all reports requiring a date and will default to the current date if not present.

        Most dates will be converted to the first of the month requardless of the date entered.

        Entered dates are parsed using Chronic (https://github.com/mojombo/chronic).
        Chronic provide a wide range options.

        Probably the easiest option is the yyyy-mm format (again day is optional) but you can do stuff like:
          last-may
          last-October
          'oct 2014'
        DATE_HELP
    end

  desc "between date1 date2", "Get balances between two dates"
  long_desc <<-HELLO_WORLD

  Produces a Fund Balance summary between two dates (beginning balance, debits, credits, ending balance) in a compact format.

  HELLO_WORLD

  def between(first, last)
    sdate = get_date(first)
    edate = get_date(last)
    bom = sdate - sdate.day + 1
    Controller.new(bom).between(sdate,edate)
  end


  ######### VERSION
    map %w[--version -v] => :__print_version

     desc "--version, -v", "print the version"
     def __print_version
       puts "Version: #{Vfwcash::VERSION}"
     end

  ##### profit_loss
    desc "profit_loss [--lev --from --to]","Generate profit/loss pdf with depth of --lev beteween dates --from and --to"
    method_option :lev, type: :numeric,
                           desc: "Depth of account hiearchy",
                           required: false,
                           default: 2
    method_option :from, type: :string,
                           required: false,
                           desc: "From date, defaults to first of current month"
    method_option :to, type: :string,
                           required: false,
                           desc: "To date, defaults to end of current month"

    def profit_loss
      # puts "Generate profit_loss report with options  #{options.inspect}"
      Controller.new(Date.today).profit_loss(options)

      # api = Api.new(Date.today.beginning_of_month)
      # pl = api.cash.profit_loss(options)
      # puts api.cash.profit_loss(options).inspect
    end

  ######### INSTALL
    desc "install [--dir --db]", "Install config files and optional test DB in pwd or pwd/--dir"
    long_desc <<-HELLO_WORLD

    Install will create two directories [config,pdf]in your current working directory.
    The PDF directory will contain copies of the generated PDF reports.
    The config directory will contain a vfwcash.yml file that contains post information, 
    path to sqlit3 database
    and other configuration data needed to generate a Trustees' Report of Audit.

    -- dir='dirname' will create a new directory in the working directory before the copies

    -- db will copy a GnuCash test sqlite3 database into the config directory

    HELLO_WORLD
    method_option :dir, type: :string,
                           desc: "Create a new directory",
                           required: false
    method_option :db, type: :boolean,
                           default: false,
                           desc: "Copy a Test GnuCash Database to the config directory"


    def install
      Vfwcash.install(options)
    end

  ######### REGISTER
    desc "register [DATE]", "Checkbook register report"
    long_desc <<-HELLO_WORLD

    Produces a PDF reports of the checkbook register by month. All tranasaction for the month
    are displayed, ordered by date and check number. A running balance is displayed starting with the
    beginning balance. There is one line per transaction. Savings account transactions are displayed
    but the amount is not added to the running balance.

    The --split option displays the same information, but lines are added for each transaction showing 
    the amount of each split by fund or income/expense account


    HELLO_WORLD
    def register( date=nil )
      bom = get_date(date)
      Controller.new(bom).register
    end

  ######### SPLIT
    desc "split [DATE]", "Checkbook split register report"
    long_desc <<-HELLO_WORLD

    Produces a PDF reports of the checkbook register by month. All tranasaction for the month
    are displayed, ordered by date and check number. A running balance is displayed starting with the
    beginning balance. Savings account transactions are displayed
    but the amount is not added to the running balance.

    Each transaction will have multiple lines displaying 
    the amount of each split by fund or income/expense account


    HELLO_WORLD
    def split( date=nil )
      bom = get_date(date)
      Controller.new(bom).split
    end

  ######### LEDGER
    desc "ledger [DATE]", "General Ledger report by month"
    long_desc <<-HELLO_WORLD

    Produces a PDF report of the Post's General Ledger formated much like the VFW Ledger book.

    Each transaction displays tranaction information along with each fund distribution. Balances include
    the beginning balance, total debits(increases) and credits(decreases) and ending balance.

    HELLO_WORLD

    option :summary
    def ledger( date=nil )
      bom = get_date(date)
      Controller.new(bom).ledger
    end

  ######### SUMMARY
    desc "summary [DATE]", "General Ledger Summary Report"
    long_desc <<-HELLO_WORLD

    Produces a PDF report containing only a monthly summary of Post's General Ledger.

    The report displays all months in the checkbook but only contains balances, debits and credits sums.

    HELLO_WORLD

    option :summary
    def summary( date=nil )
      bom = get_date(date)
      Controller.new(bom).summary
    end

  ######### Audit
    desc "audit [DATE]", "Trustee Audit Report "
     long_desc <<-HELLO_WORLD

     Productes a Trustee Audit Report for the ending quarter that ended before
     the date enter. If date is not ended, it will be the last report.

     HELLO_WORLD

    def audit( date=nil )
      bom = get_date(date)
      Controller.new(bom).audit
    end

  ######### Balance
    desc "balance [DATE]", "Monthly Fund Balance Summary "
    long_desc <<-HELLO_WORLD

    Produces a Monthly Fund Balance summary (beginning balance, debits, credits, ending balance) for only one month in a compact format.

    HELLO_WORLD
    def balance( date=nil )
      bom = get_date(date)
      Controller.new(bom).balance
    end

    private

    def get_date(date)
      if  date.nil?
        bom = Date.today
      else
        bom = Chronic.parse(date)
        if bom.nil?
          puts "Invalid date #{date}"
          exit(0)
        else
          bom = bom.to_date
        end
      end
      bom
    end


  end
end