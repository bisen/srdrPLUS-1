class ExtractionFormsProjectsSection < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :extraction_forms_project, inverse_of: :extraction_forms_projects_sections
  belongs_to :section, inverse_of: :extraction_forms_projects_sections

  has_many :extraction_forms_projects_sections_questions, dependent: :destroy, inverse_of: :extraction_forms_projects_section
  has_many :questions, through: :extraction_forms_projects_sections_questions, dependent: :destroy

  accepts_nested_attributes_for :section, reject_if: :section_name_exists?

  private

  def section_name_exists?(attributes)
    begin
      self.section = Section.where(name: attributes[:name]).first_or_create!
    rescue ActiveRecord::RecordNotUnique
      retry
    end
#    if _section = Section.find_by(name: attributes[:name])
#      # Associate this ExtractionFormsProject with the existing ExtractionForm.
#      self.section = _section
#      return true
#    else
#      return false
#    end
  end
end
