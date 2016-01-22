class Restaurant < ActiveRecord::Base
  belongs_to :user
  has_many :reviews,
      -> { extending WithUserAssociationExtension },
      dependent: :destroy
  validates :name, length: {minimum: 3}, uniqueness: true

  def owned_by?(user)
    user == self.user
  end

  has_many :reviews do
    def build_with_user(attributes = {}, user)
      attributes[:user] ||= user
      build(attributes)
    end
  end

  def build_review(attributes = {}, user)
    attributes[:user] ||= user
    reviews.build(attributes)
  end
end
