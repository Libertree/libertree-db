CREATE TABLE groups_members (
      group_id INTEGER NOT NULL REFERENCES groups(id)
    , member_id INTEGER NOT NULL REFERENCES members(id)
);
