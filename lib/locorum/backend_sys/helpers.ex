defmodule Locorum.BackendSys.Helpers do
  use Phoenix.Channel
  require Logger

  def init_json(url, header, socket) do
    set_header(url, header)
    |> init_frontend(socket)
    |> fetch_json
  end

  def init_html(url, header, socket) do
    set_header(url, header)
    |> init_frontend(socket)
    |> fetch_html
  end

  def send_results(results, header, socket, query) do
    rate_result(results, query)
    |> broadcast_results(header, socket)
  end

  # TODO allow for apostrophe to not be replaced
  def convert_to_utf(text, output) do
    String.downcase(text)
    |> String.replace(~r/'/, "")
    |> String.replace(~r/[^\w-]+/, output)
  end

  defp rate_result(results, _query) do
    for result <- results do
      Map.put(result, :rating, "100")
    end
  end

  defp broadcast_results(results, header, socket) do
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
    broadcast! socket, "loaded_results", %{
      backend: header.backend,
      backend_str: header.backend_str
    }
  end

  defp set_header(url, header) do
    Map.put(header, :url_search, url)
  end

  defp fetch_json(url) do
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

  defp fetch_html(url) do
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

  # defp make_message(results, query_ref, header) do
  #   {:results, query_ref, header, results}
  # end

  defp init_frontend(header, socket) do
    broadcast! socket, "backend", %{
      backend: header.backend,
      backend_str: header.backend_str,
      backend_url: header.url_site,
      results_url: header.url_search
    }
    header.url_search
  end
end
