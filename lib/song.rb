class Song

  attr_accessor :name, :album, :id

  def initialize(name:, album:, id: nil)
    @id = id
    @name = name
    @album = album
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS songs
    SQL

    DB[:conn].execute(sql)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS songs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO songs (name, album)
      VALUES (?, ?)
    SQL

    # insert the song
    DB[:conn].execute(sql, self.name, self.album)

    # get the song ID from the database and save it to the Ruby instance
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]

    # return the Ruby instance
    self
  end

  def self.create(name:, album:)
    song = Song.new(name: name, album: album)
    song.save
  end

  def self.new_from_db(row)
    # From my own understanding, since this is a class method, self.new is the same as Song.new, and we are initializing it with the values obtained from a particular row in the db table. 
    self.new(id: row[0], name: row[1], album: row[2])
  end

  def self.all
    # grabs all the songs from the database. This is a better alternative to declaring @@all, because we are persisting the data to the database. Will still be there if the code stops running. 
    sql = <<-SQL
      SELECT *
      FROM songs
    SQL

    # accessing the database connection from environment.rb file
    # Returns an array of rows from teh database that matches the query, which we can then map over to create a new ruby object for each row
    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end

  # The only difference between the above is that we are give the method an argument, and including that name in the SQL query to retrieve it. The .first method just returns the first matching name.
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM songs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end


end
