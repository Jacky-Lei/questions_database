DROP TABLE IF EXISTS users;

CREATE TABLE users(
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions(
  id INTEGER PRIMARY KEY,
  title VARCHAR(255),
  body TEXT,
  users_id INTEGER NOT NULL,
  FOREIGN KEY (users_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows(
  id INTEGER PRIMARY KEY,
  questions_id INTEGER REFERENCES questions(id),
  users_id INTEGER REFERENCES users(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies(
  id INTEGER PRIMARY KEY,
  body TEXT,
  questions_id INTEGER REFERENCES questions(id),
  users_id INTEGER REFERENCES users(id),
  replies_id INTEGER REFERENCES replies(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes(
  id INTEGER PRIMARY KEY,
  users_id INTEGER REFERENCES users(id),
  questions_id INTEGER REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ("Matt", "Highfield"),
  ("Jacky", "Lei");

INSERT INTO
  questions (title, body, users_id)
VALUES
  ("SQL Confusion", "How the heck do you do this stuff?", 1),
  ("Another Question", "Will this give me an array of two questions?", 1),
  ("Costco Travels", "When is the next time we are going to costco?", 2);

INSERT INTO
  replies (body, questions_id, users_id)
VALUES
  ("You practice A TON, yo.", (SELECT id FROM questions WHERE title = "SQL Confusion"), 2),
  ("I probably want to go about every two weeks, so in about 1.5 weeks.",
  (SELECT id FROM questions WHERE title = "Costco Travels"), 1);

INSERT INTO
  question_follows (questions_id, users_id)
VALUES
  (1, 2),
  (2, 2),
  (2, 1);

INSERT INTO
  question_likes (users_id, questions_id)
VALUES
  (1, 2),
  (1, 1),
  (1, 2);

INSERT INTO
  replies (body, questions_id, users_id, replies_id)
VALUES
  ("That sounds ok, but I really want more beer sooner",
    (SELECT id FROM questions WHERE title = "Costco Travels"),
  2, (SELECT id FROM replies WHERE body LIKE '%probably%'));
