class Question < ApplicationRecord
  include SharedOrderableMethods
  include SharedSuggestableMethods

  acts_as_paranoid
  has_paper_trail

  after_create :create_default_question_rows

#  after_save :ensure_matrix_column_headers

  before_validation -> { set_ordering_scoped_by(:extraction_forms_projects_section_id) }, on: :create

  belongs_to :extraction_forms_projects_section, inverse_of: :questions

  has_one :ordering, as: :orderable, dependent: :destroy

  has_many :question_rows, dependent: :destroy, inverse_of: :question

  accepts_nested_attributes_for :question_rows

  delegate :extraction_forms_project, to: :extraction_forms_projects_section
  delegate :section, to: :extraction_forms_projects_section

  validates :ordering, presence: true

  # Returns the question type based on how many how many rows/columns/answer choices the question has.
  def question_type
    if self.question_rows.length == 1
      if self.question_rows.first.question_row_columns.length == 1
        if self.question_rows.first.question_row_columns.first.question_row_column_field.question_row_column_field_type == 4
          return 'Text'
        else
          return 'Custom'
        end
      else
        return 'Custom'
      end
    else
      return 'matrix'
    end
  end

  private

    def create_default_question_rows
      self.question_rows.create
    end

#    def create_default_question_rows
#      if %w(Text Checkbox Dropdown Radio).include? self.question_type.name
#
#        self.question_rows.create
#
#      elsif %w(Matrix\ Text Matrix\ Checkbox Matrix\ Dropdown Matrix\ Radio).include? self.question_type.name
#
#        self.question_rows.create
#        self.question_rows.create
#
#      else
#
#        raise 'Unknown QuestionType'
#
#      end
#    end
#
#    #!!! May need to rethink this.
#    def ensure_matrix_column_headers
#      if self.question_type.name.include? 'Matrix'
#
#        first_row = self.question_rows.first
#        rest_rows = self.question_rows[1..-1]
#
#        column_headers = []
#
#        first_row.question_row_columns.each do |c|
#          column_headers << c.name
#        end
#
#        rest_rows.each do |r|
#          r.question_row_columns.each_with_index do |rc, idx|
#            rc.update(name: column_headers[idx])
#          end
#        end
#
#      end
#    end
end
