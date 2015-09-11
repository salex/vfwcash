class Pdf::Between < Prawn::Document
  attr_accessor :cash, :date, :cwidths

  def initialize(date,cash,from,to)
    super( top_margin: 35, page_layout: :landscape)
    @date = Vfwcash.set_date(date).beginning_of_month
    @from = Vfwcash.set_date(from)
    @to = Vfwcash.set_date(to)

    @m = Vfwcash.yyyymm(@date)
    @cash = cash
    @cash.get_fund_balances(@from,@to)
    @results = cash.balances
    @config = @cash.config
    # reset_balance
    make_pdf
    number_pages "#{Date.today}   -   Page <page> of <total>", { :start_count_at => 0, :page_filter => :all, :at => [bounds.right - 100, 0], :align => :right, :size => 6 }
  end

  def header
    arr = %w(Fund BeginBal Debits Credits P/L EndBal)
  end

  def checking_row
    arr = ["Checking"]
    arr << {content: money(@results[:checking][:bbalance]), align: :right}
    arr << {content: money(@results[:checking][:debits]), align: :right}
    arr << {content: money(@results[:checking][:credits]), align: :right}
    arr << {content: money(@results[:checking][:diff]), align: :right}
    arr << {content: money(@results[:checking][:ebalance]), align: :right}
    arr
  end

  def savings_row
    arr = ["Savings"]
    arr << {content: money(@results[:savings][:bbalance]), align: :right}
    arr << {content: money(@results[:savings][:debits]), align: :right}
    arr << {content: money(@results[:savings][:credits]), align: :right}
    arr << {content: money(@results[:savings][:diff]), align: :right}
    arr << {content: money(@results[:savings][:ebalance]), align: :right}
    arr
  end

  def fund_rows
    farr = []
    @cash.checking_funds.each do |f|
      arr = [f]
      arr << {content: money(@results[f][:bbalance]), align: :right}
      arr << {content: money(@results[f][:debits]), align: :right}
      arr << {content: money(@results[f][:credits]), align: :right}
      arr << {content: money(@results[f][:diff]), align: :right}
      arr << {content: money(@results[f][:ebalance]), align: :right}
      farr << arr
    end
    farr
  end

  def curr_assets_row
    arr = ["Curr Assets"]
    arr << {content: money(@results[:checking][:bbalance] + @results[:savings][:bbalance]), align: :right}
    arr << {content: money(@results[:checking][:debits] + @results[:savings][:debits]), align: :right}
    arr << {content: money(@results[:checking][:credits] + @results[:savings][:credits]), align: :right}
    arr << {content: money(@results[:checking][:diff] + @results[:savings][:diff]), align: :right}
    arr << {content: money(@results[:checking][:ebalance] + @results[:savings][:ebalance]), align: :right}
    arr

  end

  def make_pdf
    font_size 9
    build_table
    draw_table
  end

  def build_table
    @rows = [header]
    @rows << checking_row
    @rows += fund_rows
    @rows << savings_row
    @rows << curr_assets_row
  end

  def draw_table
    text "#{@config[:post][:post]} General Ledger Balances Between #{@from} and #{@to}", style: :bold, align: :center
    move_down(2)
    e = make_table @rows,row_colors: ["F8F8F8", "FFFFFF"],:cell_style => {:padding => [1, 2, 2, 1],border_color:"E0E0E0"}, 
      :column_widths => [60,60,60,60,60,60], header:true do
      
      row(0).font_style = :bold
      row(0).align = :center
      column(0).font_style = :bold
    end
    e.draw
  end

  def money(int)
    Vfwcash.money(int)
  end

end
