require 'gmail'

class EmailController < AuthenticationController
  respond_to :json

  def index
    senders_to_email_counts = senders_to_email_counts()
    senders_to_email_counts = sort(senders_to_email_counts)
    respond_with(senders_to_email_counts.as_json)
  end

  private

  def senders_to_email_counts
    senders_to_email_counts = {}

    @gmail.imap.uid_fetch(uids, "ENVELOPE").each do |envelope|
      envelope.attr["ENVELOPE"].from.each do |sender|
        from = from(sender)
        sender_hash = senders_to_email_counts[from]
        if sender_hash.nil?
          senders_to_email_counts[from] = 1
        else
          senders_to_email_counts[from] += 1
        end
      end
    end

    senders_to_email_counts
  end

  def from(sender)
    from = ""
    unless sender.name.blank? || sender.name == "#{sender.mailbox}@#{sender.host}"
      from = "#{sender.name} "
    end
    from += "<#{sender.mailbox}@#{sender.host}>"
    from
  end

  def sort(senders_to_email_counts)
    ActiveSupport::OrderedHash[senders_to_email_counts.sort_by { |key, value| value }.reverse]
  end

  def uids
    uids = []
    @gmail.inbox.emails.each do |email|
      uids << email.uid
    end
    uids
  end
end