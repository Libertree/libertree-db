ALTER TABLE message_recipients ADD COLUMN symkey VARCHAR(4096);
COMMENT ON COLUMN message_recipients.symkey IS
'The symmetric key to decrypt the message, encrypted under the public key of the recipient.';
