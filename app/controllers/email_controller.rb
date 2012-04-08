require 'gmail'

class EmailController < AuthenticationController

  def index
    @senders_to_email_counts = senders_to_email_counts()
    @senders_to_email_counts = sort(senders_to_email_counts)
    @total_count = total_count
    respond_to do |format|
      format.html
      format.json { render :json => @senders_to_email_counts.as_json }
    end
  end

  private

  def from(sender)
    from = ""
    unless sender.name.blank? || sender.name.downcase == "#{sender.mailbox.downcase}@#{sender.host.downcase}"
      from = "#{sender.name} "
    end
    from += "<#{sender.mailbox.downcase}@#{sender.host.downcase}>"
    from
  end

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

  def sort(senders_to_email_counts)
    ActiveSupport::OrderedHash[senders_to_email_counts.sort_by { |key, value| value }.reverse]
  end

  def total_count
    @gmail.inbox.emails.count
  end

  def uids
    uids = []
    @gmail.inbox.emails.each do |email|
      uids << email.uid
    end
    uids
  end
end