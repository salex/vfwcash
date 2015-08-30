# VFWcash

A beta version of a Ruby Command Line gem that generates VFW formated reports(pdf) from a GnuCash book.

## Why

VFW Quartermasters are required to keep Post accounting books. Procedures only address manual/paper ledgers and reports.
This is fine for a small Post that only writes a few checks a month. Automated ledgers are allowed, but paper backup is 
required.

I was not about to use a paper ledger and decided to use GnuCash (http://gnucash.org) several years ago. GnuCash is a full fledged double entry accounting system somewhere between Quicken and Quickbooks and it's free!
I had developed a Rails Web Based system to help me with my Quartermaster tasks, but is was fairly customized, including my
interface to the GnuCash data.
GnuCash was set up to use the VFW's version of Fund Based Accounting. This became fairly simple and
could be used by any Post or any organization that uses fund based accounting (most non-profit organizations)

I wanted to share my work, but I work on a Mac and setting up Rails on Windows would probably be more than most VFW
users could handle.  Setting up Ruby on Windows is fairly straight forward (http://rubyinstaller.org) and so I decided to
write a command line interface to the models and Prawn PDF reports I had developed. Hopefully I can document how to use the CLI.

## Installation

The gem has not been uploaded to Ruby Gems yet, but you can install it locally by cloning vfwcash

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

You must edit the config/config.yml file after it is installed and set the absolute path to the sqlite3 database.

GunCash's default data format is XML, but there is an option to use a sqlite3 database in the default download (Postgresql or Mysql if you want to roll your own). I still use the
XML version because of a built-in backup scheme. Since I'm only concerned with reports a few times a month, I use `Save As` to create a sqlite3 copy of the database for reporting.
The VFWCash database is read-only so it could point to the primary db, but that brings up single-user problems (GnuCash implementation)

Once installed and configured, `vwfcash help` will display:

    Commands:
      vfwcash --dates, -d         # print date format options
      vfwcash --version, -v       # print the version
      vfwcash audit [DATE]        # Trustee Audit Report 
      vfwcash balance [DATE]      # Monthly Fund Balance Summary 
      vfwcash help [COMMAND]      # Describe available commands or one specific command
      vfwcash install --dir --db  # Install config files and optional test DB in pwd or pwd/--dir
      vfwcash ledger [DATE]       # General Ledger report by month
      vfwcash register [DATE]     # Checkbook register report
      vfwcash split [DATE]        # Checkbook split register report
      vfwcash summary [DATE]      # General Ledger Summary Report

There are 6 basic reports derived from GnuCash accounts, transactions and splits. You can view examples
of these reports in the folder [`pdf_examples`](https://github.com/salex/vfwcash/tree/master/pdf_examples) on github

* register
  * A checkbook like register with transactions by date and number/ Single line summarizing transaction, no splits
* split
  * The same as register but with all splits (there will be at least two) displayed on a separate line
* ledger
  * A general ledger by date and number with a debit/credit column for each fund account. The report includes starting and ending balances, and summed credits and debits for the month
* summary
  * A general ledger by month but only displays summary balances, debits and credits
* audit
  * Produces a PDF version of VFW Form:  Trustees Audit Report (summarizes transactions by quarter)
* balance
  * Like the summary command, but only produces a summary of fund balances, debits and credits for a single month in a compact format.

## Contributing

1. Fork it ( https://github.com/salex/vfwcash/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
