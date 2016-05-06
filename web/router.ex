defmodule Locorum.Router do
  use Locorum.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Locorum.Auth, repo: Locorum.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Locorum do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/user", UserController, only: [:new, :create, :index, :show, :delete]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  scope "/manage", Locorum do
    pipe_through [:browser, :authenticate_user]

    resources "/search", SearchController
    resources "/project", ProjectController
    resources "/upload", CSVController, only: [:create]
    get "/results/:id", ResultsController, :show
    get "/results/project/:id", ResultsController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Locorum do
  #   pipe_through :api
  # end
end
