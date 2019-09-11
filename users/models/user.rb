class User
  USERS = [
    {
      id: 1,
      name: 'Bill Gates',
      email: 'bill.gates@example.com'
    },
    {
      id: 2,
      name: 'Steve Jobs',
      email: 'steve.jobs@example.com'
    }
  ]

  def self.all
    USERS
  end

  def self.find(id)
    USERS.find { |u| u[:id] == id.to_i }
  end
end
