class Extraction < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  #!!! We can't implement this without ensuring integrity of the extraction form. It is possible that the database
  #    is rendered inconsistent if a project lead changes links between type1 and type2 after this hook is called.
  #    We need something that ensures consistency when linking is changed.
  after_create :update_all

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

  ### Giant method to ensure existence of qrcf and eefps_qrcf for each question answer choice
  ### not private, because we need to call this from the "work" action of the controller 
  def update_all
    # loop over extraction forms (there should be only 1)
    self.project.extraction_forms_projects.each do |efp|
      # loop over its sections
      efp.extraction_forms_projects_sections.each do |efps|
        # find or create the join model between extraction and the section
        eefps = self.extractions_extraction_forms_projects_sections.find_or_create_by!(extraction_forms_projects_section: efps)
        
        # if there is a linked "arms" or "outcomes" section (Type1 in general), try to get the linked type1s
        type1s = efps.link_to_type1.nil? ? [ nil ] : 
            ExtractionsExtractionFormsProjectsSectionsType1
            .joins(:extractions_extraction_forms_projects_section)
            .where(extractions_extraction_forms_projects_sections:
                  { extraction: self,
                    extraction_forms_projects_section: efps.link_to_type1 }).all

        # we still want one eefps_qrcf even when there's no type1, so add nil
        type1s = type1s.empty? ? [ nil ] : type1s
        
        # delete previous eefps_qrcf if a type1 is deleted
        eefps.extractions_extraction_forms_projects_sections_question_row_column_fields.where.not(extractions_extraction_forms_projects_sections_type1: type1s).delete_all

        if not type1s.include?(nil)
          eefps.extractions_extraction_forms_projects_sections_question_row_column_fields.where(extractions_extraction_forms_projects_sections_type1_id: nil).delete_all
        end

        # for each question row column in the extraction form
        efps.questions.each do |q|
          q.question_rows.each do |qr|
            qr.question_row_columns.each do |qrc|
              # if the question has a multiple choice answer, we need to create one eefps_qrcf for each answer choice
              if [ 'checkbox', 'select2_multi' ].include? qrc.question_row_column_type.name
                qrc.question_row_columns_question_row_column_options.
                  where(question_row_column_option: QuestionRowColumnOption.where(name: 'answer_choice')).each do |qrcqrco|
                  # also make sure that we create one set of eefps_qrcf for each linked type1
                  type1s.each do |type1|
                    qrcf = QuestionRowColumnField.find_or_create_by(
                             question_row_column: qrc )

                    eefps_qrcf =
                      ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField
                      .find_or_create_by(
                        extractions_extraction_forms_projects_sections_type1: type1,
                        extractions_extraction_forms_projects_section: eefps,
                        question_row_column_field: qrcf )

                    # create the record that will hold the extraction data
                    record = Record.find_or_create_by(recordable: eefps_qrcf)
                  end
                end
              # else, just create one set
              else
                type1s.each do |type1|
                  eefps_qrcf =
                    ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.
                      find_or_create_by(
                      extractions_extraction_forms_projects_sections_type1: type1,
                      extractions_extraction_forms_projects_section: eefps,
                      question_row_column_field: qrc.question_row_column_fields.first )
                  record = Record.find_or_create_by(recordable: eefps_qrcf)
                end
              end
            end
          end
        end
      end
    end
  end

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
end
