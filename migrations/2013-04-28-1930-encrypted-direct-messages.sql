ALTER TABLE message_recipients ADD COLUMN symkey VARCHAR(4096);
COMMENT ON COLUMN message_recipients.symkey IS
'The symmetric key to decrypt the message, encrypted under the public key of the recipient.';

ALTER TABLE messages ADD COLUMN iv VARCHAR(256);
COMMENT ON COLUMN messages.iv IS
'The initialisation vector used to encrypt the message.'
