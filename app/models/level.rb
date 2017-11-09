class Level < ApplicationRecord
  has_many :users
  after_update :change_user_level

  def self.seed
    levels = [{nu: 1, des: '等级1'}, {nu: 2, des: '等级2'}, { nu: 3, des: '等级3'}, { nu: 4, des: '等级4'} ]
    levels.each do |l|
      Level.create(number: l[:nu], descripte: l[:des])
    end
  end

  def change_user_level
    if price_changed?
      levels = Level.where("number < ?", self.number)
      levels.each do |level|
        level.users.find_each(batch_size: 500) do |user|
          total_spend = user.total_spend || 0
          user.update_attribute(:level_id, id) if total_spend >= price
        end
      end
    end
  end
end
