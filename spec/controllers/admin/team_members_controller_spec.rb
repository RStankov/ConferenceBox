# frozen_string_literal: true

require 'spec_helper'

describe Admin::TeamMembersController do
  let(:user) { instance_double User, to_param: '2' }

  context 'when signed in as admin' do
    stub_current_user role: :admin

    describe 'GET index' do
      it 'assigns all users' do
        allow(User).to receive(:all).and_return [user]
        get :index
        expect(assigns[:users]).to eq [user]
      end
    end

    describe 'GET edit' do
      it 'assigns the user' do
        allow(User).to receive(:find).with('2').and_return user
        get :edit, params: { id: '2' }
        expect(assigns[:user]).to eq user
      end
    end

    describe 'PATCH update' do
      before do
        allow(User).to receive(:find).with('2').and_return user
        allow(user).to receive(:update).and_return true
      end

      it 'changes the role' do
        patch :update, params: { id: '2', user: { role: 'reviewer' } }
        expect(user).to have_received(:update).with(role: 'reviewer')
        expect(controller).to respond_with user, location: admin_team_members_path
      end

      it 'refuses to change the current user role' do
        allow(User).to receive(:find).with('2').and_return current_user
        patch :update, params: { id: '2', user: { role: 'reviewer' } }
        expect(controller).to redirect_to admin_team_members_path
        expect(flash[:alert]).to eq 'You cannot change your own role'
      end
    end
  end

  context 'when signed in as organizer' do
    stub_current_user role: :organizer

    it 'is forbidden' do
      get :index
      expect(controller).to render 'admin/shared/forbidden', status: :forbidden
    end
  end
end
