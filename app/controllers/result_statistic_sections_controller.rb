class ResultStatisticSectionsController < ApplicationController
  before_action :set_result_statistic_section, only: [:edit, :update, :add_comparison, :consolidate]
  before_action :set_arms, only: [:edit, :update, :consolidate]
  before_action :set_extractions, only: [:consolidate]
  #!!! Birol: don't think this is working...where is comparables set?
  #before_action :set_comparisons_measures, only: [:edit]

  # GET /result_statistic_sections/1/edit
  def edit
  end

  # PATCH/PUT /result_statistic_sections/1
  # PATCH/PUT /result_statistic_sections/1.json
  def update
    respond_to do |format|
      if @result_statistic_section.update(result_statistic_section_params)
        format.html { redirect_to edit_result_statistic_section_path(@result_statistic_section),
                      notice: t('success') }
        format.json { render :show, status: :ok, location: @result_statistic_section }
      else
        format.html { render :edit }
        format.json { render json: @result_statistic_section.errors, status: :unprocessable_entity }
      end
    end
  end

  def add_comparison
    if params[:result_statistic_section]['comparison_type'] == 'bac'
      temp_result_statistic_section = @result_statistic_section.population.result_statistic_sections.find_by(result_statistic_section_type_id: 2)
    elsif params[:result_statistic_section]['comparison_type'] == 'wac'
      temp_result_statistic_section = @result_statistic_section.population.result_statistic_sections.find_by(result_statistic_section_type_id: 3)
    end

    respond_to do |format|
      if temp_result_statistic_section.update(result_statistic_section_params)
        format.html { redirect_to edit_result_statistic_section_path(@result_statistic_section),
                      notice: t('success') }
        format.json { render :show, status: :ok, location: @result_statistic_section }
      else
        format.html { render :edit }
        format.json { render json: @result_statistic_section.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /result_statistic_sections/1/consolidate
  def consolidate
  end

  private
#    # check if all the join table entries are in place, create if needed
#    def set_comparisons_measures
#      @result_statistic_section.measures.each do |measure|
#        @result_statistic_section.comparisons.each do |comparison|
#          unless @result_statistic_section.comparisons_measures.exists?( measure: measure, comparison: comparison)
#            @result_statistic_section.comparisons_measures.build( measure: measure, comparison: comparison )
#          end
#        end
#      end
#    end

    # Use callbacks to share common setup or constraints between actions.
    def set_arms
      @arms = ExtractionsExtractionFormsProjectsSectionsType1.by_section_name_and_extraction_id_and_extraction_forms_project_id('Arms',
      @result_statistic_section.population.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_section.extraction.id,
      @result_statistic_section.population.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_section.extraction_forms_projects_section.extraction_forms_project.id)
    end

    def set_result_statistic_section
      @result_statistic_section = ResultStatisticSection
        .includes(population: { extractions_extraction_forms_projects_sections_type1: [ :type1, extractions_extraction_forms_projects_section: [ :extraction, extraction_forms_projects_section: :extraction_forms_project ] ] } )
        .includes(:result_statistic_section_type)
        .find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def result_statistic_section_params
      params.require(:result_statistic_section).permit(
        measure_ids: [],
        comparisons_attributes: [:id,
          comparate_groups_attributes: [:id,
            comparates_attributes: [:id,
              comparable_element_attributes: [:id, :comparable_type, :comparable_id]]]])
#
#        measure_ids: [],
#        comparisons_attributes: [ :id, :_destroy, :result_statistic_section_id,
#          comparisons_measures_attributes: [ :id, :_destroy, :comparison_id, :measure_id ,
#          measurement_attributes: [ :id, :_destroy, :comparisons_measure_id, :value ] ],
#        comparate_groups_attributes: [ :id, :_destroy, :comparison_id,
#        comparates_attributes: [ :id, :_destroy, :comparate_group_id, :comparable_element_id,
#        comparable_element_attributes: [ :id, :_destroy, :comparable_type, :comparable_id, :_destroy ] ] ] ] )
    end

    def set_extractions
      @extractions = Extraction
        .includes(projects_users_role: { projects_user: { user: :profile } })
        .where(id: extraction_ids_params)
    end

    def extraction_ids_params
      params.require(:extraction_ids)
    end
end
