class TestMailer < ApplicationMailer
  def greetings
    @name = params[:name]
    mail(to: params[:recipient], subject: "Welcome to My Awesome Site")
  end
end
