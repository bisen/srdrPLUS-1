class AddEefpsqrcfEefpst1JoinTable < ActiveRecord::Migration[5.0]
  def change
    create_table :eefpsqrcf_eefpst1s do |t|
      t.references :eefps_qrcf, foreign_key: true, index: { name: 'index_eefpsqrcfeefpst1_on_eefps_qrcf_id' }
      t.references :extractions_extraction_forms_projects_sections_type1, foreign_key: true, index: { name: 'index_eefpsqrcfeefpst1_on_eefpst1_id' }
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    remove_column :eefps_qrcfs, :extractions_extraction_forms_projects_sections_type1_id
  end
end
