module Libertree
  module Model
    class CommentLike < M4DBI::Model(:comment_likes)
      def member
        @member ||= Member[self.member_id]
      end

      def comment
        @comment ||= Comment[self.comment_id]
      end

      # RDBI casting not working with TIMESTAMP WITH TIME ZONE ?
      def time_created
        DateTime.parse self['time_created']
      end

      def delete_cascade
        DB.dbh.d %|DELETE FROM notifications WHERE data = '{"type":"comment-like","comment_like_id":#{self.id}}'|
        self.delete
      end

      def self.create(*args)
        like = super
        like.comment.notify_about_like like
        like
      end
    end
  end
end