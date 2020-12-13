class Api::V2::ProjectsController < Api::V2::BaseController
  before_action :set_project, only: [:show, :update, :destroy]

  #before_action :skip_authorization, only: [:index, :show, :create]
  #before_action :skip_policy_scope

  SORT = {  'updated-at': { updated_at: :desc },
            'created-at': { created_at: :desc }
  }.stringify_keys

  resource_description do
    short 'End-points describing SRDR+ Projects.'
    formats [:json]
  end

  def_param_group :project do
    param :project, Hash, required: true, action_aware: true do
      property :id,             Integer, 'Resource ID.'
      param :name,              String, 'Name of the project'
      param :description,       String, 'Long description of project'
      param :attribution,       String, 'Project attribution'
      param :methodology,       String, 'Methodology description'
      param :prospero,          String, 'Prospero ID'
      param :doi,               String, 'Document Object Identifier'
      param :notes,             String, 'Project notes'
      param :funding_source,    String, 'Who funds this project'
      property :deleted_at,     DateTime
      property :created_at,     DateTime
      property :updated_at,     DateTime
      param :authors_of_report, String, 'Authors of Report'
      property :url,            String
      property :is_public,      :boolean
    end
  end

  def_param_group :user do
    property :id, Integer, desc: 'Resource ID.'
    property :email, String
    property :username, String
    property :first_name, String
    property :middle_name, String
    property :last_name, String
    property :roles, Array, array_of: String
  end

  api :GET, '/v2/projects.json', 'List of projects. Requires API Key.'
  param_group :paginate, Api::V2::BaseController
  returns desc: 'Returns array of Hash. Each Hash contains project information.' do
    property :projects, Array do
      param_group :project
    end
  end
  def index
    @projects = current_user.projects
      .includes(:extraction_forms)
      .includes(:key_questions)
      .includes(publishing: [{ user: :profile }, approval: [{ user: :profile }]])
  end

  api :GET, '/v2/projects/:id.json', 'Display complete project meta data. Requires API Key.'
  param_group :resource_id, Api::V2::BaseController
  returns desc: 'Detailed description of SRDR+ Project.' do
    param_group :project
    property :key_questions, Hash do
      param_group :key_question, Api::V2::KeyQuestionsController
    end
    property :members, Hash do
      param_group :user
    end
    property :extraction_template, Hash do
      property :sections, Hash do
        property :id, Integer, desc: 'Resource ID.'
        property :name, String
        property :type, String
        property :hidden, :boolean
        property :created_at, DateTime
        property :updated_at, DateTime
        property :url, String
        property :questions, Hash do
          param_group :question, Api::V2::QuestionsController
        end
      end
    end
    property :extractions_meta_data, Hash do
      param_group :extraction, Api::V2::ExtractionsController
    end
  end
  def show
    authorize(@project, policy_class: ProjectPolicy)
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
