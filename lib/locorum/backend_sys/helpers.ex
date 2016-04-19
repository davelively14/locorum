defmodule Locorum.BackendSys.Helpers do
  require Logger
  use Phoenix.Channel

  def fetch_json(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: json}} ->
        json
      {:ok, %HTTPoison.Response{status_code: 301}} ->
        Logger.error("301 redirect, #{__MODULE__} backend, #{inspect url}. Change get call to url, [], follow_redirect: true")
        {:error, "301"}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.error("404 redirect, #{__MODULE__} backend, #{inspect url}")
        {:error, "404"}
      {:ok, %HTTPoison.Response{status_code: 403}} ->
        Logger.error("403 redirect, #{__MODULE__} backend, #{inspect url}")
        {:error, "403"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTPoison error: #{inspect reason}, #{__MODULE__} backend, #{inspect url}")
        {:error, reason}
    end
  end

  def fetch_html(url) do
    case HTTPoison.get(url, [], follow_redirect: true) do
      {:ok, %HTTPoison.Response{status_code: 200, body: html}} ->
        html
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.error("404 redirect, #{__MODULE__} backend, #{inspect url}")
        {:error, "404"}
      {:ok, %HTTPoison.Response{status_code: 403}} ->
        Logger.error("403 redirect, #{__MODULE__} backend, #{inspect url}")
        {:error, "403"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTPoison error: #{inspect reason}, #{__MODULE__} backend, #{inspect url}")
        {:error, reason}
    end
  end

  # TODO handle the nil results on the front end
  def make_message(nil, query_ref, _header, url), do: {:ignore, query_ref, url}
  def make_message(results, query_ref, header, url) do
    header = Map.put(header, :url_search, url)
    {:results, query_ref, header, results}
  end

  def send_results(message, socket) do
    {_, _, header, results} = message
    broadcast! socket, "backend", %{
      backend: header.backend,
      backend_str: header.backend_str,
      backend_url: header.url_site,
      results_url: header.url_search
    }
    if results != [] do
      for result <- results do
        broadcast! socket, "result", %{
          backend: header.backend,
          biz: result.biz,
          address: result.address,
          city: result.city,
          state: result.state,
          zip: result.zip
        }
      end
    else
      broadcast! socket, "no_result", %{
        backend: header.backend
      }
    end
  end
end
