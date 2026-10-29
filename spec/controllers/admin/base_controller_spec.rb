# frozen_string_literal: true

require 'spec_helper'

describe Admin::BaseController do
  controller(described_class) do
    def index
      head :ok
    end
  end

  context 'when signed in as admin' do
    stub_current_user role: :admin

    it 'allows access' do
      get :index
      expect(response).to have_http_status :ok
    end
  end

  context 'when signed in as organizer' do
    stub_current_user role: :organizer

    it 'allows access' do
      get :index
      expect(response).to have_http_status :ok
    end
  end

  context 'when signed in as reviewer' do
    stub_current_user role: :reviewer

    it 'renders forbidden page' do
      get :index
      expect(controller).to render 'admin/shared/forbidden', status: :forbidden
    end
  end

  context 'when signed out' do
    it 'redirects to sign in' do
      get :index
      expect(controller).to redirect_to sign_in_path
    end
  end
end
