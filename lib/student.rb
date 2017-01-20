class StudentError < StandardError 
end

class Student
  ATTRIBUTES = {
    :id => "INTEGER PRIMARY KEY",
    :name => "TEXT",
    :tagline => "TEXT",
    :github =>  "TEXT",
    :twitter =>  "TEXT",
    :blog_url =>  "TEXT",
    :image_url  => "TEXT",
    :biography =>  "TEXT"
  }

  @@all_students = []

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS students (#{schema_definition})")
  end

  def self.schema_definition
    ATTRIBUTES.collect{|k,v| "#{k} #{v}"}.join(",")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS students")
  end

  def self.new_from_db(row)
    self.new.tap do |object|
      ATTRIBUTES.keys.each_with_index { |key, index| object.send("#{key}=", row[index]) }
    end	
  end	

  def self.find_by_attr(attr_name, attr_value)
  	row = DB[:conn].execute("SELECT * FROM students WHERE #{attr_name} = ?", attr_value)[0]
  	self.new_from_db(row) if row
  end	

  def self.find_by_name(name)
  	self.find_by_attr("name", name)
  end	

  def self.all
  	@@all_students
  end

  def self.clear_all
    @@all_students.clear
  end  	

  attr_accessor *ATTRIBUTES.keys

  def initialize
  	@@all_students << self
  end	

  def id=(id)
  	if @id then 
  	  raise StudentError, "Unable to change an ID!"
  	else
  	  @id = id
  	end  
  end

  def persisted?
    !!self.id
  end

  def insert
    DB[:conn].execute("INSERT INTO students (#{sql_columns}) VALUES (#{sql_question_marks})", sql_values)
    @@all_students << self unless @@all_students.include?(self)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end

  def update
  	DB[:conn].execute("UPDATE students SET #{sql_update_string} WHERE id = ?", [sql_values, @id].flatten)
  end

  def save
    persisted? ? update : insert
  end	

  def delete
  	DB[:conn].execute("DELETE FROM students WHERE id = ?", @id)
  	@@all_students.delete(self)
  	@id = nil
  end	

  def sql_columns
  	ATTRIBUTES.keys[1..-1].join(",")
  end

  def sql_question_marks
  	(["?"]*ATTRIBUTES.keys[1..-1].size).join(",")
  end

  def sql_update_string
  	ATTRIBUTES.keys[1..-1].map { |key| "#{key} = ?" }.join(",")
  end

  def sql_values
  	ATTRIBUTES.keys[1..-1].map { |key| self.send(key) }
  end
  	
end
