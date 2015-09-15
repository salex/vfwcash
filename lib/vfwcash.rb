require "vfwcash/version"
require 'vfwcash/cli'
require 'vfwcash/controller'
require 'vfwcash/api'

module Vfwcash
  # Define constants to define where your are and location of config file
  LibPath = File.expand_path(File.dirname(__FILE__))
  PWD = Dir.pwd
  Config =  YAML.load_file(File.join(PWD,'config/vfwcash.yml'))

  def self.yyyymm(date=nil)
    date = Vfwcash.set_date(date)
    yyyymm = date.strftime('%Y%m') # "#{date.year}#{date.month.to_s.rjust(2,'0')}"
  end

  def self.transaction_range
    t = Tran.order(:post_date)
    first = Date.parse(t.first.post_date).beginning_of_month
    last = Date.parse(t.last.post_date).end_of_month
    first..last
  end

  def self.set_date(date=nil)
    if date.nil? || date == ""
      date = Date.today
    elsif date.class == Date
    else
      if date.length == 6
        date += '01'
      end
      date = Date.parse(date)
    end
    date
  end

  def self.money(int)
    dollars = int / 100
    cents = (int % 100) / 100.0
    amt = dollars + cents
    set_zero = sprintf('%.2f',amt) # now have a string to 2 decimals
    set_zero.gsub(/(\d)(?=(\d{3})+(?!\d))/, "\\1,") # add commas
  end

  def self.valid_root?
    unless Dir.exist?(PWD+'/config') && Dir.exist?(PWD+'/pdf') && File.exist?(PWD+"/config/"+"vfwcash.yml")
      puts "Error: vfwcash must be run from a diectory containing valid  configuration files"
      exit(0)
    end
  end

  def self.install(options)
    wd = PWD
    ok = true
    if options['dir'].present?
      unless Dir.exist?(wd+options['dir'])
        Dir.mkdir(wd+'/'+options['dir'])
        puts "Created a new directory in #{wd}"
        ok = false
        Dir.chdir(wd+'/'+options['dir'])
        wd = Dir.pwd
      end
    end
    unless Dir.exist?(wd+'/config')
      Dir.mkdir(wd+'/config')
      puts "Created config directory in #{wd}"
      ok = false
    end
    unless Dir.exist?(wd+'/pdf')
      Dir.mkdir(wd+'/pdf')
      puts "Created pdf directory in #{wd}"
      ok = false
    end
    unless File.exist?(wd+"/config/"+"vfwcash.yml")
      FileUtils.cp((LibPath+"/templates/vfwcash.yml"),(wd+"/config/"+"vfwcash.yml"))
      puts "Created vfwcash.yml file in config directory, must be edited for your post."
      ok = false
    end
     if options['db']
      unless File.exist?(wd+"/config/"+"vfwcash.gnucash")
        FileUtils.cp((LibPath+"/templates/vfwcash.gnucash"),(wd+"/config/"+"vfwcash.gnucash"))
        puts "Created vfwcash.gnucash db in config directory."
        ok = false
      end
    end

    puts "No installation required" if ok
    puts "Installation complete. Edit your vfwcash.yml file to set your post information." if !ok
  end
end
