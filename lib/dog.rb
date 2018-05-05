require_relative "../config/environment.rb"
require 'pry'

class Student

    attr_accessor :id, :name, :grade

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(id=nil, name, grade)
      @id = id
      @name = name
      @grade = grade
  end

  def self.create_table
      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS students(
         id INTEGER PRIMARY KEY,
         name TEXT,
         grade TEXT
        )
      SQL
      DB[:conn].execute(sql)
  end

  def self.drop_table
      sql = "DROP TABLE students"
      DB[:conn].execute(sql)
  end

  def save
      if self.id
          sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
          DB[:conn].execute(sql, self.name, self.grade, self.id)
      else
          sql = <<-SQL
            INSERT INTO students (name, grade)
            VALUES (?, ?);
          SQL
          DB[:conn].execute(sql, self.name, self.grade)
          @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
     end
  end

  def self.create(name, grade)
      new_student = self.new(name, grade)
      new_student.save
      new_student
  end

  def self.new_from_db(row)
      new_student = self.new(row[0], row[1], row[2])

  end

  def self.find_by_name(name)
      sql = <<-SQL
      SELECT * FROM students
      WHERE name = ?;
      SQL
      student_found = DB[:conn].execute(sql, name).first
      self.new_from_db(student_found)
  end

  def update
      self.save

  end

end
