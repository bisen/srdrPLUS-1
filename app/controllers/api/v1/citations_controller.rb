class Api::V1::CitationsController < Api::V1::BaseController
  def index
    page                      = ( params[ :page ] || 1 ).to_i
    page_size                 = 200
    offset                    = page_size * ( page - 1 )
    query                     = params[ :q ] || ''

    @citation_project_dict    = { }
    @total_count              = 0
    @citations                = [ ]
    @more                     = false

    if params[ :project_id ].present?
      project                 = Project.find( params[ :project_id ] )
      total_arr               = project.citations.by_query( query )
                                                 .order( pmid: :desc )
                                                 .includes( :authors, :journal, :keywords )
      citations_projects      = project.citations_projects.where( citation: total_arr )
      @total_count            = citations_projects.length
      @citation_project_dict  = Hash[ *citations_projects.map { | c_p | [ c_p.citation_id,  c_p.id ] }.flatten ]
      @citations              = total_arr[ offset .. offset + page_size - 1 ]
      @more                   = offset + @citations.length < @total_count
    else
      citations               = Citation.by_query( query )
      @total_count            = citations.length
      @citations              = citations[ offset .. offset + page_size - 1 ]
      @more                   = offset + @citations.length < total_arr.length
    end
  end

  def titles
    page                      = (params[ :page ] || 1).to_i
    query                     = params[ :q ] || ''
    page_size = 30
    offset                    = page_size * ( page - 1 )
    total_arr                 = Citation.by_query( query )
    @total_count              = total_arr.length
    @citations                = total_arr[ offset .. offset + page_size - 1 ]
    @more                     = offset + @citations.length < @total_count
  end
end

