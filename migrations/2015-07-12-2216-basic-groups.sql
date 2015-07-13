CREATE TABLE groups (
      id SERIAL PRIMARY KEY
    , name_display VARCHAR(255) NOT NULL
    , description VARCHAR(2048) NOT NULL
    , admin_member_id INTEGER NOT NULL REFERENCES members(id)
);

ALTER TABLE posts ADD COLUMN group_id INTEGER REFERENCES groups(id);
