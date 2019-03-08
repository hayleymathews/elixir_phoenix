defmodule CatcastsWeb.VideoController do
  use CatcastsWeb, :controller

  alias Catcasts.Multimedia
  alias Catcasts.Multimedia.{YoutubeData, Video}

  plug :check_video_owner when action in [:delete]

  def index(conn, _params) do
    videos = Multimedia.list_videos()
    render(conn, "index.html", videos: videos)
  end

  def new(conn, _params) do
    changeset = Multimedia.change_video(%Video{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"video" => video_params}) do
    case YoutubeData.has_valid_url?(video_params) do
      nil ->
        changeset = Video.changeset(%Video{}, video_params)

        conn
        |> put_flash(:error, "Invalid YouTube URL")
        |> render("new.html", changeset: changeset)

      url_info ->
        [video, message] = YoutubeData.insert_or_get_video(url_info, conn.assigns.user)

        conn
        |> put_flash(:info, message)
        |> redirect(to: Routes.video_path(conn, :show, video))
    end
  end

  def show(conn, %{"id" => id}) do
    video = Multimedia.get_video!(id)
    render(conn, "show.html", video: video)
  end

  def delete(conn, %{"id" => id}) do
    video = Multimedia.get_video!(id)
    {:ok, _video} = Multimedia.delete_video(video)

    conn
    |> put_flash(:info, "Video deleted successfully.")
    |> redirect(to: Routes.video_path(conn, :index))
  end

  defp check_video_owner(conn, _params) do
    %{params: %{"id" => video_id}} = conn

    video = Catcasts.Repo.get(Video, video_id)

    case video.user_id == conn.assigns.user.id do
      true ->
        conn

      false ->
        conn
        |> put_flash(:error, "You cannot do that")
        |> redirect(to: Routes.video_path(conn, :show, video))
        |> halt()
    end
  end
end
