 # VFWcash

A beta version of a Ruby Command Line gem that generates VFW formated reports(pdf) from a GnuCash book.

## Why

VFW Quartermasters are required to keep Post accounting books. Procedures only address manual/paper ledgers and reports.
This is fine for a small Post that only writes a few checks a month. Automated ledgers are allowed, but paper backup is 
required.

I was not about to use a paper ledger and decided to use GnuCash (http://gnucash.org) several years ago. GnuCash is a full fledged double entry accounting system somewhere between Quicken and Quickbooks and it's free!
I had developed a Rails Web Based system to help me with my Quartermaster tasks, but is was fairly customized, including my
interface to the GnuCash data.
The GnuCash was set up to use the VFW's version of Fund Based Accounting. This became fairly simple and
I thought it could be used by any Post or any organization that uses fund based accounting (most non-profit organizations)

I felt I could share my work, but I work on a Mac and setting up Rails on Windows would probably be more than most VFW
users could handle.  Setting up Ruby on Windows is fairly straight forward (http://rubyinstaller.org) and so decided to
write a command line interface to the models and Prawn PDF reports I had developed. Hopefully I can document how to use the CLI.


## Installation

The gem has not been uploaded to Ruby Gems yet, but you can install it locally by cloning vfwcash

```ruby
git git@github.com:salex/Assessable.git 
```

And then execute:

    $ cd vfwcash
    $ rake build
    $ rake install
    $ mkdir ~./some_rails_like_app_directory
    $ cd ~./some_rails_like_app_directory
    $ vfwcash help
    $ vfwcash install

Or work with the development version:

    $ cd vfwcash
    $ bundle
    $ bundle exec bin/vfwcash help
    $ bundle exec bin/vfwcash install

## Usage

I will write a wiki documentation on how to set up GnuCash at some point, but for
now the vfwcash install command will install a small sqlite3 database in the config directory that
only contains a few transactions for the months April through August of 2015.  You don't need GnuCash 
installed to use the CLI, unless you want to add transactions.

You must edit the config/config.yml file after it is installed and set the absolute path to the sqlite3 database.

GunCash's default data format is XML, but there is an option to use sqlite3 in the default download (Postgresql or Mysql if you want to roll your own). I use the
XML version because of a built-in backup scheme. I then `Save As` to sqlite3 to create a copy of the database for reporting.
VFWCash database is read-only so it could use the primary db, but that brings up single-user problems (GnuCash implementation)

Once installed and configured, `vwfcash help` will display:

    Commands:
      vfwcash audit [DATE]             # Trustee Audit Report 
      vfwcash balance [DATE]           # Monthly Fund Balance Summary 
      vfwcash dates                    # Date formats and information (help dates)
      vfwcash help [COMMAND]           # Describe available commands or one specific command
      vfwcash install                  # Install configuration files and test DB in working directory
      vfwcash ledger [DATE] --summary  # General Ledger report with options
      vfwcash register [DATE] --split  # Checkbook register report with options
      vfwcash version                  # Print VFWcash version

There are 4 basic reports with some options

* register
  * A checkbook like register with transactions by date and number, single line, no splits
  * The --split option is about same as register but with all splits (there will be at least two) displayed
* ledger
  * A general ledger book version by date and number with a debit/credit column for each fund account
  * The --summary display summary balances only for all months
* audit - Produces a PDF version of VFW Form:  Trustees Audit Report (sumarizes transactions by quarter)
* balance - Produces a summary of fund balances for a single month.

## Contributing

1. Fork it ( https://github.com/salex/vfwcash/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
