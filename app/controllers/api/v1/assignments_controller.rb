module Api
  module V1
    class AssignmentsController < BaseController
      before_action :set_assignment, only: [:screen]

      api :GET, '/v1/assignments/:id/screen', 'List of citations to screen and past labels from current user'
      formats [:json]
      def screen
        @unlabeled_citations_projects = CitationsProject.unlabeled( @assignment.project, params[:count] )

        @past_labels = Label.last_updated( current_user, @assignment.project, params[:count] )
        
        render 'screen.json'
      end

    private

      def set_assignment
        @assignment = Assignment.find( params[:id] )
      end
    end
  end
end
