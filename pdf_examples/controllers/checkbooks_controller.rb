

 class CheckbooksController < ApplicationController
  layout 'print'
  before_action :set_cash

  def index
  end

  def ledger
    @cash.get_fund_balances(@bom,@bom.end_of_month)
    @response = @cash.month_ledger_api(@bom)
  end

  def balance
    @cash.get_fund_balances(@bom,@bom.end_of_month)
  end

  def split
    @cash.get_fund_balances(@bom,@bom.end_of_month)
    @response = @cash.split_ledger_api(@bom)
  end

  def register
    @cash.get_fund_balances(@bom,@bom.end_of_month)
    @response = @cash.split_ledger_api(@bom)
  end

  def summary
    @cash.get_all_balances
  end

  def ledger_pdf
    pdf = Vfwcash::Api.new(@bom).ledger
    send_data pdf.render, filename: "GeneralLedger-#{@bom}",
      type: "application/pdf",
      disposition: "inline"
  end

  def summary_pdf
    pdf = Vfwcash::Api.new(@bom).summary
    send_data pdf.render, filename: "LedgerSummary-#{@bom}",
      type: "application/pdf",
      disposition: "inline"
  end


  def split_pdf
    pdf = Vfwcash::Api.new(@bom).split
    send_data pdf.render, filename: "SplitRegister-#{@bom}",
      type: "application/pdf",
      disposition: "inline"
  end

  def register_pdf
    pdf = Vfwcash::Api.new(@bom).register
    send_data pdf.render, filename: "CheckingRegister-#{@bom}",
      type: "application/pdf",
      disposition: "inline"
  end

  def audit_pdf
    pdf = Vfwcash::Api.new(@bom).audit
    send_data pdf.render, filename: "Audit-#{@bom}",
      type: "application/pdf",
      disposition: "inline"
  end

  def between
    @from = Date.parse(params[:from])
    @to = Date.parse(params[:to])
    @cash.get_fund_balances(@from,@to)
  end

  def between_pdf
    @from = Date.parse(params[:from])
    @to = Date.parse(params[:to])
    pdf = Vfwcash::Api.new(@bom).between(@from,@to)
    send_data pdf.render, filename: "Between-#{@from}_#{@to}",
      type: "application/pdf",
      disposition: "inline"

  end


  private

  def set_cash
    if params[:id].present?
      params[:id] += "01" if params[:id].length == 6
      @date = Date.parse(params[:id])
    else
      @date = Date.today
    end
    @bom = @date.beginning_of_month
    @cash = Vfwcash::Api.new(@bom).cash
  end

end
