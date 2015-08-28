
class CashAccount < ActiveRecord::Base
  self.table_name = "accounts"

  self.primary_key = 'guid'
  has_many :splits, foreign_key: 'account_guid'
  has_many :trans, through: :splits

  def parent
    CashAccount.find(self.parent_guid)
  end

  def children
    CashAccount.where(parent_guid:self.guid)
  end

  def balance(decimal=true)
    b = self.splits.sum(:value_num)
    if decimal
      "#{b/100}.#{b%100}"
    else
      b
    end
  end

  def balances(first=nil,last=nil)
    if first.nil?
      trange = Vfwcash.transaction_range
      first = trange.first
      last = trange.last
    end
    curr = first
    b = 0
    results = {}
    while curr <= last
      month = Vfwcash.yyyymm(curr)
      bom = month + "00"
      eom = month + "32"
      sp = splits_by_month(bom,eom)
      credits = sp.where('value_num < ?',0).sum(:value_num)
      debits = sp.where('value_num >= ?', 0).sum(:value_num)
      diff = debits + credits
      results[month] = {bbalance:b,diff:diff,debits:debits,credits:credits * -1,ebalance:b+diff}
      b += diff
      curr += 1.month
    end
    return results
  end

  def splits_by_month(bom,eom)
    self.splits.joins(:tran).where('transactions.post_date between ? and ?',bom,eom)
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
