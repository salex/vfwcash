class Split < ActiveRecord::Base
  self.primary_key = 'guid'
  belongs_to :tran, foreign_key: 'tx_guid'
  belongs_to :checking_account, foreign_key: 'account_guid'

  def amount
    return "#{self.value_num / self.value_denom}.#{self.value_num % self.value_denom}"
  end

  def details
    acct = self.checking_account
    fund = acct.name
    parent = acct.parent
    acct_name = parent.present? ? "#{parent.name}:#{acct.name}" : acct.name

    amt = self.value_num
    if amt.to_f < 0
      credit = amt * -1
      debit = 0
    else
      credit = 0
      debit = amt
    end
    return {fund:fund,name:acct_name,cr:credit,db:debit, memo:self.memo, r:self.reconcile_state}
  end
end
