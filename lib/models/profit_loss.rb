
class ProfitLoss < Prawn::Document
  attr_accessor :report, :level, :cur
  COL = [140,210,280,350]
  def initialize(report)
    super(page_layout: :portrait, top_margin:32, left_margin:32, right_margin:32,bottom_margin:32)
    level = 2 if level.nil?
    @report = report
    @level = @report['options'][:level]
    from = @report['options'][:from]
    to = @report['options'][:to]
    font_size(14)
    text "VFW Post 8600 Profit/Loss Report  #{from} to #{to}", style: :bold, align: :center
    move_down 6
    font_size(9)
    @cur = cursor.to_i
    generate_report
  end

  def generate_report
    total_row("Income",'','Increase')
    pad = 1
    children(pad,@report["Income"][:children])
    total_row("Total Income",@report["Income"][:total])
    pad = 1
    total_row("Expenses",'','Decrease')
    children(pad,@report["Expense"][:children])
    total_row("Total Expenses",@report["Expense"][:total])
    total_row("Profit(+)/Loss(-)",@report["Income"][:total] - @report["Expense"][:total])
  end

  def children(pad,kids)
    kids.each do |k,v|
      if v[:children].blank?
        send "pad#{pad}#{@level}_row", k,v[:amount] unless v[:amount].zero?
      else
        # if @level == 1
        if pad == @level
          unless v[:total].zero?
            send "pad#{pad}#{@level}_row",k,v[:total]+v[:amount]
          end
        else
          unless v[:total].zero?
            send "pad#{pad}#{@level}_row", k,v[:amount] 
            pad += 1
            children(pad,v[:children])
            pad -= 1
            send "pad#{pad}#{@level}_row", "Total #{k}",v[:amount] + v[:total]
          end
        end
      end
    end
  end

  def total_row(name,amount,extra=nil)
    text_box name, at: [0,@cur], width:140,align: :left, style: :bold 
    unless extra.nil?
      text_box extra, at: [COL[@level - 1],@cur], width:70,align: :right, style: :bold  
    end
    text_box imoney(amount), at: [COL[@level],@cur], width:70,align: :right, style: :bold  
    @cur -= 9 
  end

  def pad11_row(acct,amount)
    text_box acct, at: [10,@cur], width:130,align: :left   
    text_box imoney(amount), at: [140,@cur], width:70,align: :right   
    @cur -= 9
  end

  def pad12_row(acct,amount)
    text_box acct, at: [10,@cur], width:130,align: :left   
    text_box imoney(amount), at: [210,@cur], width:70,align: :right   
    @cur -= 9
  end

  def pad22_row(acct,amount)
    text_box acct, at: [20,@cur], width:120,align: :left   
    text_box imoney(amount), at: [140,@cur], width:70,align: :right   
    @cur -= 9
  end

  # def pad32_row(acct,amount)
  #   text_box acct, at: [30,@cur], width:110,align: :left   
  #   text_box imoney(amount), at: [140,@cur], width:70,align: :right   
  #   @cur -= 9
  # end


  def pad13_row(acct,amount)
    text_box acct, at: [10,@cur], width:130,align: :left   
    text_box imoney(amount), at: [280,@cur], width:70,align: :right   
    @cur -= 9
  end

  def pad23_row(acct,amount)
    text_box acct, at: [20,@cur], width:120,align: :left   
    text_box imoney(amount), at: [210,@cur], width:70,align: :right   
    @cur -= 9
  end

  def pad33_row(acct,amount)
    text_box acct, at: [30,@cur], width:100,align: :left   
    text_box imoney(amount), at: [140,@cur], width:70,align: :right   
    @cur -= 9
  end

  def imoney(int,dollar="$")
    return '' if int.to_i.zero?
    dollars = int / 100
    cents = (int % 100) / 100.0
    amt = dollars + cents
    set_zero = sprintf('%.2f',amt) # now have a string to 2 decimals
    '$'+set_zero.gsub(/(\d)(?=(\d{3})+(?!\d))/, "\\1,") # add commas
  end
 
end


