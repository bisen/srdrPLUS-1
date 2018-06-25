require 'test_helper'

class ExtractionTest < ActiveSupport::TestCase
  def setup
    @new_extraction = projects(:one).extractions.create!(
        projects_users_role: projects_users_roles(:one),
        citations_project: citations_projects(:one))
  end

  test 'eefps records should be created for each section' do
    ### There should be 5 eefps, one for each efp.
    assert_equal(@new_extraction.extractions_extraction_forms_projects_sections.size, 5, "extractions_extraction_forms_projects_sections are not created with the extraction")
  end

  test 'eefps_qrcf records should be created for each answer choice' do
    ### There should be 3 eefps_qrcf created:
    # 1 for QuestionOne: 1 answer_choice
    # 2 for QuestionTwo: 2 answer_choices
    # other eefps_qrcf should be deleted

    qrcf_arr = []

    @new_extraction.extractions_extraction_forms_projects_sections.each do |eefps|
      qrcf_arr = qrcf_arr +  eefps.question_row_column_fields
    end

    byebug
    assert_equal(qrcf_arr.size, 3, "eefps_qrcf are not created with the extraction")
  end

  test 'make sure that adding linking to a type1 section adds additional eefps_qrcf records' do
    ### There should be 5 eefps_qrcf in the end:
    # 1 for QuestionOne: 1 answer_choice
    # 4 for QuestionTwo: 2 answer_choices * 2 type1s
    # other eefps_qrcf should be deleted

    ExtractionsExtractionFormsProjectsSectionsType1.create!(
      type1: type_1s(:one),
      extractions_extraction_forms_projects_section:
        @new_extraction.extractions_extraction_forms_projects_sections.
        where(extraction_forms_projects_section: extraction_forms_projects_sections(:one)).first)
    ExtractionsExtractionFormsProjectsSectionsType1.create!(
      type1: type_1s(:two),
      extractions_extraction_forms_projects_section:
        @new_extraction.extractions_extraction_forms_projects_sections.
        where(extraction_forms_projects_section: extraction_forms_projects_sections(:one)).first)

    @new_extraction.update_all

    qrcf_arr = []

    @new_extraction.extractions_extraction_forms_projects_sections.each do |eefps|
      qrcf_arr = qrcf_arr +  eefps.question_row_column_fields
    end

    assert_equal(qrcf_arr.size, 5, "eefps_qrcf are not created for each linked type1")
  end
end
