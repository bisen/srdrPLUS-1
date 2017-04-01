class ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :edit, :update, :destroy]

  # GET /profile
  # GET /profile.json
  def show
  end

  # GET /profile/edit
  def edit
  end
  #
  # POST /profiles
  # POST /profiles.json
  def create
    @profile = current_user.build_profile
    respond_to do |format|
      if @profile.update(profile_params)
        format.html { redirect_to @profile, notice: 'Profile was successfully updated.' }
        format.json { render :show, status: :created, location: @profile }
      else
        format.html { render :new }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /profile
  # PATCH/PUT /profile.json
  def update
    respond_to do |format|
      if @profile.update(profile_params)
        format.html { redirect_to @profile, notice: 'Profile was successfully updated.' }
        format.json { render :show, status: :ok, location: @profile }
      else
        format.html { render :edit }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_profile
    # Every user should have a profile, build for a new user.
    @profile = current_user.profile
  end

  def profile_params
    # Never trust parameters from the scary internet, only allow the white list through.
    params.require(:profile).permit(:username, :first_name, :middle_name, :last_name,
                                    :organization_id, degree_ids: [])
  end
end
