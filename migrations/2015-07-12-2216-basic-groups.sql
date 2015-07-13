CREATE TABLE groups (
      id SERIAL PRIMARY KEY
    , name_display VARCHAR(255) NOT NULL CONSTRAINT non_empty_name_display CHECK(length(trim(from name_display))>0)
    , description VARCHAR(2048) NOT NULL CONSTRAINT non_empty_description CHECK(length(trim(from description))>0)
    , admin_member_id INTEGER NOT NULL REFERENCES members(id)
);

ALTER TABLE posts ADD COLUMN group_id INTEGER REFERENCES groups(id);
