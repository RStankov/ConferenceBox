# frozen_string_literal: true

require 'spec_helper'

describe User do
  describe 'role' do
    it 'defaults to admin' do
      expect(described_class.new.role).to eq 'admin'
    end

    it 'rejects unknown roles' do
      user = build :user, role: 'janitor'
      expect(user).to have_error_on :role
    end
  end

  describe '#organizer_access?' do
    it 'is true for admins and organizers' do
      expect(build(:user, role: 'admin').organizer_access?).to be true
      expect(build(:user, role: 'organizer').organizer_access?).to be true
    end

    it 'is false for reviewers' do
      expect(build(:user, role: 'reviewer').organizer_access?).to be false
    end
  end

  describe '#full_name' do
    it 'joins first and last name' do
      expect(build(:user, first_name: 'Ada', last_name: 'Lovelace').full_name).to eq 'Ada Lovelace'
    end
  end
end
