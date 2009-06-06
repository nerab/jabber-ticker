require 'jabber/bot'

#
#
#
class TickerBot
  def initialize(cfg, tickerListLoader)
    @shutdown = false
    @tickerListLoader = tickerListLoader
    @tickerLoaders = {}
    @bot = Jabber::Bot.new(cfg)

    # Beware! If the description contains non-ASCII characters, this source file must be UTF-8 encoded, otherwise Jabber chokes and
    # the client disconnects without an error message

		@bot.add_command(
			:syntax      => 'verlauf',
			:description => "Sende 'verlauf <zahl>', um den bisherigen Spielverlauf für den Ticker <zahl> zu sehen.",
		  :regex       => /^verlauf\s+(\d*)?$/,
			:is_public   => true
		){|sender, message|
		  begin
		    ticker = Ticker.find_by_tid(message)
        if ticker == nil
	        "Ticker #{message} existiert nicht."
	      else
	        # first, refresh ticker
          find_or_create_loader(ticker).refresh!

          subscriber = Subscriber.find_or_create_by_jid(sender)
	        ticker.ticker_lines.collect{|line| "\n#{line}" if subscriber.status == 'normal' || (subscriber.status == 'wichtig' && line.severity > 0)}
	      end
      rescue
        LOG.error($!)
        "Fehler: #{$!}"
      end
		}

		@bot.add_command(
			:syntax      => 'wichtig',
			:description => "Sende 'wichtig', um nur bei Ereignissen (Tore, Wechsel, gelbe und rote Karten) informiert zu werden. Gilt auch für das Kommando 'verlauf'.",
	    :regex       => /^wichtig$/,
	    :is_public   => true
		  ){|sender, message|
		    begin
			    subscriber = Subscriber.find_or_create_by_jid(sender)
	        subscriber.status = 'wichtig'
	        subscriber.save!
	        "OK"
        rescue
          LOG.error($!)
          "Fehler: #{$!}"
        end
		  }

		@bot.add_command(
			:syntax      => 'normal',
			:description => "Sende 'normal', um alle Ereignisse zu erhalten.",
	    :regex       => /^normal$/,
	    :is_public   => true
		){|sender, message|
		  begin
	      subscriber = Subscriber.find_or_create_by_jid(sender)
	      subscriber.status = 'normal'
	      subscriber.save!
	      "OK"
      rescue
        LOG.error($!)
        "Fehler: #{$!}"
      end
		}

		@bot.add_command(
			:syntax      => 'status',
			:description => "Sende 'status', um Deine momentane Einstellung zu erhalten.",
	    :regex       => /^status$/,
	    :is_public   => true
		){|sender, message|
		  begin
			  Subscriber.find_or_create_by_jid(sender).status
      rescue
        LOG.error($!)
        "Fehler: #{$!}"
      end
		}

		@bot.add_command(
			:syntax      => 'abos',
			:description => "Zeige alle Deine abonnierten Ticker an.",
	    :regex       => /^abos$/,
	    :is_public   => true
		){|sender, message|
		  begin
		    subscriber = Subscriber.find_or_create_by_jid(sender)

	      if subscriber.tickers.empty?
	        "Du hast keine Ticker abonniert."
			  else
		      subscribed_tickers = ""
		      subscriber.tickers.each{|subscribed|
				    subscribed_tickers << "\n"
		        subscribed_tickers << subscribed.to_s
				  }
				  "Du hast folgende Ticker abonniert: #{subscribed_tickers}"
			  end
      rescue
        LOG.error($!)
        "Fehler: #{$!}"
      end
		}

		@bot.add_command(
			:syntax      => 'abo <zahl>',
			:description => "Gib die Nummer eines Tickers mit, um Nachrichten dieses Tickers zu erhalten.",
	    :regex       => /^abo\s+(\d*)?$/,
	    :is_public   => true
		){|sender, message|
		  begin
		    ticker = Ticker.find_by_tid(message)
		    if ticker == nil
			    "Ticker #{message} existiert nicht."
			  else
			    subscriber = Subscriber.find_or_create_by_jid(sender)
          # TODO Throw error on attempt to subscribe the same ticker twice
          #if subscriber.tickers.find_by_tid(message).size > 0
		      #  "Du hattest den Ticker #{message} bereits abonniert."
		      #else
		        Subscription.create!(:subscriber => subscriber, :ticker => ticker)
		        "OK"
		      #end
	      end
      rescue
        LOG.error($!)
        "Fehler: #{$!}"
		  end
		}

		@bot.add_command(
			:syntax      => 'stop <zahl>',
			:description => "Gib die Nummer eines Tickers mit, um keine Nachrichten dieses Tickers mehr zu erhalten.",
	    :regex       => /^stop\s+(\d*)?$/,
	    :is_public   => true
		){|sender, message|
		  begin
		    Subscription.delete(Subscription.find(:all, :conditions => {:subscriber_id => Subscriber.find_or_create_by_jid(sender), :ticker_id => Ticker.find_by_tid(message.to_i)}).first)
        "OK"
      rescue
        LOG.error($!)
        "Fehler: #{$!}"
      end
		}

		@bot.add_command(
			:syntax      => 'liste',
			:description => "Sende 'liste', um eine Liste aller bekannten Ticker zu erhalten.",
	    :regex       => /^liste$/,
	    :is_public   => true
		){
		  begin
			  @tickerListLoader.refresh!
			  tickers = Ticker.find(:all, :order => :date).collect{|ticker| "\n#{ticker}"}
			  "Folgende Ticker sind verfügbar: #{tickers}"
      rescue
        LOG.error($!)
        "Fehler: #{$!}"
      end
		}

		@bot.add_command(
			:syntax      => 'stand',
			:description => "Sende 'stand', um den Spielstand des aktuellen Spiels / der aktuellen Spiele zu erfahren.",
		  :regex       => /^stand$/,
			:is_public   => true
		){
		  begin
			  "not yet implemented"
      rescue
        LOG.error($!)
        "Fehler: #{$!}"
      end
		}

		@bot.add_command(
			:syntax      => 'stand <zahl>',
			:description => "Sende 'stand <zahl>', um den Spielstand des Spiels <zahl> zu erfahren.",
	    :regex       => /^standp\s+(\d*)?$/,
			:is_public   => true
		){
		  begin
			  "not yet implemented"
      rescue
        LOG.error($!)
        "Fehler: #{$!}"
      end
		}

		@bot.add_command(
			:syntax      => 'broadcast',
			:description => "broadcast a message to all buddies (subscribers)",
		  :regex       => /^broadcast\s+.+$/,
			:is_public   => false
		){|sender, message|
		  begin
			  @bot.jabber.roster.items.values.each{|buddy|
			    @bot.jabber.deliver(buddy.jid.to_s, message) if buddy.online?
			  }
			  nil
      rescue
        LOG.error($!)
        "Fehler: #{$!}"
      end
		}

		@bot.add_command(
			:syntax      => 'stats',
			:description => "returns statistics",
		  :regex       => /^stats$/,
			:is_public   => false
		){|sender, message|
		  begin
		    "#{Subscriber.count} subscribers have #{Subscription.count} subscriptions to #{Ticker.count} tickers"
      rescue
        LOG.error($!)
        "Fehler: #{$!}"
      end
		}

		@bot.add_command(
			:syntax      => 'shutdown',
			:description => "shut the bot down. THERE IS NO WAY TO START IT AGAIN FROM REMOTE!",
		  :regex       => /^shutdown$/,
			:is_public   => false
		){|sender, message|
		  begin
			  disconnect
			  nil
      rescue
        LOG.error($!)
        "Fehler: #{$!}"
      end
		}

		@bot.add_command(
			:syntax      => 'r',
			:description => "Sende 'r <command>', um ein Ruby command auszuführen.",
	    :regex       => /^r\s+.+$/,
	    :is_public   => false
		){|sender, message|
		  begin
		    eval(message.gsub(/&apos;/, "'").gsub(/&quot;/, "\"").gsub(/&lt;/, "<").gsub(/&gt;/, ">"))
      rescue
        LOG.error($!)
        "Fehler: #{$!.message}"
      end
		}

  end

  def connect
    # update loop for all tickers that have at least one subsriber
    # TODO that is not a master and is actually online
    @ticker_thread = Thread.new{
      while not @shutdown do
        Subscription.find(:all, :group => :ticker_id).each{|subscription|
          find_or_create_loader(subscription.ticker).refresh! # re-reading in a thread breaks sqlite for some reason :-(
	      }

        sleep 10
	    end
    }

    # refresh list of tickers
    @ticker_list_thread = Thread.new{
      while not @shutdown do
        @tickerListLoader.refresh!

        status = ""

        # Announce currently running game(s) as IM status
				LOG.debug("Checking for currently running games:")
        running_games = Ticker.all.select{|t| t.running?}

        running_games.each{|t|
          LOG.debug(t)
          status << "#{t.parties}: #{t.score}"
          status << "; " if t != running_games.last
        }

        # Announce today's game(s) as IM status if none is running right now
        LOG.debug("Checking for upcoming games:")
        if running_games.empty? # no games currently running
          # TODO Improve the efficiency of this filter by storing date and time of the game separately
          # and use proper AR finders (find_by_date)
          todays_games = Ticker.all.select{|t| t.date.to_date == DateTime.now.to_date}
          LOG.debug("Today's games are: #{todays_games}")

          if not todays_games.nil?
	          status << "ab " if not todays_games.empty?
	          todays_games.each{|t|
		          status << "#{t.date.hour}: #{t.date.min} #{t.parties}"
		          status << "; " if t != todays_games.last
		        }
          end
        end

        # Reset the IM status to some standard text if there is no game right now
        @bot.status = status if @bot.jabber

        sleep 1.minute.to_i # should really be one hour
	    end
    }

    # wait for bot to connect to jabber
    Thread.new{
      10.downto 1 do
        if @bot.jabber
            @bot.jabber.accept_subscriptions = true
            break
        end
        sleep 1
      end
    }

    @bot.connect # this method is blocking ...
  end

  def disconnect
    @shutdown = true
    @ticker_thread.join(10)
    @bot.disconnect
  end

  # Ticker callback. Called upon a new ticker line.
	def on_ticker_line(t_line)
    # Select those users that have a subscription to the ticker of the passed ticker_line, and whose status matches the message severity
	  t_line.ticker.subscribers.select{|s| s.status == 'normal' || (s.status == 'wichtig' && t_line.severity > 0)}.each{|subscriber|
	    if @bot.jabber
        if @bot.jabber.roster.items[subscriber.jid] != nil # TODO && @bot.jabber.roster.items[subscriber.jid].online?
          LOG.debug "delivering update to #{subscriber.jid}: #{t_line.to_s}"
          @bot.deliver(subscriber.jid, t_line.to_s)
        end
	    end
	  }
  end

  # Ticker callback. Called upon a new score.
	def on_score(score)
    if @bot.jabber && score.ticker.running?
      @bot.status = score
    end
  end

private
  #
  # returns true if the subscriber's preference matches the line's severity
  #
  def wants_message?(sender, line)
    subscriber = Subscriber.find_or_create_by_jid(sender)
    (subscriber.status == 'normal' || (subscriber.status == 'wichtig' && line.severity > 0))
  end

  def find_or_create_loader(ticker)
    loader = @tickerLoaders[ticker.tid]

    if loader == nil
      # If a loader does not exist yet for this ticker, create one.
      loader = TickerLoader.new(ticker)
      loader.subscribe(self) # Register this bot as a listener to the ticker updates
      @tickerLoaders[ticker.tid] = loader
    end

    loader
  end

end
