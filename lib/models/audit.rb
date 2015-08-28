module Pdf
class Audit < Prawn::Document
  attr_accessor :cur, :config, :balances
  def initialize(date,cash)
    super( top_margin: 35)
    @date = Vfwcash.set_date(date).beginning_of_month
    @layout = {top:bounds.height.to_i,right:bounds.width.to_i,left:0,bottom:0,cursor:cursor}
    @config = cash.config
    cash.get_balances
    @balances = cash.audit_api(@date)
    make_pdf
  end

  def make_pdf
    @cur = @layout[:top]
    font_size 9
    # get_config
    header
    report
    funds
    operations
    reconcile
    certify
    verify
    quartermaster
    trustees
    bonding
    commander
    number_pages "VFW Post 8600 Form -   Page <page> of <total>", { :start_count_at => 0, :page_filter => :all, :at => [bounds.right - 100, 0], :align => :right, :size => 6 }
  end


  def header
    bounding_box([0,@cur], width: 80, height:80) do
      image "#{Dir.pwd}/config/vfw-gray.png",height:50
    end

    bounding_box([0, @cur], :width => @layout[:right], :height => 30) do
      draw_text "TRUSTEES' REPORT OF AUDIT of", at:[100,15], style: :bold, size:12
    end
    @cur -= 32
  end

  def report
    bounding_box([70, @cur], :width => @layout[:right] - 70, :height => 50) do
      text_box "The Books and Records of the Quartermaster and Adjutant of:     <strong><u>#{@config[:post][:name]}  -  #{@config[:post][:post]}</u></strong>", at:[30,50], inline_format:true
      text_box "Department of <strong><u> #{@config[:post][:department]} </u></strong> for Fiscal Quarter ending:     <strong><u>#{@balances[:dates][:eoq]}</u></strong>", at:[30,35], inline_format:true
      text_box "Fiscal Quarter    <strong><u>#{@balances[:dates][:boq]} to #{@balances[:dates][:eoq]}</u></strong>", at:[30,20], inline_format:true

    end
    @cur -= 52

  end

  def funds
    bounding_box([0, @cur], :width => @layout[:right], :height => 180) do
      rows = []
      h = [ "FUNDS",
        "10.  Net Cash Balances at Beginning of Quarter",
        "11.  Receipts During Quarter",
        "12.  Expenditures During Quarter",
        "13.  Net Cash Balances at End of Quarter"]
        rows << h
      # 1.upto(8) do |i|
      #   rows << [i.to_s+'.',"begin","debits","credits","end"]
      # end
      # 3.times{rows << [' ',nil,nil,nil,nil]}
      # rows << ["9.","begin","debits","credits","end"]
      # rows << [{content:"Total",align: :right},"begin","debits","credits","end"]
      bb = @eb = cr = db = 0
      @config[:funds].each do |f,v|
        bal = @balances[v[:fund]]
        if bal.present?
          bb += bal[:bbalance]
          @eb += bal[:ebalance]
          db += bal[:debits]
          cr += bal[:credits]
          rows << [v[:text], money(bal[:bbalance]),money(bal[:debits]),money(bal[:credits]),money(bal[:ebalance])]
        end
      end
      rows << [' ',nil,nil,nil,nil]
      rows << ['10.  Total',money(bb),money(db),money(cr),"(15)    " + money(@eb)]
      font_size 8
      e = make_table rows,:cell_style => {:padding => [1, 2, 2, 1] ,border_color:"000000"},
        :column_widths => [268, 68,68,68,68] do
          row(0).column(0).font_style = :bold
          row(0).column(0).size = 10
          row(0).column(1..4).size = 5
          row(0).column(1..4).font_style = :bold
          row(-1).font_style = :bold
          column(1..4).align = :right
          row(-1).align = :right



        end
      e.draw

    end
    @cur -= 182

  end

  def operations
    bounding_box([0, @cur], :width => @layout[:right]/2, :height => 180) do
      stroke_bounds
      move_down 5
      text "16.   OPERATIONS", size:10, style: :bold
      stroke_horizontal_rule
      rows = []
      @config[:operations].each do |k,v|
        rows << [v[:ques], (v[:answ].is_a?(Numeric) ? money(v[:answ]) : v[:answ])]
      end
      move_down(2)
        indent 3,3 do
        e = make_table rows,row_colors: ["F8F8F8", "FFFFFF"],:cell_style => {:padding => [3, 2, 2, 3] ,border_color:"FFFFFF",
          border_widths: [0,0,0,0]},
          :column_widths => [190, 60] do
            column(1).align = :right
          end
        e.draw
      end
    end
  end

  def reconcile
    bounding_box([@layout[:right]/2, @cur], :width => @layout[:right]/2, :height => 140) do
      stroke_bounds
      move_down 5
      text "17.   RECONCILIATION OF FUND BALANCES", size:10, style: :bold
      stroke_horizontal_rule
      move_down(2)

      rows = []
      rows << ['Checking Account Balance',{content:money(@config[:checking][:balance]),align: :right},nil]
      rows << ['Less Outstand Checks',{content:money(@config[:checking][:outstanding]), align: :right},nil]
      ab = @config[:checking][:balance] - @config[:checking][:outstanding]
      save = 0
      cash = 100000
      t1 = ab+save+cash
      bond = @balances['Savings'][:ebalance]
      t2 = t1 + bond
      rows << [{content:'Actual Balance', align: :right, colspan: 2},{content:money(ab),align: :right}]
      rows << [{content:'Savings Account Balance', align: :right, colspan: 2},{content:money(0),align: :right}]
      rows << [{content:'Cash on Hand', align: :right, colspan: 2},{content:money(cash),align: :right}]
      rows << [{content:'Total', align: :right, colspan: 2},{content:money(t1),align: :right}]
      rows << [{content:'Bonds and Investments (cost value)', align: :right, colspan: 2},{content:money(bond),align: :right}]
      rows << [{content:'Total', align: :right, colspan: 2},{content:money(t2),align: :right, text_color: (t2 != @eb ? 'FF0000' : '000000')}]
      indent 2,2 do
        e = make_table rows,row_colors: ["F8F8F8", "FFFFFF"],:cell_style => {:padding => [3, 2, 2, 3] ,border_color:"FFFFFF",
          border_widths: [0,0,0,0]},
          :column_widths => [120, 60, 60] do
            row(-1).font_style = :bold
          end
        e.draw
      end
    end
    @cur -= 140
  end

  def certify
    bounding_box([@layout[:right]/2, @cur], :width => @layout[:right]/2, :height => 40) do
      draw_text "18.", at:[5,30]
      draw_text "TRUSTEEs' and COMMANDER's", at:[40,30], style: :bold, size:10
      draw_text "CERTIFICATE OF AUDIT", at:[55,20], style: :bold, size:10
      move_down 30
      text "<strong>Date: <u> #{@config[:date]} </u></strong>", inline_format:true, indent_paragraphs:35
    end
    @cur -= 46

  end

  def verify
    bounding_box([0, @cur], :width => @layout[:right], :height => 60) do
      move_down 5
      text "#{Prawn::Text::NBSP * 5}This is to certify that we (or qualified accountants) have audited the books and records of the Adjutant & Quartermaster of"+
      " \n<strong><u> #{@config[:post][:post]} </u></strong> (District/County Council/Post No.)"+
      " For the Fiscal Quarter ending <strong><u> #{@balances[:dates][:eoq]} </u></strong> in accordance of the National By-Laws and this Report"+
      " is a true and correct statement thereof to the best of our knowledge and belief. All Vouchers and checks have been examined"+
      " and found to be properly approved and checks properly signed.", inline_format:true
    end
    @cur -= 62

  end

  def quartermaster
    bounding_box([0, @cur], :width => @layout[:right]/2, :height => 80) do
      draw_text "Post Quartermaster:", at:[5,65], style: :bold
      draw_text "Name and Address", at:[120,65], size: 6
      draw_text @config[:qm][:name], at:[120,50]

      draw_text @config[:qm][:address], at:[120,35]
      draw_text @config[:qm][:city], at:[120,25]

      
    end

  end

  def  trustees
    bounding_box([@layout[:right]/2, @cur], :width => @layout[:right]/2, :height => 80) do 
      move_down 14
      text "Signed _____________________________________ Trustee"
      move_down 14

      text "Signed _____________________________________ Trustee"
      move_down 14

      text "Signed _____________________________________ Trustee"
    end
    @cur -= 82

  end

  def bonding
    bounding_box([0, @cur], :width => @layout[:right], :height => 50) do
      move_down 10
      text "#{Prawn::Text::NBSP * 5}This is to certify that the Office of the Quartermaster is Bonded with"+
      " <strong><u> #{@config[:bond][:name]} </u></strong> "+
      "in the amount of <strong><u> #{'$'+money(@config[:bond][:amount])} </u></strong> until <strong><u> #{@config[:bond][:to]} </u></strong>, "+
      "and that this Audit is correctly made out to the best of my knowledge and belief.", inline_format:true
    end
    @cur -= 52

  end

  def commander
    bounding_box([@layout[:right]/2, @cur], :width => @layout[:right]/2, :height => 30) do
      move_down 20
      text "Signed _____________________________________ Commander"
    end

  end

  def money(int)
    Vfwcash.money(int)
  end


end
end