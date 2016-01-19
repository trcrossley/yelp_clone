require 'rails_helper'

feature 'restaurants' do
  context 'while not signed in' do
    context 'creating restaurants' do
      scenario 'user cannot create a restaurant' do
        visit '/restaurants'
        click_link 'Add a restaurant'
        expect(current_path).to eq '/users/sign_in'
      end
    end

    context 'editing restaurants' do
      before { Restaurant.create name: 'KFC' }

      scenario 'user cannot edit a restaurant' do
        visit '/restaurants'
        click_link 'Edit KFC'
        expect(current_path).to eq '/users/sign_in'
      end
    end

    context 'deleting restaurants' do
      before { Restaurant.create name: 'KFC' }

      scenario 'user cannot delete a restaurant' do
        visit '/restaurants'
        click_link 'Delete KFC'
        expect(current_path).to eq '/users/sign_in'
      end
    end
  end

  context 'while user is logged in' do
    before do
      sign_up_for_account
    end

    context 'creating restaurants' do
      scenario 'prompts user to fill out a form then displays new restaurant' do
        manually_create_restaurant
        expect(page).to have_content 'KFC'
        expect(current_path).to eq '/restaurants'
      end

      context'an invalid restaurant' do
        scenario 'does not let you submit a name that is too short' do
          visit '/restaurants'
          click_link 'Add a restaurant'
          fill_in 'Name', with: 'kf'
          click_button 'Create Restaurant'
          expect(page).not_to have_css 'h2', text: 'kf'
          expect(page).to have_content 'error'
        end
      end
    end

    context 'editing restaurants' do
      context 'the restaurant was created by user' do
        before { manually_create_restaurant }

        scenario 'let a user edit a restaurant' do
          visit '/restaurants'
          click_link 'Edit KFC'
          fill_in 'Name', with: 'Kentucky Fried Chicken'
          click_button 'Update Restaurant'
          expect(page).to have_content 'Kentucky Fried Chicken'
          expect(current_path).to eq '/restaurants'
        end
      end

      context 'the restaurant was created by someone else' do
        before { Restaurant.create name: 'KFC' }

        scenario 'the user cannot edit restaurant' do
          visit '/restaurants'
          click_link 'Edit KFC'
          fill_in 'Name', with: 'Kentucky Fried Chicken'
          click_button 'Update Restaurant'
          expect(page).to have_content 'KFC'
          expect(current_path).to eq '/restaurants'
          expect(page).to have_content 'Only owners can edit'
        end
      end
    end

    context 'deleting restaurants' do
      context 'the restaurant was created by user' do
        before { manually_create_restaurant }

        scenario 'removes a restaurant when a user clicks a delete link' do
          visit '/restaurants'
          click_link 'Delete KFC'
          expect(page).not_to have_content 'KFC'
          expect(page).to have_content 'Restaurant successfully deleted'
        end
      end

      context 'the restaurant was created by someone else' do
        before { Restaurant.create name: 'KFC' }

        scenario 'raises and error when user tries to delete restaurant' do
          visit '/restaurants'
          click_link 'Delete KFC'
          expect(page).to have_content 'KFC'
          expect(page).to have_content 'Only owners can delete'
        end
      end
    end
  end

  context 'no restaurants have been added' do
    scenario 'should display a prompt to add a restaurant' do
      visit '/restaurants'
      expect(page).to have_content 'No restaurants yet'
      expect(page).to have_link 'Add a restaurant'
    end
  end

  context 'restaurants have been added' do
    before do
      Restaurant.create(name: 'KFC')
    end

    scenario 'display restaurants' do
      visit '/restaurants'
      expect(page).to have_content('KFC')
      expect(page).not_to have_content('No restaurants yet')
    end
  end

  context 'viewing restaurants' do
    let!(:kfc) { Restaurant.create(name: 'KFC') }

    scenario 'lets a user view a restaurant' do
      visit '/restaurants'
      click_link 'KFC'
      expect(page).to have_content 'KFC'
      expect(current_path).to eq "/restaurants/#{kfc.id}"
    end
  end
end
