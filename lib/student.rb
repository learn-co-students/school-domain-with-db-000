class Student
	ATTRIBUTES = {
		:id => "INTEGER PRIMARY KEY AUTOINCREMENT",
		:name => "TEXT",
		:tagline => "TEXT",
		:github => "TEXT",
		:twitter => "TEXT",
		:blog_url => "TEXT",
		:image_url => "TEXT",
		:biography => "TEXT"
	}

	attr_accessor *ATTRIBUTES.keys

	def self.create_table
		sql = "CREATE TABLE IF NOT EXISTS students (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			name TEXT,
			tagline TEXT,
			github TEXT,
			twitter TEXT,
			blog_url TEXT,
			image_url TEXT,
			biography TEXT
			)"
		DB[:conn].execute(sql)
	end

	def self.drop_table
		sql = "DROP TABLE IF EXISTS students"
		DB[:conn].execute(sql)
	end

	def insert
		sql = "INSERT INTO students (name, tagline, github, twitter, blog_url, image_url, biography) VALUES (?,?,?,?,?,?,?)"
		DB[:conn].execute(sql, [self.name, self.tagline, self.github, self.twitter, self.blog_url, self.image_url, self.biography])
		@id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
	end

	def self.new_from_db(row_array)
		self.new.tap do |s|
			row_array.each_with_index do |value, index|
				s.send("#{ATTRIBUTES.keys[index]}=", value)
			end
		end
	end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"
    result = DB[:conn].execute(sql,name)[0]  
    self.new_from_db(result) if result
  end

  def update
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
