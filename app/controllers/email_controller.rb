require 'gmail'

class EmailController < AuthenticationController

  GROUPING_THRESHOLD_DEFAULT = 5
  
  def index
    @senders_to_email_counts = senders_to_email_counts
    @senders_to_email_counts = group_by_threshold(@senders_to_email_counts, params[:grouping_threshold] || GROUPING_THRESHOLD_DEFAULT)
    @senders_to_email_counts = sort(@senders_to_email_counts)
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

  def group_by_threshold(senders_to_email_counts, threshold)
    others_count = 0
    cloned_senders_to_email_counts = senders_to_email_counts.clone
    senders_to_email_counts.each do |sender, email_count|
      unless email_count.to_i > threshold.to_i
        cloned_senders_to_email_counts.delete(sender)
        others_count += email_count
      end
      cloned_senders_to_email_counts["Others"] = others_count
    end
    cloned_senders_to_email_counts
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