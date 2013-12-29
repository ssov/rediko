require "rediko/version"
require "net/http"
require "uri"
require "base64"

module Rediko
  PLAYER="http://radiko.jp/player/swf/player_4.0.0.00.swf"

  class << self
    def dump(options)
      channel = options[:channel]
      time = options[:time]
      output = options[:output]

      download_player
      get_key
      authtoken = auth

      now = Time.now
      output = "#{output}/#{channel}-#{now.strftime("%Y-%m-%d-%H-%M")}.flv"

      a, b, c, d = rtmp_url(channel)
      `rtmpdump -v \
        -r '#{a}://#{b}' \
        --app '#{c}' \
        --playpath '#{d}' \
        -W '#{PLAYER}' \
        -C S:'' -C S:'' -C S:'' -C S:#{authtoken} \
        --live \
        --stop #{time} \
        --flv #{output}`
    end

    def rtmp_url(channel)
      uri = URI.parse("http://radiko.jp/v2/station/stream/#{channel}.xml")
      res = Net::HTTP.get(uri)
      
      res =~ /<item>(.+):\/\/(.+?)\/(.*)\/(.*?)<\/item>/
      return $1, $2, $3, $4
    end

    def auth
      uri = URI.parse("https://radiko.jp/v2/api/auth1_fms")
      header = {
        "X-Radiko-App" => "pc_1",
        "X-Radiko-App-Version" => "2.0.1",
        "X-Radiko-User" => "test-stream",
        "X-Radiko-Device" => "pc"
      }
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      res = https.post(uri.request_uri, "", header)
      raise Exception unless res.code.to_i == 200
      body = res.body

      body =~ /AuthToken=([\w_-]+)/i
      authtoken = $1
      body =~ /KeyOffset=(\d+)/i
      offset = $1.to_i
      body =~ /KeyLength=(\d+)/i
      length = $1.to_i

      image = File.open("/tmp/key", "rb").read
      partial_key = Base64.encode64(image[offset,length])

      uri = URI.parse("https://radiko.jp/v2/api/auth2_fms")
      header = {
        "X-Radiko-App" => "pc_1",
        "X-Radiko-App-Version" => "2.0.1",
        "X-Radiko-User" => "test-stream",
        "X-Radiko-Device" => "pc",
        "X-Radiko-Authtoken" => authtoken,
        "X-Radiko-Partialkey" => partial_key
      }
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      body = https.post(uri.request_uri, "", header)
      raise Exception unless body.code.to_i == 200

      return authtoken
    end

    def download_player
      uri = URI.parse(PLAYER)
      File.open("/tmp/player.swf", "w") do |f|
        f.puts Net::HTTP.get(uri)
      end
    end

    def get_key
      `swfextract -b 14 /tmp/player.swf -o /tmp/key`
    end
  end
end
