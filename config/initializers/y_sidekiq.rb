Sidekiq.configure_server do |config|
  config.options[:concurrency] = Setting.concurrency
  config.options[:queues] << :default
  config.options[:queues] << :user
end if Sidekiq.server?
