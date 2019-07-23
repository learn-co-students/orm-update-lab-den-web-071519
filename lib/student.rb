require_relative "../config/environment.rb"

require 'pry'

class Student
attr_accessor :id, :name, :grade

   def initialize(id=nil, name, grade)
     @name = name
     @grade = grade
   end

   def self.create_table
     sql = <<-SQL
     CREATE TABLE IF NOT EXISTS students (
       id INTEGER PRIMARY KEY,
       name TEXT,
       grade INTEGER
     );
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
     if self.id
       self.update
     else
       sql = <<-SQL
       INSERT INTO students (name, grade)
       VALUES (?, ?)
       SQL
       DB[:conn].execute(sql, self.name, self.grade)
       @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
   end

   def update # updates the record associated with a given instnace.
     sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
     DB[:conn].execute(sql, self.name, self.grade, self.id)

   end

   def self.create(name, grade)
     student = Student.new(name, grade)
     student.save
     student
   end

   def self.new_from_db(array)
     student = Student.new(array[1], array[2])
     student.id = array[0]
     student
   end

   def self.find_by_name(student_name)
     sql = <<-SQL
     SELECT *
     FROM students
     WHERE name = ?
     SQL
     found_student = DB[:conn].execute(sql, student_name)[0]
     new_from_db(found_student)
   end


end
