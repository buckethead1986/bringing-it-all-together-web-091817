require 'pry'
class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    # binding.pry
    @id = id
    @name = name
    @breed = breed
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    new_dog = self.new(id: row[0], name: row[1], breed: row[2])
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self #return instance of dog class just created
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name)[0]
    new_dog = self.new_from_db(row)
    # hash = {id: row[0], name: row[1], breed: row[2]}
    # self.new(hash)
  end

  def self.create(info)
    new_dog = Dog.new(info)
    new_dog.save
    new_dog
  end

  def self.find_or_create_by(info)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    row = DB[:conn].execute(sql, info[:name], info[:breed]).flatten
    if row.empty?
      dog = self.new(info)
      dog.save
    else
      dog = self.find_by_name(info[:name])
    end
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, id)[0]
    new_dog = self.new_from_db(row)
    end



end
