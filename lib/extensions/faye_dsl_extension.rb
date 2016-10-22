module FayeDslExtension
  def channel_part(part)
    if subscribing? and message['subscription']
      @parts ||= message['subscription'].split('/')
      @parts[part]
    end
  end

  def current_user
    current_user = nil
    client_id = message['clientId']
    if client_id and ClientsStorage.client client_id
      current_user = User.find_by_id ClientsStorage.user_id(client_id)
    end

    current_user
  end

  def current_user=(user_id)
    client_id = message['clientId']
    ClientsStorage.add_client client_id, user_id if client_id
  end

  # @todo Add Redis (or something like that) support
  class ClientsStorage
    class << self
      def add_client(client_id, user_id, lifetime = 6.hours)
        # Delete current client record
        clients.delete_if do |value|
          value[:client_id] == client_id
        end

        clients << { client_id: client_id,
                     user_id: user_id,
                     expire: Time.now + lifetime }
      end

      def client(client_id)
        clients.detect do |element|
          element[:client_id] == client_id and element[:expire] > Time.now
        end
      end

      def user_id(client_id)
        client(client_id)[:user_id]
      end

      protected
      def clients
        @clients ||= []
      end

      def clients=(value)
        @clients = value
      end
    end
  end
end

# Include the extension
FayeRails::Filter::DSL.send(:include, FayeDslExtension)