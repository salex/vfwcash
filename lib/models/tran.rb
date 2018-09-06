class Tran < SqliteBase
	self.table_name = "transactions"
	self.primary_key = 'guid'

	has_many :splits, foreign_key: 'tx_guid'

  # attribute :date, :date
  # after_find do |t|
  #   if t.post_date.present?
  #     t.date = Date.parse(t.post_date)
  #   end
  # end


  # def self.month_transactions(date)
  #   month = Vfwcash.yyyymm(date)
  #   trans = Tran.where('transactions.post_date BETWEEN ? and ?',month+"00",month+"32").order(:post_date,:num)
  # end

  def self.month_transactions(date)
    bom = date.beginning_of_month.to_datetime.beginning_of_day.to_s(:db)
    eom = date.end_of_month.to_s(:db).to_datetime.end_of_day.to_s(:db)
    trans = Tran.where(post_date: bom..eom ).order(:post_date,:num)
  end


end
