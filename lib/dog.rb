class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql_command = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);
        SQL
        DB[:conn].execute(sql_command)
    end

    def self.drop_table
        sql_command = <<-SQL
            DROP TABLE dogs;
        SQL
        DB[:conn].execute(sql_command)
    end

    def save
        if self.id
            self.update
        else
            sql_command = <<-SQL
                INSERT INTO dogs (name, breed) VALUES (?,?);
            SQL
            DB[:conn].execute(sql_command, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        end
    end

    def self.create(attributes)
        dog = self.new(attributes)
        dog.save
        dog
    end

    def self.new_from_db(row)
        id,name,breed = row
        dog = self.new(id: id, name: name, breed: breed)
        dog
    end

    def self.find_by_id(id)
        sql_query = <<-SQL
            SELECT * FROM dogs WHERE id = ?;
        SQL
        result = DB[:conn].execute(sql_query, id).flatten
        new_from_db(result)
    end

    def self.find_by_name(name)
        sql_query = <<-SQL
            SELECT * FROM dogs WHERE name = ?;
        SQL
        result = DB[:conn].execute(sql_query, name).flatten
        new_from_db(result)
    end

    def self.find_or_create_by(attributes)
        sql_query = <<-SQL
            SELECT * FROM dogs WHERE name = ? AND breed = ?;
        SQL
        result = DB[:conn].execute(sql_query, attributes[:name], attributes[:breed]).flatten
        if !result.empty? #exists
            dog = new_from_db(result)
        else #doesn't exist
            dog = create(attributes)
        end
        dog
    end

    def update
        sql_command = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
        SQL
        DB[:conn].execute(sql_command,self.name, self.breed, self.id)
    end
end