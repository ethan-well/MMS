class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  validates :email, uniqueness: true
  validates :name, presence: true, uniqueness: true
  has_many :orders
  has_many :special_prices
  belongs_to :level, required: false

  after_create :generate_invitation_code

  def serializable_hash(options = nil)
    super(options).merge(encrypted_password: encrypted_password, confirmed_at: confirmed_at, unconfirmed_email: unconfirmed_email)
  end

  def total_spend
    orders.where('status = ?', 'Finished').map(&:total_price).reduce(:+)
  end

  def generate_invitation_code
    invitation_code = AESCrypt.encrypt(email, encrypted_password)
    self.update_attribute(:invitation_code, invitation_code[0..6] + id.to_s)
  end

  def current_goods_special_prices(goods_id)
    self.special_prices.find_by_goods_id(goods_id).price rescue nil
  end

  def invitation_code_in_word
    level_id > 1 ? invitation_code : '未开放'
  end

  def active_in_word
    active ? '可登录' : '不可登录'
  end

  def my_price(good_id)
    @good = Goods.find(good_id)
    current_goods_special_prices(good_id) || @good.get_current_price(self.level_id)
  end

  def month_ago_spend
    orders.where('status = ?', 'Finished').where('created_at BETWEEN ? AND ?', Date.today - 1.month, Date.today).map(&:total_price).reduce(:+)
  end

  def low_level_users
    User.where('h_invitation_code = ?', self.invitation_code).count
  end

  def today_spend
    orders.where('status = ?', 'Finished').where('created_at BETWEEN ? AND ?', DateTime.now.beginning_of_day, DateTime.now).map(&:total_price).reduce(:+)
  end

  def can_invite_in_word
    can_invite ? '是' : '否'
  end

  def h_user
    User.find_by_invitation_code(self.h_invitation_code) rescue nil
  end
end
