require 'libertree/db'

# Connect to the DB so the ORM can get what it needs to get
Libertree::DB.dbh

require_relative 'model/account'
require_relative 'model/chat-message'
require_relative 'model/comment'
require_relative 'model/comment-like'
require_relative 'model/contact-list'
require_relative 'model/forest'
require_relative 'model/embed-cache'
require_relative 'model/invitation'
require_relative 'model/job'
require_relative 'model/member'
require_relative 'model/message'
require_relative 'model/notification'
require_relative 'model/pool'
require_relative 'model/post'
require_relative 'model/post-hidden'
require_relative 'model/post-like'
require_relative 'model/post-revision'
require_relative 'model/profile'
require_relative 'model/river'
require_relative 'model/server'
require_relative 'model/session-account'
require_relative 'model/url-expansion'

module Libertree
  def self.slice_hash(struct, model)
    column_prefix = model.name.split('::')[-1].downcase + '__'
    model_columns = model.columns.map { |c|
      column_prefix + c.name.to_s
    }

    sliced_hash = Hash[
      *struct.members.map(&:to_s).zip(struct.values).flatten
    ].select { |k,v|
      model_columns.include? k
    }

    Hash[
      # to_sym used for RDBI compatibility.
      # Otherwise, struct-like field access doesn't work.
      # String columns, too, for the times the fields are accessed by String keys.

      sliced_hash.map { |k,v|
        col = k.gsub(/^#{column_prefix}/, '')
        [ col.to_sym, v, ]
      } + sliced_hash.map { |k,v|
        col = k.gsub(/^#{column_prefix}/, '')
        [ col, v, ]
      }
    ]
  end

  module Model
    def self.denormalised_rows_to_model_instances(rows, model)
      sliced_rows = rows.map { |row|
        Libertree.slice_hash(
          row,
          model
        )
      }
      sliced_rows.uniq!
      sliced_rows.map { |row|
        model.new row
      }
    end
  end
end
