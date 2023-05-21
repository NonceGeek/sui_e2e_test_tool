defmodule MoveE2eTestToolWeb.ScriptLive.Index do
  use MoveE2eTestToolWeb, :live_view

  alias MoveE2eTestTool.Scripts
  alias MoveE2eTestTool.Scripts.Script
  alias Phoenix.PubSub
  @impl true
  def mount(_params, _session, socket) do
    change_set = MoveE2eTestTool.Scripts.change_script(Scripts.get_script(1) || %Script{})
    form = to_form(change_set, as: "script")
    PubSub.subscribe(MoveE2eTestTool.PubSub, "task")
    {:ok,
     stream(socket, :scripts, Scripts.list_scripts())
     |> assign(:form, form)
     |> assign(:log, nil)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end
  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Scripts")
    |> assign(:script, nil)
  end

  @impl true
  def handle_info({MoveE2eTestToolWeb.ScriptLive.FormComponent, {:saved, script}}, socket) do
    {:noreply, stream_insert(socket, :scripts, script)}
  end

  @impl true
  def handle_info({:append_log, log}, socket) do
    {:noreply, update(socket, :log, fn x -> "#{x}<br>#{log}" end)}
   end
  @impl true
  def handle_info(:clear_log, socket) do
    {:noreply, update(socket, :log, fn _x -> "....." end)}
   end
  @impl true
  def handle_event("on_submit", %{"script" => %{"content" => content, "name" => name}}, socket) do
    case Scripts.get_script(1) do
      nil ->
        Scripts.create_script(%{content: content, name: name})

      script ->
        Scripts.update_script(script, %{content: content, name: name})
    end
    Phoenix.PubSub.broadcast(MoveE2eTestTool.PubSub, "task", :clear_log)
    spawn(fn  ->
    :timer.sleep(500)
    try do
    MoveE2ETestTool.CliParser.run(content)
    catch r,x ->
    Phoenix.PubSub.broadcast(MoveE2eTestTool.PubSub, "task", {:append_log, "#{inspect(r)}=>#{inspect(x)}"})
    end
    end)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    script = Scripts.get_script!(id)
    {:ok, _} = Scripts.delete_script(script)

    {:noreply, stream_delete(socket, :scripts, script)}
  end
end
