class AddQuestionRowColumnsQuestionRowColumnOptionsIdToQuestionRowColumnFields < ActiveRecord::Migration[5.0]
  def change
    add_reference :question_row_column_fields, :question_row_columns_question_row_column_option, foreign_key: true, index: { name: 'index_qrcf_on_qrcqrco_id' }
  end
end
