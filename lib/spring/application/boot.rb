# This is necessary for the terminal to work correctly when we reopen stdin.
Process.setsid

require "spring/application"

app = Spring::Application.new(
  UNIXSocket.for_fd(3),
  Spring::JSON.load(ENV.delete("SPRING_ORIGINAL_ENV").dup),
  Spring::Env.new(log_file: IO.for_fd(4))
)

Signal.trap("TERM") { app.terminate }

Spring::ProcessTitleUpdater.run do |distance|
  stats = [
    app.app_name,
    "started #{distance} ago",
    "#{app.app_context} context",
    "#{app.app_env} mode",
  ]
  "spring app    | #{stats.join(" | ")}"
end

app.eager_preload if ENV.delete("SPRING_PRELOAD") == "1"
app.run
