# frozen_string_literal: true

require 'spec_helper'

feature 'Conference' do
  context 'when normal conference' do
    let(:conference) { create :conference, domain: 'example.com' }

    describe 'Archive' do
      it 'isnt displayed when they arent other event of current conference' do
        create :event, conference: conference

        visit root_path

        expect(page).not_to have_content 'Архив'
      end

      it 'is displayed when they arent at least two events current conference' do
        2.times { create :event, conference: conference }

        visit root_path

        expect(page).to have_content 'Архив'
      end
    end
  end
end
