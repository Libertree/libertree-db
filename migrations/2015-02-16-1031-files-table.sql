CREATE TABLE files (
      id SERIAL PRIMARY KEY
    , account_id INTEGER NOT NULL REFERENCES accounts(id)
    , filename VARCHAR(255) NOT NULL
);

COMMENT ON COLUMN files.filename IS
'Filename.  Not a path.';
