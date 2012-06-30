module Libertree
  module Model
    class Comment < M4DBI::Model(:comments)
      after_create do |comment|
        # TODO: only create job for local comments
        Libertree::Model::Job.create_for_forests(
          {
            task: 'request:COMMENT',
            params: { 'comment_id' => comment.id, }
          },
          *comment.forests
        )
      end

      before_destroy do |comment|
        # TODO: only create job for local comment
        Libertree::Model::Job.create_for_forests(
          {
            task: 'request:COMMENT-DELETE',
            params: { 'comment_id' => comment.id, }
          },
          *comment.forests
        )
      end

      def member
        @member ||= Member[self.member_id]
      end

      def post
        @post ||= Post[self.post_id]
      end

      # RDBI casting not working with TIMESTAMP WITH TIME ZONE ?
      def time_created
        DateTime.parse self['time_created']
      end

      def delete_cascade
        DB.dbh.d  %|DELETE FROM notifications WHERE data = '{"type":"comment","comment_id":#{self.id}}'|
        DB.dbh.d(
          %{
            UPDATE accounts
            SET watched_post_last_comment_id = (
              SELECT MAX(id)
              FROM comments
              WHERE
                post_id = ?
                AND id < ?
            )
            WHERE watched_post_last_comment_id = ?
          },
          self.post.id,
          self.id,
          self.id
        )
        self.delete
      end

      # TODO: DRY up with Post#glimpse
      def glimpse
        if self.text.length < 61
          self.text
        else
          self.text[0...60] + '...'
        end
      end

      def self.search(q)
        self.s("SELECT * FROM comments WHERE text ILIKE '%' || ? || '%' ORDER BY time_created DESC LIMIT 42", q)
      end

      def self.create(*args)
        comment = super
        account = comment.member.account
        comment.post.mark_as_unread_by_all  except: [account]
        if account
          comment.post.mark_as_read_by account
          account.subscribe_to comment.post
        end
        comment.post.notify_about_comment comment
        comment
      end

      def likes
        @likes ||= CommentLike.s("SELECT * FROM comment_likes WHERE comment_id = ? ORDER BY id DESC", self.id)
      end

      def notify_about_like(like)
        notification_attributes = {
          'type'         => 'comment-like',
          'comment_like_id' => like.id,
        }
        local_comment_author = like.comment.member.account
        like_author = like.member.account

        if local_comment_author && local_comment_author != like_author
          local_comment_author.notify_about notification_attributes
        end
      end

      def like_by(member)
        CommentLike[ member_id: member.id, comment_id: self.id ]
      end

      def server
        self.member.server
      end

      def public_id
        self.remote_id || self.id
      end

      def forests
        if self.post.remote?
          self.post.server.forests
        else
          Libertree::Model::Forest.all_local_is_member
        end
      end
    end
  end
end
