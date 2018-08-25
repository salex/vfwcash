
class CashAccount < SqliteBase
  self.table_name = "accounts"

  self.primary_key = 'guid'
  has_many :splits, foreign_key: 'account_guid'
  has_many :trans, through: :splits

  def parent
    CashAccount.find(self.parent_guid)
  end

  def children
    CashAccount.where(parent_guid:self.guid).order(:name)
  end

  def account_ledger
    acct_trans = self.trans.order(:post_date).distinct
    b = 0
    lines = []
    acct_trans.each do |t|
      date = Date.parse(t.post_date)
      line = {date: date.strftime("%m/%d/%Y"),num:t.num,desc:t.description,
        checking:{db:0,cr:0},details:[],balance:0, memo:nil,r:nil}
      t.splits.each do |s|
        details = s.details
        if details[:aguid] == self.guid
          line[:checking][:db] += details[:db]
          line[:checking][:cr] += details[:cr]
          b += (details[:db] - details[:cr])
          line[:balance] = b
          line[:r] = details[:r]
        else
          line[:balance] = b
          if line[:memo].nil?
            line[:memo] = details[:name]
          else
            line[:memo] = "- Split Transaction -"
          end
        end
        line[:details] << details
      end
      lines << line
    end
    lines
  end


  def balance(decimal=true)
    b = self.splits.sum(:value_num)
    if decimal
      "#{b/100}.#{b%100}"
    else
      b
    end
  end

  def balance_on(date)
    sp = self.splits.joins(:tran).where(Tran.arel_table[:post_date].lt(date.to_s(:db)))
    b = sp.sum(:value_num)
  end

  def balances_between(from,to)
    bb = self.balance_on(from)
    sp = splits_by_month(from,to)
    credits = sp.where('value_num < ?',0).sum(:value_num)
    debits = sp.where('value_num >= ?', 0).sum(:value_num)
    diff = debits + credits
    results = {bbalance:bb,diff:diff,debits:debits,credits:credits * -1,ebalance:bb+diff}
  end

  def splits_by_month(bom,eom)
    self.splits.joins(:tran).where(transactions:{post_date: Vfwcash.str_date_range(bom,eom)})
  end
  
  def children_balance(decimal=true)
    b = 0
    kids = self.children
    kids.each do |c|
      b += c.balance(false)
    end
    if decimal
      "#{b/100}.#{b%100}"
    else
      b
    end
  end

  def account_name
    account_name = self.name 
    p = self.parent
    while p.parent_guid.present?
      account_name = p.name + ":" + account_name
      p = p.parent
    end
    return account_name
  end

end
