require 'spec_helper'

describe Restaurant, type: :model do
  it { is_expected.to have_many :reviews }

  it 'is not valid with a name of less than three characters' do
    restaurant = Restaurant.new(name: "kf")
    expect(restaurant).to have(1).error_on(:name)
    expect(restaurant).not_to be_valid
  end

  it 'it not valid unless it has a unique name' do
    Restaurant.create(name: "Moe's Tavern")
    restaurant = Restaurant.new(name: "Moe's Tavern")
    expect(restaurant).to have(1).error_on(:name)
  end

  it { is_expected.to belong_to :user }

  describe '#owned_by?' do
    it 'should return true if owned by that user' do
      user = User.create(email:'test@test.com', password:'testtest', password_confirmation:'testtest')
      restaurant = Restaurant.create(name:'KFC', user:user)
      expect(restaurant.owned_by?(user)).to be true
    end

    it 'should return false if not owned by that user' do
      user = User.create(email:'test@test.com', password:'testtest', password_confirmation:'testtest')
      restaurant = Restaurant.create(name:'KFC')
      expect(restaurant.owned_by?(user)).to be false
    end
  end

  describe 'reviews' do
    describe 'build_with_user' do

      let(:user) { User.create email: 'test@test.com' }
      let(:restaurant) { Restaurant.create name: 'Test' }
      let(:review_params) { { rating: 5, thoughts: 'yum' } }

      subject(:review) { restaurant.reviews.build_with_user(review_params, user) }

      it 'builds a review' do
        expect(review).to be_a Review
      end

      it 'builds a review associated with the specified user' do
        expect(review.user).to eq user
      end
    end
  end
end
