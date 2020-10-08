CREATE TABLE lists(
    id serial PRIMARY KEY,
    name varchar(100) UNIQUE NOT NULL,
    check (char_length(name) BETWEEN 1 AND 100)
);

CREATE TABLE todos(
    id serial PRIMARY KEY,
    name varchar(100) NOT NULL,
    list_id integer NOT NULL,
    completed boolean NOT NULL DEFAULT false,
    check (char_length(name) BETWEEN 1 AND 100),
    FOREIGN KEY (list_id) REFERENCES lists(id) ON DELETE CASCADE
);