defmodule MoveE2eTestTool.Repo do
  use Ecto.Repo,
    otp_app: :move_e2e_test_tool,
    adapter: Ecto.Adapters.Postgres
end
