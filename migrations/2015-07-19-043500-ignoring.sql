CREATE TABLE ignored_members (
      account_id INTEGER NOT NULL REFERENCES accounts(id)
    , member_id INTEGER NOT NULL REFERENCES members(id)
);

COMMENT ON COLUMN ignored_members.account_id IS
'The account doing the ignoring.';

COMMENT ON COLUMN ignored_members.member_id IS
'The member that is being ignored.';
