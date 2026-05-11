defmodule AbsensiDigitalWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use AbsensiDigitalWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="flex h-screen bg-brand-background font-brand text-brand-on-surface antialiased overflow-hidden">
      <!-- Sidebar -->
      <aside class="w-64 bg-brand-surface-container-low border-r border-brand-outline-variant flex flex-col hidden md:flex">
        <div class="p-8">
          <a href="/" class="flex items-center gap-3 group">
            <div class="bg-brand-primary p-2 rounded-brand-md shadow-xl shadow-brand-primary/20 transition-transform group-hover:scale-110">
              <.icon name="hero-academic-cap" class="size-6 text-brand-on-primary" />
            </div>
            <span class="text-xl font-black tracking-tight bg-clip-text text-transparent bg-gradient-to-r from-brand-primary to-brand-secondary">
              ABSENSI
            </span>
          </a>
        </div>

        <nav class="flex-1 px-4 space-y-1.5 py-4">
          <div class="text-[10px] uppercase tracking-widest text-brand-on-surface-variant font-black px-4 mb-2">
            Main Menu
          </div>
          <.nav_link navigate={~p"/"} icon="hero-squares-2x2" active={@current_scope == :dashboard}>
            Dashboard
          </.nav_link>
          <.nav_link navigate={~p"/student"} icon="hero-users" active={@current_scope == :student}>
            Students
          </.nav_link>
          <.nav_link navigate={~p"/scan"} icon="hero-qr-code" active={@current_scope == :scan}>
            Scan QR
          </.nav_link>
        </nav>

        <div class="p-6 border-t border-brand-outline-variant bg-brand-surface-container-low/50">
          <div class="flex items-center gap-4 mb-4">
            <div class="size-10 rounded-brand-md bg-gradient-to-tr from-brand-primary to-brand-secondary flex items-center justify-center text-brand-on-primary font-black shadow-lg shadow-brand-primary/20">
              A
            </div>
            <div>
              <p class="text-sm font-black tracking-tight">Admin</p>
              <p class="text-[10px] text-brand-on-surface-variant font-bold uppercase tracking-widest">
                Online
              </p>
            </div>
          </div>
          <.theme_toggle />
        </div>
      </aside>
      
    <!-- Main Content -->
      <div class="flex-1 flex flex-col overflow-hidden">
        <!-- Topbar (Mobile) -->
        <header class="md:hidden flex items-center justify-between p-4 bg-brand-surface/80 backdrop-blur-md border-b border-brand-outline-variant sticky top-0 z-40">
          <a href="/" class="flex items-center gap-2">
            <div class="bg-brand-primary p-1.5 rounded-brand-sm">
              <.icon name="hero-academic-cap" class="size-5 text-brand-on-primary" />
            </div>
            <span class="font-black tracking-tighter text-lg bg-clip-text text-transparent bg-gradient-to-r from-brand-primary to-brand-secondary">
              ABSENSI
            </span>
          </a>
          <div class="flex items-center gap-3">
            <.theme_toggle />
            <button class="p-2 rounded-brand-sm bg-brand-surface-container border border-brand-outline-variant">
              <.icon name="hero-bars-3" class="size-6 text-brand-on-surface" />
            </button>
          </div>
        </header>

        <main class="flex-1 overflow-y-auto p-6 lg:p-12 bg-brand-background">
          <div class="max-w-[1280px] mx-auto">
            {render_slot(@inner_block)}
          </div>
        </main>
      </div>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  attr :navigate, :string, required: true
  attr :icon, :string, required: true
  attr :active, :boolean, default: false
  slot :inner_block, required: true

  defp nav_link(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class={[
        "flex items-center gap-3 px-4 py-3 rounded-brand-md transition-all duration-300 group",
        if(@active,
          do:
            "bg-brand-primary text-brand-on-primary shadow-lg shadow-brand-primary/25 translate-x-1",
          else:
            "hover:bg-brand-surface-container text-brand-on-surface-variant hover:text-brand-on-surface hover:translate-x-1"
        )
      ]}
    >
      <div class={[
        "p-1.5 rounded-brand-sm transition-colors duration-300",
        if(@active,
          do: "bg-brand-on-primary/20",
          else:
            "bg-brand-surface-container-high group-hover:bg-brand-primary/10 group-hover:text-brand-primary"
        )
      ]}>
        <.icon name={@icon} class="size-5 transition-transform duration-300 group-hover:scale-110" />
      </div>
      <span class="font-bold text-sm tracking-tight">{render_slot(@inner_block)}</span>
    </.link>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="relative flex flex-row items-center border border-brand-outline-variant bg-brand-surface-container rounded-brand-full p-1">
      <div class="absolute w-1/3 h-[calc(100%-8px)] rounded-brand-full bg-brand-surface-container-lowest shadow-sm left-1 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-all" />

      <button
        class="flex justify-center p-2 cursor-pointer w-1/3 z-10"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon
          name="hero-computer-desktop-micro"
          class="size-4 text-brand-on-surface-variant hover:text-brand-on-surface transition-colors"
        />
      </button>

      <button
        class="flex justify-center p-2 cursor-pointer w-1/3 z-10"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon
          name="hero-sun-micro"
          class="size-4 text-brand-on-surface-variant hover:text-brand-on-surface transition-colors"
        />
      </button>

      <button
        class="flex justify-center p-2 cursor-pointer w-1/3 z-10"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon
          name="hero-moon-micro"
          class="size-4 text-brand-on-surface-variant hover:text-brand-on-surface transition-colors"
        />
      </button>
    </div>
    """
  end
end
