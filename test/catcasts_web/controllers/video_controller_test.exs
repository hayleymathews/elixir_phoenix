defmodule CatcastsWeb.VideoControllerTest do
  use CatcastsWeb.ConnCase

  alias Catcasts.{Multimedia, Repo, User}

  @create_attrs %{video_id: "https://www.youtube.com/watch?v=wZZ7oFKsKzY"}
  @invalid_attrs %{video_id: ""}

  def fixture(:video) do
    {:ok, video} = Multimedia.create_video(@create_attrs)
    video
  end

  def youtube_video_fixture(attrs \\ %{}) do
    user = user_fixture()

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

  describe "index" do
    test "lists all videos", %{conn: conn} do
      conn = get(conn, Routes.video_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Videos"
    end
  end

  describe "new video" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.video_path(conn, :new))
      assert html_response(conn, 200) =~ "New Video"
    end
  end

  describe "create video" do
    test "redirects to show when data is valid", %{conn: conn} do
      user = user_fixture()
      conn =
        conn
        |> assign(:user, user)
        |> post(Routes.video_path(conn, :create), video: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.video_path(conn, :show, id)
      assert html_response(conn, 302) =~
        "<html><body>You are being <a href=\"/videos/#{id}\">redirected</a>.</body></html>"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = user_fixture()
      conn =
        conn
        |> assign(:user, user)
        |> post(Routes.video_path(conn, :create), video: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Video"
    end
  end

  describe "delete video" do

    test "deletes chosen video", %{conn: conn} do
      video = youtube_video_fixture()
      conn = delete(conn, Routes.video_path(conn, :delete, video))
      assert redirected_to(conn) == Routes.video_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.video_path(conn, :show, video))
      end
    end
  end

  defp create_video(_) do
    video = fixture(:video)
    {:ok, video: video}
  end
end
