class Extraction < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  #!!! We can't implement this without ensuring integrity of the extraction form. It is possible that the database
  #    is rendered inconsistent if a project lead changes links between type1 and type2 after this hook is called.
  #    We need something that ensures consistency when linking is changed.
  #after_create :create_extractions_extraction_forms_projects_sections

  scope :by_project_and_user, -> ( project_id, user_id ) {
    joins(projects_users_role: { projects_user: :user })
    .where(project_id: project_id)
    .where(projects_users: { user_id: user_id })
  }

  belongs_to :project,             inverse_of: :extractions
  belongs_to :citations_project,   inverse_of: :extractions
  belongs_to :projects_users_role, inverse_of: :extractions

  has_many :extractions_extraction_forms_projects_sections, dependent: :destroy, inverse_of: :extraction
  has_many :extraction_forms_projects_sections, through: :extractions_extraction_forms_projects_sections, dependent: :destroy

  has_many :extractions_projects_users_roles, dependent: :destroy, inverse_of: :extraction

#  def to_builder
#    Jbuilder.new do |extraction|
#      extraction.sections extractions_extraction_forms_projects_sections.map { |eefps| eefps.to_builder.attributes! }
#    end
#  end

  private

    # This may create issues if type1 to type2 links are created or broken after an extraction is created.
    def create_extractions_extraction_forms_projects_sections
      # Iterate over each efp (atm there should only ever be one).
      self.project.extraction_forms_projects.each do |efp|

        # Find every extraction_forms_projects_section which is part of the efp.
        efp.extraction_forms_projects_sections.includes(:extraction_forms_projects_section_type, :section, :type1s).each do |efps|

          # Create the ExtractionsExtractionFormsProjectsSection making sure we
          # check for the existence of links between type1 and type2 sections.
          eefps = ExtractionsExtractionFormsProjectsSection.includes(extraction_forms_projects_section: :section).find_or_create_by(
            extraction: @extraction,
            extraction_forms_projects_section: efps,
            link_to_type1: efps.link_to_type1.nil? ? nil : ExtractionsExtractionFormsProjectsSection.find_by(
              extraction: @extraction, extraction_forms_projects_section: efps.link_to_type1))
        end
      end
    end
  def update_all
    self.project.extraction_forms_projects.each do |efp|
      efp.extraction_forms_projects_sections.each do |efps|
        efps.questions.each do |q|
          q.question_rows.each do |qr|
            qr.question_row_columns.each do |qrc|
              arms = [ nil ]
              eefps = self.extractions_extraction_forms_projects_sections.find_by(extraction_forms_projects_section: efps)
              eefps = ExtractionsExtractionFormsProjectsSection.where(
                { extraction: self, extraction_forms_projects_section: efps } ).first
              if efps.link_to_type1 != nil
                arms = ExtractionsExtractionFormsProjectsSectionsType1
                  .joins(:extractions_extraction_forms_projects_section)
                  .where(extractions_extraction_forms_projects_sections:
                        { extraction: self,
                          extraction_forms_projects_section: efps.link_to_type1 }
                       ).all
              end
              if [ 5, 9 ].include? qrc.question_row_column_type_id
                qrc.question_row_columns_question_row_column_options.
                  where(question_row_column_option_id: 1).each do |qrcqrco|
                  arms.each do |arm|
                    qrcf = QuestionRowColumnField.find_or_create_by(
                             question_row_column: qrc,
                             question_row_columns_question_row_column_option: qrcqrco )

                    eefps_qrcf =
                      ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField
                      .find_or_create_by(
                        extractions_extraction_forms_projects_sections_type1: arm,
                        extractions_extraction_forms_projects_section: eefps,
                        question_row_column_field: qrcf )
                    record = Record.find_or_create_by(recordable: eefps_qrcf)

                  end
                end
              else
                arms.each do |arm|
                   eefps_qrcf =
                    ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.
                      find_or_create_by(
                      extractions_extraction_forms_projects_sections_type1: arm,
                      extractions_extraction_forms_projects_section: eefps,
                      question_row_column_field: qrc.question_row_columns_fields.first )
                    record = Record.find_or_create_by(recordable: eefps_qrcf)
                end
              end
            end
          end
        end
      end
    end
  end
end
