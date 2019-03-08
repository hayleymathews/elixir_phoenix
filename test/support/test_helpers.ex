defmodule Catcasts.TestHelpers do
  alias Catcasts.{Multimedia, Repo, User}

  def user_fixture(attrs \\ %{}) do
    params =
      attrs
      |> Enum.into(%{
        first_name: "Tony",
        last_name: "Stark",
        email: "ironman#{System.unique_integer([:positive])}@example.com",
        token: "2u9dfh7979hfd",
        provider: "google"
      })

    {:ok, user} =
      User.changeset(%User{}, params)
      |> Repo.insert()

    user
  end

  def youtube_video_fixture(%Catcasts.User{} = user, attrs \\ %{}) do
    video_params =
      attrs
      |> Enum.into(%{
        duration: "PT2M2S",
        thumbnail: "https://i.ytimg.com/vi/1rlSjdnAKY4/hqdefault.jpg",
        title: "Super Troopers (2/5) Movie CLIP - The Cat Game (2001) HD",
        video_id: "1rlSjdnAKY4",
        view_count: 658_281
      })

    {:ok, video} = Multimedia.create_video(user, video_params)

    video
  end
end
