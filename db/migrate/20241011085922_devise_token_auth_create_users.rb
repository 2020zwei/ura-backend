class DeviseTokenAuthCreateUsers < ActiveRecord::Migration[7.1]
    def change
    ## Additional columns required by Devise Token Auth
    change_table(:users) do |t|
      ## Required
      t.string :provider, null: false, default: "email"
      t.string :uid, null: false, default: ""

      ## Recoverable
      t.boolean :allow_password_change, default: false

      ## Tokens
      t.json :tokens
    end

    ## Add indexes if needed
    add_index :users, [:uid, :provider], unique: true
    # add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token, unique: true
  end
end
