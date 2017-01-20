require 'pry'

class Student
    ATTRIBUTES = {
    :id => 0,
    :name => "",
    :tagline => "",
    :github => "",
    :twitter => "",
    :blog_url => "",
    :image_url => "",
    :biography => ""
  }
  attr_accessor *ATTRIBUTES.keys



  def self.create_table
    sql_create = "CREATE TABLE IF NOT EXISTS students (
                    id INTEGER PRIMARY KEY,
                    name TEXT,
                    tagline TEXT,
                    github TEXT,
                    twitter TEXT,
                    blog_url TEXT,
                    image_url TEXT,
                    biography TEXT
      )"

    #DB was created in config/environment.rb
    DB[:conn].execute(sql_create)
  end

  def self.drop_table
    sql_drop = "DROP TABLE IF EXISTS students"

    DB[:conn].execute(sql_drop)
  end

  def insert
    sql_insert = "INSERT INTO students(id, name, tagline, github, twitter, blog_url, image_url, biography)
    VALUES (?,?,?,?,?,?,?,?)"

    DB[:conn].execute(sql_insert, @id, @name, @tagline, @github, @twitter, @blog_url, @image_url, @biography)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end

  # def self.new_from_db(row_array)
  #   self.new.tap do |s|
  #     row_array.each_with_index do |value, index|
  #       s.send("#{ATTRIBUTES.keys[index]}=", value)
  
  #     end

  #   end
  #   binding.pry
  # end

  def self.new_from_db(row)

    keys = ATTRIBUTES.keys


    ##got it to pass but still a little blurry.
    #Creates a new object and sets the attributes for that object.
    self.new.tap do |obj|
    row.each_with_index do |data, index|
      obj.send("#{ATTRIBUTES.keys[index]}=", data)
    end
    end

  end


  def self.find_by_name(name)
    #returns an instance of student that matches the name from the DB

    #find student row in database
    #then create new instance
    sql_find = "SELECT * FROM students WHERE name = ?"
    query_returns = DB[:conn].execute(sql_find, name)[0]
    self.new_from_db(query_returns) if query_returns

  end

  
  def update
    #updates and persists a student in the database
    #still need explanation

    sql = "UPDATE students SET #{ATTRIBUTES.keys[1..-1].collect{|k| "#{k} = ?"}.join(",")} WHERE id = ?"
    DB[:conn].execute(sql, ATTRIBUTES.keys[1..-1].collect{|key| self.send(key)}, id)
  end 

   def persisted?
    !!self.id
  end

  def save
     persisted? ? update : insert
  end

end
