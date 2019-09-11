class Account
  ACCOUNTS = [
    {
      id: 1,
      user_id: 1,
      value: 200_000_000
    },
    {
      id: 2,
      user_id: 2,
      value: 100_000_000
    }
  ]

  def self.all
    ACCOUNTS
  end

  def self.find(id)
    ACCOUNTS.find { |u| u[:id] == id.to_i }
  end

  def self.find_by_user_id(user_id)
    ACCOUNTS.find { |u| u[:user_id] == user_id.to_i }
  end
end
