class Question < ApplicationRecord
  include SharedOrderableMethods
  include SharedSuggestableMethods

  acts_as_paranoid
  has_paper_trail

  before_validation -> { set_ordering_scoped_by(:extraction_forms_projects_section_id) }

  belongs_to :extraction_forms_projects_section, inverse_of: :questions
  belongs_to :question_type, inverse_of: :questions

  has_one :ordering, as: :orderable, dependent: :destroy

  has_many :question_rows, dependent: :destroy, inverse_of: :question

  accepts_nested_attributes_for :question_rows

  delegate :extraction_forms_project, to: :extraction_forms_projects_section

  validates :ordering, presence: true
end