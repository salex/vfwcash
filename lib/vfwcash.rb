require "vfwcash/version"
require 'vfwcash/cli'
require 'vfwcash/controller'

module Vfwcash
  # Your code goes here...
  LibPath = File.expand_path(File.dirname(__FILE__))
  PWD = Dir.pwd

  def self.yyyymm(date=nil)
    date = Vfwcash.set_date(date)
    yyyymm = "#{date.year}#{date.month.to_s.rjust(2,'0')}"
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
    unless Dir.exist?(PWD+'/config') && Dir.exist?(PWD+'/pdf') && File.exist?(PWD+"/config/"+"config.yml")
      puts "Error: vfwcash must be run from a diectory containing valid  configuration files"
      exit(0)
    end
  end

  def self.install
    ok = true
    unless Dir.exist?(PWD+'/config')
      Dir.mkdir(PWD+'/config')
      puts "Created config directory in #{PWD}"
      ok = false
    end
    unless Dir.exist?(PWD+'/pdf')
      Dir.mkdir(PWD+'/pdf')
      puts "Created pdf directory in #{PWD}"
      ok = false
    end
    unless File.exist?(PWD+"/config/"+"config.yml")
      FileUtils.cp((LibPath+"/templates/config.yml"),(PWD+"/config/"+"config.yml"))
      puts "Created config.yml file in config directory, must be edited for your post."
      ok = false
    end
    unless File.exist?(PWD+"/config/"+"vfw-gray.png")
      FileUtils.cp((LibPath+"/templates/vfw-gray.png"),(PWD+"/config/"+"vfw-gray.png"))
      puts "Created vfw-gray.png image in config directory."
      ok = false
    end
    unless File.exist?(PWD+"/config/"+"vfwcash.gnucash")
      FileUtils.cp((LibPath+"/templates/vfwcash.gnucash"),(PWD+"/config/"+"vfwcash.gnucash"))
      puts "Created vfwcash.gnucash db in config directory."
      ok = false
    end

    puts "No installation required" if ok
    puts "Installation complete. Edit your config.yml file to set your post information." if !ok
  end
end
