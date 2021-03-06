# frozen_string_literal: true

require 'spec_helper'

module Sign
  describe Login do
    let(:user) { create :user }

    describe 'ActiveModel' do
      include ActiveModel::Lint::Tests

      ActiveModel::Lint::Tests.public_instance_methods.map(&:to_s).grep(/^test/).each do |m|
        example m.tr('_', ' ') do
          send m
        end
      end

      def model
        subject
      end
    end

    describe 'validation' do
      it 'requires a email' do
        expect(described_class.new).to have_error_on(:email)
      end

      it 'requires a password' do
        expect(described_class.new).to have_error_on(:password)
      end

      it 'doesnt accept correct email with wrong password' do
        login = described_class.new email: user.email, password: '-wrong-password-'
        expect(login).to have_error_on(:email)
      end

      it 'doesnt accept wrong email with correct password' do
        login = described_class.new email: 'invalid-email@example.org', password: user.password
        expect(login).to have_error_on(:email)
      end

      it 'requires correct email and password' do
        login = described_class.new email: user.email, password: user.password
        expect(login).to be_valid
      end
    end

    describe '#user_id' do
      it 'returns user if for given email and password' do
        login = described_class.new email: user.email, password: user.password
        expect(login.user_id).to eq user.id
      end

      it 'returns nil if login is not valid' do
        login = described_class.new email: user.email, password: user.password
        allow(login).to receive(:valid?).and_return false
        expect(login.user_id).to be_blank
      end
    end
  end
end
