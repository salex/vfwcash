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
    desc "install", "This will install configuration files"
    long_desc <<-HELLO_WORLD

    Install will create two directories [config,pdf]in your current working directory.
    The PDF directory will contain copies of the generated PDF reports.
    The config directory will contain a config.yml file that contains post information
    and other configuration data needed to: generate a Trustees' Report of Audit, describe
    your accounts in GNUCash and define where your sqlite3 copy of your GNUCash data is located.

    HELLO_WORLD

    def install
      Vfwcash.install
    end

  ######### REGISTER
    desc "register [DATE] --split", "Product checkbook register report"
    long_desc <<-HELLO_WORLD

    produce PDF reports on the checkbook register

    HELLO_WORLD
    option :split
    def register( date=nil )
      bom = get_date(date)
      Controller.new(bom).register(options[:split])
    end

  ######### LEDGER
    desc "ledger [DATE] --summary", "Product general ledger report"
    long_desc <<-HELLO_WORLD

    produce PDF reports general ledger

    HELLO_WORLD
    option :summary
    def ledger( date=nil )
      bom = get_date(date)
      Controller.new(bom).ledger(options[:summary])
    end

  ######### Audit
    desc "audit [DATE]", "Product Trustee Audit Report "
    long_desc <<-HELLO_WORLD

    Product Trustee Audit Report

    HELLO_WORLD
    def audit( date=nil )
      bom = get_date(date)
      Controller.new(bom).audit
    end

  ######### Balance
    desc "balance [DATE]", "Product Monthly Fund Balance "
    long_desc <<-HELLO_WORLD

    Product Monthly Fund Balance

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