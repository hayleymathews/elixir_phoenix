defmodule Catcasts.Multimedia.Video do
  use Ecto.Schema
  use Rummage.Ecto
  import Ecto.Changeset

  schema "videos" do
    field :duration, :string
    field :thumbnail, :string
    field :title, :string
    field :video_id, :string
    field :view_count, :integer
    belongs_to(:user, Catcasts.User)

    timestamps()
  end

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [:video_id, :title, :duration, :thumbnail, :view_count])
    |> validate_required([:video_id, :title, :duration, :thumbnail, :view_count])
    |> unique_constraint(:video_id)
  end
end
