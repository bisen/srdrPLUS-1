require 's_import_job/worksheet_section'

#!!!
class GenericType2 < WorksheetSection

  protected

  #!!!
  def _validate_row(row)
    return true
  end

  #!!!
  def _process_row(row)
  end

  #!!!
  def _return_worksheet_type
    return 'worksheet type'
  end
end
