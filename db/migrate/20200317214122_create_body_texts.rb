class CreateBodyTexts < ActiveRecord::Migration[5.2]
  def up
    create_table :body_texts do |t|
      t.integer :paper_id
      t.string :section
      t.integer :sequence
      t.text :content
      t.tsvector :search_vector

      t.timestamps
    end
    execute "CREATE INDEX body_texts_search_idx ON papers USING gin(search_vector);"
    execute "DROP TRIGGER IF EXISTS body_texts_search_vector_update ON body_texts;"
    execute "CREATE TRIGGER body_texts_search_vector_update BEFORE INSERT OR UPDATE ON body_texts FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger(search_vector, 'pg_catalog.english', section, content);"
  end
  
  def down
    drop_table :body_texts
    execute "DROP TRIGGER IF EXISTS body_texts_search_vector_update on papers;"
  end
end
