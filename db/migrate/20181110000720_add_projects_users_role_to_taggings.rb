class AddProjectsUsersRoleToTaggings < ActiveRecord::Migration[5.0]
  def change
    add_reference :taggings, :projects_users_role, foreign_key: true
  end
end
