module GhDiff
  class Auth
    def self.[](opts={})
      new(username:opts[:username],
          password:opts[:password],
          oauth:opts[:oauth]).login
    end

    def initialize(username:nil, password:nil, oauth:nil)
      @username = username
      @password = password
      @oauth = oauth
      @@login = nil
    end

    def login
      if @oauth
        Octokit.configure { |c| c.access_token = @oauth }
      else
        Octokit.configure { |c| c.login = @username; c.password = @password }
      end
      @@login = Octokit.user
    end
  end
end
