defmodule RoadtripWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use RoadtripWeb, :controller
      use RoadtripWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: RoadtripWeb

      import Plug.Conn
      import RoadtripWeb.Gettext
      alias RoadtripWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/roadtrip_web/templates",
        namespace: RoadtripWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {RoadtripWeb.LayoutView, "live.html"}

      unquote(view_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import RoadtripWeb.Gettext
    end
  end

  @doc """
  Creates an HTML `<select>` element with all of the available timezone
  identifiers.
  """
  def tz_select(form, field, opts \\ []) do
    groups = Tzdata.zone_lists_grouped()

    renamed = [
      "Greenwich Offsets": groups[:etcetera],
      Africa: groups[:africa],
      Antarctica: groups[:antarctica],
      Asia: groups[:asia],
      Australasia: groups[:australasia],
      Europe: groups[:europe],
      "North America": groups[:northamerica],
      "South America": groups[:southamerica],
      Renamed: groups[:backward]
    ]

    Phoenix.HTML.Form.select(form, field, renamed, opts)
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView and .heex helpers (live_render, live_patch, <.form>, etc)
      import Phoenix.LiveView.Helpers

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import RoadtripWeb.ErrorHelpers
      import RoadtripWeb.Gettext
      alias RoadtripWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
