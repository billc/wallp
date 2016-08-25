defmodule Wallp do
  require Logger

  @url "http://magic.wizards.com/en/articles/media/wallpapers"
  
  @user_agent [ {"User-agent", "Anonymous nospam@email.com"}]  

  def run() do
    @url
    |> fetch
    |> parse
    |> process
  end

  defp fetch(url) do
    Logger.debug "Retrieving wallpapers from #{url}"

    url
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  defp handle_response({ :ok, %{status_code: 200, body: body } }) do
    body
  end

  defp handle_response({ _, %{status_code: status_code, body: body } }) do
    Logger.error "Failed to fetch page: status code: #{status_code}, body: #{body}"
    System.halt(2)
  end

  def parse(body) do
    Regex.scan(~r{download="(http[\S]+files/images/wallpaper/[\S]*2560[\S]+.jpg)}, body, capture: :all_but_first)
    |> List.flatten
  end

  def process(locations) do
    Enum.map(locations, &_process(&1))
  end

  defp _process(location) do
    # Fetch image
    %HTTPoison.Response{body: body} = HTTPoison.get!(location)

    # File name to use is the first base path in the URI location
    [file_name | _] = URI.path_to_segments(location)

    # Save image to Downloads folder by file name
    Logger.info("Downloading #{file_name}")
    File.write!("/Users/billc/Downloads/#{file_name}", body)
  end
end
