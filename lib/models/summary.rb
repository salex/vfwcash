class Pdf::Summary < Prawn::Document
  attr_accessor :cash, :date, :cwidths

  def initialize(cash)
    super( top_margin: 35, page_layout: :landscape)
    @cash = cash
    @cash.get_all_balances
    @config = @cash.config
    make_pdf
    number_pages "#{Date.today}   -   Page <page> of <total>", { :start_count_at => 0, :page_filter => :all, :at => [bounds.right - 100, 0], :align => :right, :size => 6 }
  end

  def header
    arr = ["General Ledger Summary for #{@cash.dates}", {content: "+ Checking -",colspan:2, align: :center}]
    @cwidths = [160,32,32]
    @cash.checking_funds.each do |f|
      arr << {content:"+ #{f} -",colspan:2, align: :center}
      @cwidths << 30
      @cwidths << 30
    end
    arr << {content:"+ Savings -",colspan:2, align: :center}
    @cwidths << 30
    @cwidths << 30
    arr
  end

  def bbalance_row(m)
    tca = @cash.balances[:savings][m][:bbalance] + @cash.balances[:checking][m][:bbalance]
    cntnt = " #{m} Beginning Balance (Current Assets #{money(tca)} )"
    arr = [{content: cntnt,font_style: :bold}]
    arr << {content: money(@cash.balances[:checking][m][:bbalance]),colspan:2, align: :center,font_style: :bold}
    @cash.checking_funds.each do |f|
      arr << { content: money(@cash.balances[f][m][:bbalance]),colspan:2, align: :center,font_style: :bold}
    end
    arr << {content: money(@cash.balances[:savings][m][:bbalance]),colspan:2, align: :center,font_style: :bold}
    arr
  end

  def ebalance_row(m)
    tca = @cash.balances[:savings][m][:bbalance] + @cash.balances[:checking][m][:bbalance]
    cntnt = " #{m} Current Balance (Current Assets #{money(tca)} )"
    arr = [{content: cntnt,font_style: :bold}]
    arr << {content: money(@cash.balances[:checking][m][:ebalance]),colspan:2, align: :center,font_style: :bold}
    @cash.checking_funds.each do |f|
      arr << { content: money(@cash.balances[f][m][:ebalance]),colspan:2, align: :center,font_style: :bold}
    end
    arr << {content: money(@cash.balances[:savings][m][:ebalance]),colspan:2, align: :center,font_style: :bold}
    arr
  end

  def summary_row(m)
    pl = @cash.balances[:savings][m][:diff] + @cash.balances[:checking][m][:diff]
    cntnt = "Total Debits/Credits (Profit/Loss: #{money(pl)})"
    arr = [{content: cntnt,font_style: :bold}]
    arr << {content: money(@cash.balances[:checking][m][:debits]), align: :right}
    arr << {content: money(@cash.balances[:checking][m][:credits]), align: :right}
    @cash.checking_funds.each do |f|
      arr << {content: money(@cash.balances[f][m][:debits]), align: :right}
      arr << {content: money(@cash.balances[f][m][:credits]), align: :right}
    end
    arr << {content: money(@cash.balances[:savings][m][:debits]), align: :right}
    arr << {content: money(@cash.balances[:savings][m][:credits]), align: :right}
    arr
  end

 
  def make_pdf
    font_size 6
    build_table
    draw_table
  end

  def build_table
    @rows = [header]
    @cash.tmonths.each do |m|
      @rows << bbalance_row(m)
      @rows << summary_row(m)
    end
    m = @cash.tmonths.last
    @rows << ebalance_row(m)
  end

  def draw_table
    text "#{@config[:post][:post]} General Ledger Summary", style: :bold, align: :center
    move_down(2)
    e = make_table @rows,row_colors: ["F8F8F8", "FFFFFF"],:cell_style => {:padding => [1, 2, 2, 1],border_color:"E0E0E0"}, 
      :column_widths => @cwidths, header:true do
      
      row(0).font_style = :bold
    end
    e.draw
  end

  def money(int)
    Vfwcash.money(int)
  end

end
