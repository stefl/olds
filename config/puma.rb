threads Integer(ENV['MIN_THREADS']  || 1), Integer(ENV['MAX_THREADS'] || 16)

workers Integer(ENV['PUMA_WORKERS'] || 3)

rackup DefaultRackup
port ENV['PORT'] || 5000
environment ENV['RACK_ENV'] || 'development'
preload_app!

on_worker_boot do
  ActiveRecord::Base.connection_pool.disconnect!
  # worker specific setup
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end

end