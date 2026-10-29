# frozen_string_literal: true

class Admin::BaseController < ActionController::Base
  include SetupController
  include CurrentUserMethods
  include ActiveStorage::SetCurrent

  layout 'admin'

  before_action :require_organizer_access

  private

  def require_organizer_access
    forbidden unless current_user.organizer_access?
  end

  def require_admin_access
    forbidden unless current_user.admin?
  end

  def forbidden
    render 'admin/shared/forbidden', status: :forbidden
  end

  def accessible_proposals
    if current_user.organizer_access?
      Cfp::Proposal.all
    else
      Cfp::Proposal
        .joins(:review_assignments)
        .where(cfp_review_assignments: { reviewer_id: current_user.id, conflict_of_interest: false })
    end
  end
end
