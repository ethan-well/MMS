class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  validates :email, uniqueness: true

  has_many :orders
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

  def invitation_code_in_word
    level_id > 1 ? invitation_code : '等级不够暂时不能邀请他人'
  end
end
