class CreateEndpoints < ActiveRecord::Migration[7.2]
  def change
    create_table :endpoints, id: :uuid do |t|
      t.string :verb, null: false
      t.string :path, null: false
      t.integer :response_code
      t.json :response_headers, default: {}
      t.text :response_body
      t.timestamps
    end

    add_index :endpoints, [ :verb, :path ], unique: true
  end
end
