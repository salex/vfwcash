class Ledger < Prawn::Document
  attr_accessor :response, :date, :cwidths

  def initialize(date,cash)
    super( top_margin: 35, page_layout: :landscape)
    @date = Vfwcash.set_date(date).beginning_of_month
    @config = cash.config
    cash.get_fund_balances(@date,@date.end_of_month)
    @response = cash.month_ledger_api(@date)

    make_pdf
    number_pages "#{Date.today}   -   Page <page> of <total>", { :start_count_at => 0, :page_filter => :all, :at => [bounds.right - 100, 0], :align => :right, :size => 6 }
  end

  def header
    arr = ["Date", "Num","R", "Description", {content: "+ Checking -",colspan:2, align: :center}]
    @cwidths = [36, 22,8,108,32,32]
    @response[:funds][:checking].each do |f|
      arr << {content:"+ #{f} -",colspan:2, align: :center}
      @cwidths << 30
      @cwidths << 30
    end
    arr << {content:"+ Savings -",colspan:2, align: :center}
    @cwidths << 30
    @cwidths << 30
    arr
  end

  def bbalance_row
    cntnt = "Beginning balance #{@response[:month]}: "
    cntnt += "Total Current Assets #{money(@response[:balances][:savings][:bbalance] + @response[:balances][:checking][:bbalance])}"

    arr = [{content: cntnt,colspan:4,font_style: :bold}]
    arr << {content: money(@response[:balances][:checking][:bbalance]),colspan:2, align: :center,font_style: :bold}
    @response[:funds][:checking].each do |f|
      arr << { content: money(@response[:balances][:funds][f][:bbalance]),colspan:2, align: :center,font_style: :bold}
    end
    arr << {content: money(@response[:balances][:savings][:bbalance]),colspan:2, align: :center,font_style: :bold}
    arr
  end

  def ebalance_row
    cntnt = "Ending balance #{@response[:month]}: "
    cntnt += "Total Current Assets #{money(@response[:balances][:savings][:ebalance] + @response[:balances][:checking][:ebalance])}"

    arr = [{content: cntnt,colspan:4,font_style: :bold}]
    arr << {content: money(@response[:balances][:checking][:ebalance]),colspan:2, align: :center,font_style: :bold}
    @response[:funds][:checking].each do |f|
      arr << { content: money(@response[:balances][:funds][f][:ebalance]),colspan:2, align: :center,font_style: :bold}
    end
    arr << {content: money(@response[:balances][:savings][:ebalance]),colspan:2, align: :center,font_style: :bold}
    arr
  end

  def summary_row
    cntnt = "Debits/Credits Summary #{@response[:month]}: "
    arr = [{content: cntnt,colspan:4,font_style: :bold}]
    arr << {content: money(@response[:balances][:checking][:debits]), align: :right}
    arr << {content: money(@response[:balances][:checking][:credits]), align: :right}
    @response[:funds][:checking].each do |f|
      arr << {content: money(@response[:balances][:funds][f][:debits]), align: :right}
      arr << {content: money(@response[:balances][:funds][f][:credits]), align: :right}
    end
    arr << {content: money(@response[:balances][:savings][:debits]), align: :right}
    arr << {content: money(@response[:balances][:savings][:credits]), align: :right}
    arr
  end

  def make_pdf
    font_size 6
    build_table
    draw_table
  end

  def build_table
    @rows = [header]
    @rows << bbalance_row
    @response[:rows].each do |r|
      arr = []
      r.each do |k,v|
        if v.class == Hash
          arr << (v[:db].zero? ? nil :{content: (money(v[:db])), align: :right})
          arr << (v[:cr].zero? ? nil :{content: (money(v[:cr])), align: :right})
        else
          arr << v
        end
      end
      @rows << arr
    end
    @rows << summary_row
    @rows << ebalance_row
  end

  def draw_table
    text "#{@config[:post][:post]} General Ledger - #{@date}", style: :bold, align: :center
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
