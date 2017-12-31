class RegisterPdf < Prawn::Document
  attr_accessor :response, :date

  def initialize(date,cash)
    super( top_margin: 35)
    @date = Vfwcash.set_date(date).beginning_of_month
    @config = cash.config
    cash.get_fund_balances(@date,@date.end_of_month)
    @response = cash.split_ledger_api(@date)
    make_pdf
    number_pages "#{Date.today}   -   Page <page> of <total>", { :start_count_at => 0, :page_filter => :all, :at => [bounds.right - 100, 0], :align => :right, :size => 6 }
  end

  def header
    arr = ["Date", "Num","Description","Account","R","Debits","Credits", "Balance"]
  end

  def balance_row
    [{content:'',colspan: 2},"Beginning Balance",nil,nil,nil,nil,{content: money(@response[:balances][:checking][:bbalance]),align: :right}]
  end

  def make_pdf
    font_size 7
    build_table
    draw_table
  end

  def build_table
    @rows = [header]
    @rows << balance_row
    @response[:rows].each do |row|
      arr =  [row[:date],row[:num],row[:desc],row[:memo],row[:r]]
      arr << (row[:checking][:db].zero? ? nil : {content: money(row[:checking][:db]), align: :right})
      arr << (row[:checking][:cr].zero? ? nil : {content: money(row[:checking][:cr]), align: :right})
      arr << (row[:balance].zero? ? nil : {content: money(row[:balance]), align: :right})
      @rows << arr
    end
  end

  def draw_table
    text "#{@config[:post][:post]} Checkbook Register - #{@date}", style: :bold, align: :center
    move_down(2)
    e = make_table @rows,row_colors: ["F8F8F8", "FFFFFF"],:cell_style => {:padding => [1, 2, 2, 1],border_color:"E0E0E0"}, 
      :column_widths => [40, 24, 150,110,10,40,40,40,40], header:true do
      row(0).font_style = :bold
    end
    e.draw
  end

 def money(int)
   Vfwcash.money(int)
 end

end
