CREATE OR REPLACE FUNCTION notify_new_chat_messages() RETURNS trigger AS $$
BEGIN
       NOTIFY chat_messages;
       RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION notify_new_comments() RETURNS trigger AS $$
BEGIN
       NOTIFY comments;
       RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION notify_new_notifications() RETURNS trigger AS $$
BEGIN
       NOTIFY notifications;
       RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION notify_updated_notifications() RETURNS trigger AS $$
BEGIN
       NOTIFY notifications_updated;
       RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION notify_deleted_comment() RETURNS trigger AS $$
BEGIN
    PERFORM pg_notify('comment_deleted', OLD.id::TEXT || ',' || OLD.post_id::TEXT);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER after_insert AFTER INSERT ON chat_messages FOR EACH STATEMENT EXECUTE PROCEDURE notify_new_chat_messages();
CREATE TRIGGER after_insert AFTER INSERT ON comments      FOR EACH STATEMENT EXECUTE PROCEDURE notify_new_comments();
CREATE TRIGGER after_insert AFTER INSERT ON notifications FOR EACH STATEMENT EXECUTE PROCEDURE notify_new_notifications();

CREATE TRIGGER after_update_seen
AFTER UPDATE OF seen ON notifications
FOR EACH STATEMENT
EXECUTE PROCEDURE notify_updated_notifications();

CREATE TRIGGER after_delete
AFTER DELETE ON comments
FOR EACH ROW
EXECUTE PROCEDURE notify_deleted_comment();
