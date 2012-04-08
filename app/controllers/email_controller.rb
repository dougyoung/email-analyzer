require 'gmail'

class EmailController < AuthenticationController
  respond_to :json

  def index
    respond_with(all_senders_to_email_counts.as_json)
  end

  private

  def all_senders_to_email_counts
    senders_to_email_counts = {}

    @gmail.imap.uid_fetch(uids, "ENVELOPE").each do |envelope|
      envelope.attr["ENVELOPE"].from.each do |from|
        from_as_string = from_as_string(from)
        sender_hash = senders_to_email_counts[from_as_string]
        if sender_hash.nil?
          senders_to_email_counts[from_as_string] = 1
        else
          senders_to_email_counts[from_as_string] += 1
        end
      end
    end

    senders_to_email_counts
  end

  def from_as_string(from)
    from_as_string = ""
    unless from.name.blank? || from.name == "#{from.mailbox}@#{from.host}"
      from_as_string = "#{from.name} "
    end
    from_as_string += "<#{from.mailbox}@#{from.host}>"
    from_as_string
  end

  def uids
    uids = []
    @gmail.inbox.emails.each do |email|
      uids << email.uid
    end
    uids
  end
end