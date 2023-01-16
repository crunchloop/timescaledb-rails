# frozen_string_literal: true

# rubocop:disable Rails/ApplicationRecord
class HypertableDefaultSchema < ActiveRecord::Base
  include Timescaledb::Rails::Model

  self.table_name = 'payloads'
end

class HypertableCustomSchema < ActiveRecord::Base
  include Timescaledb::Rails::Model

  self.table_name = 'tdb.events'
end

class NonHypertable < ActiveRecord::Base
  include Timescaledb::Rails::Model

  self.table_name = 'event_types'
end

class StandardHypertable < ActiveRecord::Base
  include Timescaledb::Rails::Model

  self.table_name = 'payloads'
end

class HypertableWithCompression < ActiveRecord::Base
  include Timescaledb::Rails::Model

  self.table_name = 'tdb.events'
end

class HypertableWithoutCompression < ActiveRecord::Base
  include Timescaledb::Rails::Model

  self.table_name = 'payloads'
end

class HypertableWithRetentionPolicy < ActiveRecord::Base
  include Timescaledb::Rails::Model

  self.table_name = 'tdb.events'
end

class HypertableWithoutRetentionPolicy < ActiveRecord::Base
  include Timescaledb::Rails::Model

  self.table_name = 'payloads'
end
# rubocop:enable Rails/ApplicationRecord
