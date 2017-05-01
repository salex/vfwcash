class ProfitLoss

  attr_accessor :from, :to, :flipper, :report

  def generate(from,to)
    @from = Vfwcash.set_date(from)
    @to = Vfwcash.set_date(to)
    i = CashAccount.find_by(name:'Income')
    e = CashAccount.find_by(name:'Expenses')
    @report = {"Income" => {amount:period_splits(i),total:0,children:{}}, "Expense" =>  {amount:period_splits(e),total:0,children:{}}}
    tree(i,report['Income'])
    tree(e,report['Expense'])
    return self
  end

  def tree(branch,hash)
    branch.children.each do |c|
      hash[:children][c.name] = {amount:period_splits(c),total:0,children: {}}
      tree(c,hash[:children][c.name])
      hash[:total] += (hash[:children][c.name][:amount] + hash[:children][c.name][:total])
    end
  end

  def period_splits(acct)
    flipper = acct.account_type == 'INCOME' ? -1 : 1
    sp = acct.splits.joins(:tran).where('transactions.post_date between ? and ?',from.strftime('%Y%m%d')+'00',to.strftime('%Y%m%d')+'24')
    sp.sum(:value_num) * flipper
  end

end
