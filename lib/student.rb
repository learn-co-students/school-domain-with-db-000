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
  
  # ATTRIBUTES.keys.each do |attribute|
  #   attr_accessor attribute
  # end
  attr_accessor *ATTRIBUTES.keys

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
        #{schema_definition}
        )
    SQL
    DB[:conn].execute(sql)
  end

  def self.schema_definition
    ATTRIBUTES.collect{|k,v| "#{k} #{v}"}.join(",")
  end

  def sql_for_update
    ATTRIBUTES.keys[1..-1].collect{|k| "#{k} = ?"}.join(",")
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end    

  def self.new_from_db(row)
    self.new.tap do |s|
      row.each_with_index do |value, index|
        s.send("#{ATTRIBUTES.keys[index]}=", value)
      end
    end
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"
      result = DB[:conn].execute(sql,name)[0] #[]    
      self.new_from_db(result) if result
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM students WHERE id = ?"
      result = DB[:conn].execute(sql,id)[0] #[]    
      self.new_from_db(result) if result
  end

  def attribute_values
    ATTRIBUTES.keys[1..-1].collect{|key| self.send(key)}
  end

  def insert
    sql = "INSERT INTO students (#{ATTRIBUTES.keys[1..-1].join(",")}) VALUES (?,?,?,?,?,?,?)"
    DB[:conn].execute(sql, *attribute_values)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end


  def update
    sql = "UPDATE students SET #{sql_for_update} WHERE id = ?"
    DB[:conn].execute(sql, *attribute_values, id)
  end    

  def persisted?
    !!self.id
  end

  def save
    persisted? ? update : insert
  end

  def courses
    sql = <<-SQL
    SELECT courses.* 
    FROM students 
    JOIN registrations 
    ON students.id = registrations.student_id 
    JOIN courses 
    ON courses.id = registrations.course_id 
    WHERE students.id = ?
    SQL
    result = DB[:conn].execute(sql, self.id) 
    result.map do |row|
      Course.new_from_db(row)
    end
  end

  def add_course(course)
    sql = "INSERT INTO registrations (course_id, student_id) VALUES (?,?);"
    DB[:conn].execute(sql, course.id, self.id)
  end
end