require 'thor'
# require 'vfwcash/cli/register'
require 'chronic'
require 'active_support'


module Vfwcash

  class Checkbook < Thor


  ######### VERSION
    desc 'version', "Print Vfwcash version"
    def version
      puts "Version: #{Vfwcash::VERSION}"
    end

  ######### INSTALL
    desc "install", "Install configuration files and test DB in working directory"
    long_desc <<-HELLO_WORLD

    Install will create two directories [config,pdf]in your current working directory.
    The PDF directory will contain copies of the generated PDF reports.
    The config directory will contain a config.yml file that contains post information
    and other configuration data needed to: generate a Trustees' Report of Audit, describe
    your accounts in GNUCash and define where the sqlite3 copy of your GNUCash data is located.

    HELLO_WORLD

    def install
      Vfwcash.install
    end

  ######### REGISTER
    desc "register [DATE] --split", "Checkbook register report with options"
    long_desc <<-HELLO_WORLD

    Produces a PDF reports of the checkbook register by month. All tranasaction for the month
    are displayed, ordered by date and check number. A running balance is displayed starting with the
    beginning balance. There is one line per transaction. Savings account transactions are displayed
    but the amount is not added to the running balance.

    The --split option displays the same information, but lines are added for each transaction showing 
    the amount of each split by fund or income/expense account


    HELLO_WORLD
    option :split
    def register( date=nil )
      bom = get_date(date)
      Controller.new(bom).register(options[:split])
    end

  ######### LEDGER
    desc "ledger [DATE] --summary", "General Ledger report with options"
    long_desc <<-HELLO_WORLD

    Produces a PDF report of the Post's General Ledger formated much like the VFW Ledger book.

    Each transaction displays tranaction information along with each fund distribution. Balances include
    the beginning balance, total debits(increases) and credits(decreases) and ending balance.

    The --summary option produces a report for all months and only contains balances.

    HELLO_WORLD

    option :summary
    def ledger( date=nil )
      bom = get_date(date)
      Controller.new(bom).ledger(options[:summary])
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

    Product Monthly Fund Balance summay for only one month in a compact format.

    HELLO_WORLD
    def balance( date=nil )
      bom = get_date(date)
      Controller.new(bom).balance
    end

    desc "dates", "Date formats and information"
    long_desc <<-DATE_HELP
    The DATE parameter is optional (unless a --option is entered) and will default to the current date.

    All dates will be converted to the first of the month requardless of the date entered.

    Entered dates are parsed using Chronic (https://github.com/mojombo/chronic).
    Chronic provide a wide range options.

    Probably the easiest option is the yyyy-mm format (again day is optional)
    DATE_HELP
    def dates
      puts "Happy Dating"
    end


    private

    def get_date(date)
      if  date.nil?
        bom = Date.today
      else
        puts date
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