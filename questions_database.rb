require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')

    self.results_as_hash = true
    self.type_translation = true
  end
end

class User
  attr_accessor :id, :fname, :lname

  def self.find_by_id(my_id) #find_by for 1 result
    results = QuestionsDatabase.instance.execute(<<-SQL, my_id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL

    User.new(results.first) # 1 result
  end

  def initialize(attrs = {})
    # @id, @fname = attrs.values_at('id', 'fname')
    @id = attrs['id']
    @fname = attrs['fname']
    @lname = attrs['lname']
  end

  def attrs
    { fname: fname, lname: lname }
  end

  def save
    if @id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, *attrs.values )
        INSERT INTO
          users (fname, lname)
        VALUES
          (?, ?)
      SQL
      self.id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, fname, lname, id)
        UPDATE
          users
        SET
          fname = ?, lname = ?
        WHERE
          id = ?
      SQL
    end
  end
end


class Question
  attr_accessor :id, :users_id, :body, :title

  def self.find_by_id
    results = QuestionsDatabase.instance.execute('SELECT id FROM questions')
    results.map { |result| Question.new(result) }
  end

  def self.where_author_id(author_id) #use where for plural results
    results = QuestionsDatabase.instance.execute(<<-SQL)
    SELECT
      *
    FROM
      questions
    WHERE
      users_id = #{author_id}
    SQL

    results.map { |result| Question.new(result) }
  end

  def initialize(attrs = {})
    @id = attrs['id']
    @users_id = attrs['users_id']
    @body = attrs['body']
    @title = attrs['title']
  end

  def author
    User.find_by_id(@users_id)
  end

end

class QuestionFollow

  attr_accessor :id, :questions_id, :users_id

  def self.find_by_id
    results = QuestionsDatabase.instance.execute('SELECT id FROM question_follows')
    results.map { |result| QuestionFollow.new(result) }
  end

  def self.followers_for_question_id(my_question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, my_question_id)
      SELECT
        *
      FROM
        users
      JOIN
        question_follows ON users.id = question_follows.users_id
      WHERE
        questions_id = ?
      SQL

    results.map {|result| User.new(result)}
  end

  def self.most_followed_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        *
      FROM
        questions
      JOIN
        question_follows ON questions.id = question_follows.questions_id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(*) DESC
      LIMIT
        ?
    SQL
    results.map { |result| Question.new(result) }
  end

  def initialize(attrs = {})
    @id = attrs['id']
    @questions_id = attrs['questions_id']
    @users_id = attrs['users_id']
  end
end

class Reply
  attr_accessor :id, :questions_id, :users_id, :body

  def self.find_by_id
    results = QuestionsDatabase.instance.execute('SELECT id FROM replies')
    results.map { |result| Reply.new(result) }
  end

  def self.find_by_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        users_id = ?
    SQL
    results.map {|result| Reply.new(result)}
  end

  def self.where_question_id(my_question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, my_question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        questions_id = ?
    SQL
    results.map { |result| Reply.new(result) }
  end

  def initialize(attrs = {})
    @id = attrs['id']
    @questions_id = attrs['questions_id']
    @users_id = attrs['users_id']
    @body = attrs['body']
  end
end

class QuestionLike

  attr_accessor :id, :users_id, :questions_id, :likes

  def self.find_by_id
    results = QuestionsDatabase.instance.execute('SELECT id FROM question_likes')
    results.map { |result| QuestionLike.new(result) }
  end
end
