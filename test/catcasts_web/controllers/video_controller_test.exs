defmodule CatcastsWeb.VideoControllerTest do
  use CatcastsWeb.ConnCase

  alias Catcasts.{Multimedia, Repo, User}

  @create_attrs %{video_id: "https://www.youtube.com/watch?v=wZZ7oFKsKzY"}
  @invalid_attrs %{video_id: ""}

  def fixture(:video) do
    {:ok, video} = Multimedia.create_video(@create_attrs)
    video
  end

  describe "index" do
    test "lists all videos", %{conn: conn} do
      conn = get(conn, Routes.video_path(conn, :index))
      assert html_response(conn, 200) =~ "Cat Videos"
    end
  end

  describe "new video" do
    test "renders form", %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> assign(:user, user)
        |> get(Routes.video_path(conn, :new))

      assert html_response(conn, 200) =~ "type=\"submit\">Add video</button>"
    end
  end

  describe "show video" do
    test "shows chosen video", %{conn: conn} do
      user = user_fixture()
      video = youtube_video_fixture(user)
      conn = get(conn, Routes.video_path(conn, :show, video))
      assert html_response(conn, 200) =~ video.title
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

      assert html_response(conn, 200) =~ "type=\"submit\">Add video</button>"
    end
  end

  describe "delete video" do
    test "deletes chosen video", %{conn: conn} do
      user = user_fixture()
      video = youtube_video_fixture(user)

      conn =
        conn
        |> assign(:user, user)
        |> delete(Routes.video_path(conn, :delete, video))

      assert redirected_to(conn) == Routes.video_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.video_path(conn, :show, video))
      end
    end

    test "cannot delete chosen video", %{conn: conn} do
      user1 = user_fixture()
      user2 = user_fixture()
      video = youtube_video_fixture(user2)

      conn =
        conn
        |> assign(:user, user1)
        |> delete(Routes.video_path(conn, :delete, video))

      assert redirected_to(conn) == Routes.video_path(conn, :show, video)

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/videos/#{video.id}\">redirected</a>.</body></html>"
    end
  end

  defp create_video(_) do
    video = fixture(:video)
    {:ok, video: video}
  end
end
