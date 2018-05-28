# Attempt to find the column index in the given row for a cell that starts with given value.
#
# returns (Boolean, Idx)
def _find_column_idx_with_value(row, value)
  row.cells.each do |cell|
    return [true, cell.index] if cell.value.start_with?(value)
  end

  return [false, row.cells.length]
end

# We keep several dictionaries here. They all track the same information such as type1s, populations and timepoints.
# One list is kept as a master list. Those are on SheetInfo.type1s, SheetInfo.populations, and SheetInfo.timepoints.
# Another is kept for each extraction.
class SheetInfo
  attr_reader :header_info, :extractions, :type1s, :populations, :timepoints

  def initialize
    @header_info = ['Extraction ID', 'Username', 'Citation ID', 'Citation Name', 'RefMan', 'PMID']
    @extractions = Hash.new
    @type1s      = Set.new
    @populations = Set.new
    @timepoints  = Set.new
  end

  def new_extraction_info(extraction)
    @extractions[extraction.id] = {
      extraction_id: extraction.id,
      type1s: [],
      populations: [],
      timepoints: [],
      questions: {}
    }
  end

  def set_extraction_info(params)
    @extractions[params[:extraction_id]][:extraction_info] = params
  end

  def add_type1(params)
    @extractions[params[:extraction_id]][:type1s] << params
    @type1s << params
  end

  def add_population(params)
    @extractions[params[:extraction_id]][:populations] << params
    @populations << params
  end

  def add_timepoint(params)
    @extractions[params[:extraction_id]][:timepoints] << params
    @timepoints << params
  end

  def add_question(params)
    @extractions[params[:extraction_id]][:questions][params[:id]] = params
  end

  def add_question_row_column(params)
  end
end
