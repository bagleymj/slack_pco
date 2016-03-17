require './lib/slack_client.rb'

class Test
  def initialize
    client = SlackClient.new
    threads = []
    threads << Thread.new{
      client.connect
    }
    threads << Thread.new{
      i = 0
      until i == 10
        i += 1
        ws = client.get_socket
        ws.send "Yo"
        puts "Sent."
        sleep 5
      end
    }
    threads.each do |thread|
      thread.join
    end
  end
end
