defmodule Catcasts.Multimedia.YoutubeData do
  alias Catcasts.Multimedia.Video
  alias Catcasts.{Multimedia, Repo}

  def has_valid_url?(video_params) do
    Regex.run(
      ~r/(?:youtube\.com\/\S*(?:(?:\/e(?:mbed))?\/|watch\?(?:\S*?&?v\=))|youtu\.be\/)([a-zA-Z0-9_-]{6,11})/,
      video_params["video_id"]
    )
  end

  def insert_or_get_video(url_info, user) do
    video_id = List.last(url_info)

    case Repo.get_by(Video, video_id: video_id) do
      nil ->
        video_data =
          get_json_data(video_id)
          |> decode_json_data()

        duration = get_formatted_time(video_data)

        {:ok, video} =
          Multimedia.create_video(user, %{
            duration: duration,
            thumbnail: video_data.snippet.thumbnails.high.url,
            title: video_data.snippet.title,
            video_id: video_data.id,
            view_count: String.to_integer(video_data.statistics.viewCount)
          })

        [video, "Video created succesfully"]

      video ->
        [video, "Video has already been created"]
    end
  end

  defp get_json_data(video_id) do
    HTTPoison.get!(
      "https://www.googleapis.com/youtube/v3/videos?id=#{video_id}&key=#{
        System.get_env("YOUTUBE_API_KEY")
      }&part=snippet,statistics,contentDetails&fields=items(id,snippet(title,thumbnails(high)),statistics(viewCount),contentDetails(duration))"
    )
  end

  defp decode_json_data(json_data) do
    %{items: [items]} = Poison.decode!(json_data.body, keys: :atoms)
    items
  end

  defp get_formatted_time(video_data) do
    duration = tl(Regex.run(~r/PT(\d+H)?(\d+M)?(\d+S)?/, video_data.contentDetails.duration))

    [hours, minutes, seconds] =
      for x <- duration, do: hd(Regex.run(~r{\d+}, x) || ["0"]) |> String.to_integer()

    {_status, time} = Time.new(hours, minutes, seconds)
    Time.to_string(time)
  end
end
