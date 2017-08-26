class Level < ApplicationRecord
  has_many :users

  def self.seed
    levels = [{nu: 1, des: '等级1'}, {nu: 2, des: '等级2'}, { nu: 3, des: '等级3'}, { nu: 4, des: '等级4'} ]
    levels.each do |l|
      Level.create(number: l[:nu], descripte: l[:des])
    end
  end
end
