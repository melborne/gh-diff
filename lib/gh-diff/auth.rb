module GhDiff
  class Auth
    def self.[](opts={})
      new(username:opts[:username],
          password:opts[:password],
          token:opts[:token]).login
    end

    def initialize(username:nil, password:nil, token:nil)
      @username = username
      @password = password
      @token = token
      @@login = nil
    end

    def login
      if @token
        Octokit.configure { |c| c.access_token = @token }
      else
        Octokit.configure { |c| c.login = @username; c.password = @password }
      end
      @@login = Octokit.user
    end
  end
end
