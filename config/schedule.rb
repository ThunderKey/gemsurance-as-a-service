# frozen_string_literal: true

every :monday, at: '2:42 am' do
  rake 'gemsurance:update'
end
