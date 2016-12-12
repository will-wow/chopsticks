defmodule Mix.Tasks.MyApp.Digest do
  use Mix.Task

  def run(args) do
    Mix.Shell.IO.cmd "npm run deploy"
    :ok = Mix.Tasks.Phoenix.Digest.run(args)
  end
end