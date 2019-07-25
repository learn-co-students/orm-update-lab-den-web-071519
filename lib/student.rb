require_relative "../config/environment.rb"
require 'pry'

 # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize id=nil, name, grade 
    @name = name
    @grade = grade 
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students;
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id == nil
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?) 
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    else
      sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.grade, self.id)
    end
  end

  def self.create name, grade
    student = Student.new(name, grade)
    student.save
  end

  def self.new_from_db row
    student = Student.new(row[0], row[1], row[2])
    student
  end

  def self.find_by_name name
    sql = <<-SQL
      SELECT * FROM students WHERE name = ?
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ?, id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
 


end
