class CreatePapers < ActiveRecord::Migration[5.2]
  def up
    create_table :papers do |t|
      t.string :paper_id
      t.string :title
      t.text :abstract
      t.tsvector :search_vector
      
      t.timestamps
    end
    execute "CREATE INDEX abstracts_search_idx ON papers USING gin(search_vector);"
    execute "DROP TRIGGER IF EXISTS papers_search_vector_update ON papers;"
    execute "CREATE TRIGGER papers_search_vector_update BEFORE INSERT OR UPDATE ON papers FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger(search_vector, 'pg_catalog.english', title, abstract);"
  end
  
  def down
    drop_table :papers
    execute "DROP TRIGGER IF EXISTS papers_search_vector_update on papers;"
  end
end
