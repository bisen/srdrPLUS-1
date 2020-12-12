class Api::V2::ProjectsController < Api::V2::BaseController
  before_action :set_project, only: [:show, :update, :destroy]

  #before_action :skip_authorization, only: [:index, :show, :create]
  #before_action :skip_policy_scope

  SORT = {  'updated-at': { updated_at: :desc },
            'created-at': { created_at: :desc }
  }.stringify_keys

  resource_description do
    short 'Projects'
    formats [:json]
    deprecated false
  end

  def_param_group :project do
    param :project, Hash, required: true, action_aware: true do
      param :name,              String, 'Name of the project'
      param :funding_source,    String, 'Who funds this project'
      param :prospero,          String, 'Prospero ID'
      param :doi,               String, 'Document Object Identifier'
      param :description,       String, 'Long description of project'
      param :attribution,       String, 'Project attribution'
      param :authors_of_report, String, 'Authors of Report'
      param :methodology,       String, 'Methodology description'
      param :notes,             String, 'Project notes'
    end
  end

  api :GET, '/v2/projects.json', 'List of projects. Requires API Key.'
  def index
    @projects = current_user.projects
      .includes(:extraction_forms)
      .includes(:key_questions)
      .includes(publishing: [{ user: :profile }, approval: [{ user: :profile }]])
  end

  api :GET, '/v2/projects/:id.json', 'Display complete project meta data. Requires API Key.'
  def show
    authorize(@project)
    #respond_with @project
  end

  api :POST, '/v2/projects', 'Create new project. Requires API Key.'
  param_group :project
  formats []
  def create
    @project = Project.new(project_params)
    flash[:notice] = 'Project was successfully created.' if @project.save
    respond_with @project
  end

  api :POST, '/v2/projects/:id', 'Update project information. Requires API Key.'
  param_group :project
  formats []
  def update
    authorize(@project, policy_class: ProjectPolicy)

    @project.update(project_params)
    flash[:notice] = 'Project was successfully updated.' if @project.save
    respond_with @project
  end

  private

    def set_project
      @project = Project.find(params[:id])
    end

    def project_params
      if action_name != 'create'
        params.require(:project).permit(policy(@project).permitted_attributes)
      else
        params.require(:project).permit(*ProjectPolicy::FULL_PARAMS)
      end
    end
end
