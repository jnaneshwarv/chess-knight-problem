module ApplicationHelper
  # Establish Redis connection
  def redis_conn
    Redis.new
  end
end
