class Student
  attr_accessor :id, :name,  :tagline, :github, :twitter, :blog_url, :image_url, :biography
  
  def self.create_table
    DB[:conn].execute("CREATE TABLE students( id INTEGER PRIMARY ID, name TEXT, tagline TEXT, github TEXT, twitter TEXT, blog_url TEXT, image_url TEXT, biography TEXT)")
  end
end
