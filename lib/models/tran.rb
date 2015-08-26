class Tran < ActiveRecord::Base
	self.table_name = "transactions"
	self.primary_key = 'guid'

	has_many :splits, foreign_key: 'tx_guid'

  def self.month_transactions(date)
    month = Vfwcash.yyyymm(date)
    trans = Tran.where('transactions.post_date BETWEEN ? and ?',month+"00",month+"32").order(:post_date,:num)
  end

end
