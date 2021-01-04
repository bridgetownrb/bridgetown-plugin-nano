class TestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Rails.logger.info "TestJob successfully run! Args: #{args}"
  end
end
