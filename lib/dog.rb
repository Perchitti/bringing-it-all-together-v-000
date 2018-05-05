require_relative "../config/environment.rb"
require 'pry'

class Dog

    attr_accessor :id, :name, :breed

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(id=nil, name, breed)
      @id = id
      @name = name
      @breed = breed
  end

  def self.create_table
      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
         id INTEGER PRIMARY KEY,
         name TEXT,
         breed TEXT
        )
      SQL
      DB[:conn].execute(sql)
  end

  def self.drop_table
      sql = "DROP TABLE dogs"
      DB[:conn].execute(sql)
  end

  def save
      if self.id
          sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
          DB[:conn].execute(sql, self.name, self.breed, self.id)
      else
          sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?);
          SQL
          DB[:conn].execute(sql, self.name, self.breed)
          @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
     end
  end

  def self.create(name, breed)
      new_dog = self.new(name, breed)
      new_dog.save
      new_dog
  end

  def self.new_from_db(row)
      new_dog = self.new(row[0], row[1], row[2])

  end

  def self.find_by_name(name)
      sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?;
      SQL
      dog_found = DB[:conn].execute(sql, name).first
      self.new_from_db(dog_found)
  end

  def update
      self.save

  end

end
