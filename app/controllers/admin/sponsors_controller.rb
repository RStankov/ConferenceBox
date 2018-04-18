# frozen_string_literal: true

class Admin::SponsorsController < Admin::BaseController
  def index
    @sponsors = Sponsor.all
  end

  def new
    @sponsor = Sponsor.new
  end

  def create
    @sponsor = Sponsor.create sponsor_params
    respond_with @sponsor, location: admin_sponsors_path
  end

  def show
    @sponsor = Sponsor.find sponsor_id
    redirect_to edit_admin_sponsor_path(@sponsor)
  end

  def edit
    @sponsor = Sponsor.find sponsor_id
  end

  def update
    @sponsor = Sponsor.update sponsor_id, sponsor_params
    respond_with @sponsor, location: admin_sponsors_path
  end

  def destroy
    @sponsor = Sponsor.destroy sponsor_id
    respond_with @sponsor, location: admin_sponsors_path
  end

  private

  def sponsor_id
    params[:id]
  end

  def sponsor_params
    params.require(:record).permit(
      :name,
      :website_url,
      :logo,
    )
  end
end
