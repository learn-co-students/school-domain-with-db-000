require 'pry'

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

    attr_accessor *ATTRIBUTES.keys

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS students (
                id INTEGER PRIMARY KEY,
                name TEXT,
                tagline TEXT,
                github TEXT,
                twitter TEXT,
                blog_url TEXT,
                image_url TEXT,
                biography TEXT
            )
            SQL
       DB[:conn].execute(sql) 
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE students
        SQL
        DB[:conn].execute(sql)
    end

    def self.new_from_db(row)
        # [1, "Avi", "Teacher", "aviflombaum", "aviflombaum", "http://aviflombaum.com", "http://aviflombaum.com/picture.jpg"]
        self.new.tap do |s|
            row.each_with_index do |value, index|
                s.send("#{ATTRIBUTES.keys[index]}=", value)
            end
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM students WHERE name = ?
        SQL
        student_data = DB[:conn].execute(sql, name)[0]
        self.new_from_db(student_data) if student_data
    end

    def attribute_values
        [self.name, self.tagline, self.github, self.twitter, self.blog_url, self.image_url, self.biography]
    end

    def insert
        sql = <<-SQL
            INSERT INTO students (name, tagline, github, twitter, blog_url, image_url, biography) VALUES (?,?,?,?,?,?,?)
            SQL
        DB[:conn].execute(sql, *attribute_values)

        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end

    def update 
        sql = <<-SQL
            UPDATE students
            SET 
                name = ?,
                tagline = ?,
                github = ?,
                twitter = ?,
                blog_url = ?,
                image_url = ?,
                biography = ?
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, *attribute_values, id)
    end

    def save
        if self.id
            update
        else 
            insert
        end
    end
end
