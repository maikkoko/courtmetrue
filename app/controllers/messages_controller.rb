class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation

  def index
    @conversations = @mailbox.inbox#.paginate(page: params[:page], per_page: 10)
  end

  def show
    @conversation = current_user.mailbox.conversations.find(params[:id])
    @receipts = @conversation.receipts_for(current_user)
  end

  def new
    @user = User.find(params[:user_id])
  end

  def create
    recipient = User.find(@conversation.to_user)
    receipt = current_user.reply_to_conversation(@conversation, params[:body])
    if recipient.enable_message_notification == true
      MessageMailer.notify_user_about_message(recipient, current_user).deliver
    end  
    redirect_to conversation_path(receipt.conversation)
  end

  private
    def set_conversation
      @conversation = current_user.mailbox.conversations.find(params[:conversation_id])
    end
end