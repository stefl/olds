class SubscribersController < ApplicationController

  def create
    subscriber = Subscriber.new(subscriber_params)
    if subscriber.save
      redirect_to root_path, flash: {notice: "Great to have you with us!"}
    else
      redirect_to root_path, flash: {error: subscriber.errors.full_messages.to_sentence}
    end
  end

  private
    # Using a private method to encapsulate the permissible parameters is just a good pattern
    # since you'll be able to reuse the same permit list between create and update. Also, you
    # can specialize this method with per-user checking of permissible attributes.
    def subscriber_params
      params.require(:subscriber).permit(:email)
    end
end
