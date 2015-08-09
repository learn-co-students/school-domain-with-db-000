require_relative 'spec_helper'

describe Student do

  context "attributes" do
    describe "instance" do
      it " has an id, name, tagline, github username, twitter handle, blog_url, image_url, biography" do

        attributes = {
          :id => 1,
          :name => "Avi",
          :tagline => "Teacher",
          :github => "aviflombaum",
          :twitter => "aviflombaum",
          :blog_url => "http://aviflombaum.com",
          :image_url => "http://aviflombaum.com/picture.jpg",
          :biography => "Programming is my favorite thing in the whole wide world."
        }

        Student.new.tap do |s|
          attributes.each do |key, value|
            s.send("#{key}=", value)
            expect(s.send(key)).to eq(value)
          end  
        end

      end
    end
  end

  describe '::create_table' do
    it 'creates a student table' do
      Student.drop_table
      Student.create_table

      table_check_sql = "SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='students';"
      expect(DB[:conn].execute(table_check_sql)[0]).to eq(['students'])
    end
  end

  describe '::drop_table' do
    it "drops the student table" do
      Student.create_table
      Student.drop_table

      table_check_sql = "SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='students';"
      expect(DB[:conn].execute(table_check_sql)[0]).to be_nil
    end
  end

  describe '::new_from_db' do
    it 'creates an instance with corresponding attribute values' do
      row = [1, "Avi", "Teacher", "aviflombaum", "aviflombaum", "http://aviflombaum.com", "http://aviflombaum.com/picture.jpg"]
      avi = Student.new_from_db(row)

      expect(avi.id).to eq(row[0])
      expect(avi.name).to eq(row[1])
      expect(avi.tagline).to eq(row[2])
      expect(avi.github).to eq(row[3])
      expect(avi.twitter).to eq(row[4])
      expect(avi.blog_url).to eq(row[5])
      expect(avi.image_url).to eq(row[6])
      expect(avi.biography).to eq(row[7])
    end
  end

  context "manipulating students" do
  
    let(:avi){
      Student.new.tap do |s|
        s.name = "Avi"
        s.tagline = "Teacher"
        s.github = "aviflombaum"
        s.twitter = "aviflombaum"
        s.blog_url = "http://aviflombaum.com"
        s.image_url = "http://aviflombaum.com/picture.jpg"
        s.biography = "aviflombaum"
      end
    }

    before do
      Student.create_table
    end
    
    after do
      Student.drop_table
      Student.clear_all
    end    

    describe '#insert' do
      it "inserts the student into the database and updates the current instance's ID" do
        avi.insert

        select_sql = "SELECT name FROM students WHERE name = 'Avi'"
        result = DB[:conn].execute(select_sql)[0]

        expect(result[0]).to eq("Avi")
        expect(avi.id).to eq(1)
      end
    end

    describe "#update" do
      it 'updates and persists a student in the database' do
        avi.insert

        avi.name = "Bob"
        original_id = avi.id

        avi.update

        avi_from_db = Student.find_by_name("Avi")
        expect(avi_from_db).to be_nil

        bob_from_db = Student.find_by_name("Bob")
        expect(bob_from_db).to be_an_instance_of(Student)
        expect(bob_from_db.name).to eq("Bob")
        expect(bob_from_db.id).to eq(original_id)
      end
    end

    describe '::find_by_name' do
      it 'returns an instance of student that matches the name from the DB' do
        avi.save

        avi_from_db = Student.find_by_name("Avi")
        expect(avi_from_db.name).to eq("Avi")
        expect(avi_from_db).to be_an_instance_of(Student)
      end
    end

    describe '#save' do
      it "chooses the right thing on first save" do
        expect(avi).to receive(:insert)
        avi.save
      end

      it 'chooses the right thing for all others' do
        avi.save

        avi.name = "Bob"
        expect(avi).to receive(:update)
        avi.save
      end
    end

    describe '::all' do
      it 'has our default "Avi" instance in an array' do
        avi.save
        all_students = Student.all
        expect(all_students).to be_an_instance_of(Array)
        expect(all_students.size).to eq(1)
        expect(all_students.include?(avi)).to eq(true)
      end
      
      it 'tracks any other added student' do
        avi.save

        newcomer = Student.new  
        newcomer.name = 'Bob'

        all_students = Student.all
        expect(all_students.size).to eq(2)
        expect(all_students.include?(newcomer)).to eq(true)
      end
    end 

    describe "::clear_all" do
      it 'clears all_students array' do
        avi.save
        newcomer = Student.new
        newcomer.name = 'Bob'

        Student.clear_all
        all_students = Student.all
        expect(all_students.size).to eq(0)
      end  
    end 

    describe '#delete' do
      it 'deletes a student from both database and all_students array, and sets its ID to nil' do
        avi.save
        old_avi_id = avi.id
        avi.delete

        all_students = Student.all
        expect(all_students.include?(avi)).to eq(false)
        expect(avi.id).to be_nil

        row = DB[:conn].execute("SELECT * FROM students WHERE id = ?", old_avi_id)[0]
        expect(row).to be_nil
      end  
    end  

    describe '#id=' do
      it 'cannot change an ID' do
        avi.save
        expect{avi.id = 2}.to raise_error(StudentError)
      end  
    end  
  end
end
