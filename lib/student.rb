class Student

  attr_accessor :id, :name, :tagline, :github, :twitter, :blog_url, :image_url, :biography

  def insert
    DB[:conn].execute("INSERT INTO students (name, tagline, github, twitter, blog_url, image_url, biography) 
                        VALUES (?,?,?,?,?,?,?)", self.name, self.tagline, self.github, self.twitter, self.blog_url, self.image_url, self.biography)
    self.id = DB[:conn].execute("SELECT students.id FROM students WHERE students.name = '#{self.name}';")[0][0]
  end

  def update
    DB[:conn].execute("UPDATE students SET name = ?", self.name)
  end


  def save

    ####THIS .SAVE CODE IS ATROCIOUS. 
    ####THE QUESTION IS: WHY DOES `SELF.INSERT` RETURN NILL INSIDE THIS INSTANCE METHOD 
    ####WHEN ALL OTHER OBJECTS IN THE STUDENT CLASS WORK CORRECTLY WITH .INSERT???

    if DB[:conn].execute("SELECT * FROM students WHERE students.name = ?", self.name).flatten.empty?
      DB[:conn].execute("INSERT INTO students (name, tagline, github, twitter, blog_url, image_url, biography) 
                        VALUES (?,?,?,?,?,?,?)", self.name, self.tagline, self.github, self.twitter, self.blog_url, self.image_url, self.biography)
      self.id = DB[:conn].execute("SELECT students.id FROM students WHERE students.name = '#{self.name}';")[0][0]
      insert
      save
    else
      self.update
    end
  end

  def self.new_from_db(row)
    new_student = Student.new
    new_student.id = row[0]
    new_student.name = row[1]
    new_student.tagline = row[2]
    new_student.github = row[3]
    new_student.twitter = row[4]
    new_student.blog_url = row[5]
    new_student.image_url = row[6]
    new_student.biography = row[7]
    new_student
  end

  def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM students WHERE students.name = ?", name).flatten
    if !row.empty?
      self.new_from_db(row) 
    else
      nil    
    end 
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE students (id INTEGER PRIMARY KEY, 
                                                      name TEXT, 
                                                      tagline TEXT, 
                                                      github TEXT, 
                                                      twitter TEXT,
                                                      blog_url TEXT,
                                                      image_url TEXT,
                                                      biography TEXT
                                                      );
                                                      ")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students")
  end

end
