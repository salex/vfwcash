# VFWCash

A beta version of a Ruby gem that provides a Command Line Interface (CLI) to generates VFW formated reports(pdf) from a GnuCash book. It also provides an pseudo API to access the same reports and/or data if accessing the reports from another application.

## Why

VFW Quartermasters are required to keep Post accounting books. Procedures only address manual/paper ledgers and reports.
This is fine for a small Post that only writes a few checks a month. Automated ledgers are allowed, but paper backup is 
required.

I was not about to use a paper ledger and decided to use GnuCash (http://gnucash.org) several years ago. GnuCash is a full fledged double entry accounting system somewhere between Quicken and Quickbooks and it's free! 
I had developed a Rails Web Based system to help me with my Quartermaster tasks, but is was fairly customized, including my
interface to the GnuCash data.
GnuCash was set up to use the VFW's version of Fund Based Accounting. This became fairly simple and
could be used by any Post or any organization that uses fund based accounting (most non-profit organizations)
I'll point out that we do not use
GnuCash as our main accounting system, although we could.  We have an Accountant that handles mainly payroll and taxes and we send them the information they need (in reports or source documents). We basically use it as a checkbook, fund manager and enter stuff from the accountant (payroll checks, eft or forms to pay taxes etc). I also summarize income and expense from our customized post management system (sales, donations, etc).

I wanted to share my work, but I work on a Mac and setting up Ruby on Rails on Windows would probably be more than most VFW
users could handle.  Setting up Ruby on Windows is fairly straight forward (http://rubyinstaller.org) and so I decided to
write a command line interface to the models and Prawn PDF reports I had developed. Hopefully I can document how to use the CLI on Windows, if I can remember how to use Windows! I also replaced my GnuCash interface in our custom application to use VFWCash

## Installation

The gem has not been uploaded to Ruby Gems during beta testing, but you can install it locally by cloning vfwcash

```ruby
git git@github.com:salex/vfwcash.git 
```

And then execute:

    $ cd vfwcash
    $ rake build
    $ rake install
    $ mkdir ~./some_rails_like_app_directory
    $ cd ~./some_rails_like_app_directory
    $ vfwcash help
    $ vfwcash install -db

Or work with the development version:

    $ cd vfwcash
    $ bundle
    $ bundle exec bin/vfwcash help
      -> commands
    $ bundle exec bin/vfwcash help install
      -> install help
    $ bundle exec bin/vfwcash install -db

## Usage

The Wiki has brief documentation on how to set up GnuCash for fund based accounting, but for
now the vfwcash install command with a --db option will install a small sqlite3 database in the config directory, That db
only contains a few transactions for the months April through August of 2015.  You don't need GnuCash 
installed to use the CLI, unless you want to add transactions.

You must edit the config/vfwcash.yml file after it is installed and set the absolute path to the sqlite3 database and other attributes that define you Post and your GnuCash setup.

GunCash's default data format is XML, but there is an option to use a sqlite3 database in the default download (Postgresql or Mysql if you want to roll your own). I still use the
XML version because of a built-in backup scheme. Since I'm only concerned with reports a few times a month, I use `Save As` to create a sqlite3 copy of the database for reporting.
The VFWCash database is read-only so it could point to the primary db, but that brings up single-user problems (GnuCash implementation) that locks the db to a single user.

Once installed and configured, `vwfcash help` will display:

    Commands:
      vfwcash --dates, -d         # print date format options
      vfwcash --version, -v       # print the version
      vfwcash audit [DATE]        # Trustee Audit Report 
      vfwcash balance [DATE]      # Monthly Fund Balance Summary
      vfwcash between date1 date2   # Get balances between two dates
      vfwcash help [COMMAND]      # Describe available commands or one specific command
      vfwcash install --dir --db  # Install config files and optional test DB in pwd or pwd/--dir
      vfwcash ledger [DATE]       # General Ledger report by month
      vfwcash register [DATE]     # Checkbook register report
      vfwcash split [DATE]        # Checkbook split register report
      vfwcash summary [DATE]      # General Ledger Summary Report

There are 7 basic reports derived from GnuCash accounts, transactions and splits. You can view examples
of these reports in the folder [`pdf_examples`](https://github.com/salex/vfwcash/tree/master/pdf_examples) on github

* register
  * A checkbook like register with transactions by date and number/ Single line summarizing transaction, no splits
* split
  * The same as register but with all splits (there will be at least two) displayed on a separate line
* ledger
  * A general ledger by date and number with a debit/credit column for each fund account. The report includes starting and ending balances, and summed credits and debits for the month
* summary
  * A general ledger for all months in db, but only displays summary balances, debits and credits by month.
* audit
  * Produces a PDF version of VFW Form:  Trustees Audit Report (summarizes transactions by quarter)
* balance
  * Like the summary command, but only produces a summary of fund balances, debits and credits for a single month in a compact format.
* between
  * Same format as balance, but produces a summary between any two dates. 

### API

I will put something in the wiki to describe how to use VFWCash from another application at some point. There is another controller to access the same reports or data from another application. There is a sample RoR controller and views in the examples directory that uses this option.

## Contributing

1. Fork it ( https://github.com/salex/vfwcash/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
