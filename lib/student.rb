class Student
  attr_accessor :id, :name,  :tagline, :github, :twitter, :blog_url, :image_url, :biography
  
  def self.create_table
    DB[:conn].execute("CREATE TABLE students( id INTEGER PRIMARY KEY, name TEXT, tagline TEXT, github TEXT, twitter TEXT, blog_url TEXT, image_url TEXT, biography TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students") 
  end

  def insert
    DB[:conn].execute("INSERT INTO students (name, tagline, github, twitter, blog_url, image_url, biography) VALUES (?,?,?,?,?,?,?)", [name, tagline, github, twitter, blog_url, image_url, biography]) 
    self.id=(DB[:conn].execute("SELECT last_insert_rowid() FROM students").flatten.first)
  end
 
  def self.new_from_db(row)
    Student.new.tap do |s|
      s.id        = row[0]
      s.name      = row[1]
      s.tagline   = row[2]
      s.github    = row[3]
      s.twitter   = row[4]
      s.blog_url  = row[5]
      s.image_url = row[6]
      s.biography = row[7]
    end
  end
  
  def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM students WHERE name = '#{name}'").flatten
    if row.empty?
      nil
    else
      student = Student.new_from_db(row)
      student
    end
  end

  
  def update
    DB[:conn].execute("UPDATE students SET name = '#{name}' WHERE id = '#{id}'") 
  end

  def save
    row = DB[:conn].execute("SELECT * FROM students where id = '#{id}'").flatten
    if row.empty? 
      self.insert
    else
      self.update
    end
  end

end
