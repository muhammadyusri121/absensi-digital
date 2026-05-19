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
      <!-- Sidebar Desktop -->
      <aside class="w-64 bg-brand-surface-container-low border-r-[0.5px] border-brand-outline-variant/60 flex flex-col hidden md:flex">
        <!-- Logo / Branding -->
        <div class="p-6 border-b-[0.5px] border-brand-outline-variant/40">
          <a href="/" class="flex items-center gap-3.5 group">
            <div class="bg-brand-primary p-2.5 rounded-brand-md shadow-xl shadow-brand-primary/20 transition-transform group-hover:scale-105 duration-300">
              <.icon name="hero-academic-cap" class="size-6 text-brand-on-primary" />
            </div>
            <div class="flex flex-col">
              <span class="text-base font-black tracking-tight bg-clip-text text-transparent bg-gradient-to-r from-brand-primary to-brand-secondary leading-tight">
                ABSENSI DIGITAL
              </span>
              <span class="text-[9px] font-extrabold text-brand-on-surface-variant/60 tracking-widest uppercase leading-none mt-0.5">
                School Portal
              </span>
            </div>
          </a>
        </div>

        <!-- Navigation Links -->
        <nav class="flex-1 px-4 space-y-1.5 py-6">
          <div class="text-[10px] uppercase tracking-widest text-brand-on-surface-variant/50 font-black px-4 mb-3">
            Menu Utama
          </div>
          <.nav_link navigate={~p"/"} icon="hero-squares-2x2" active={@current_scope == :dashboard}>
            Dashboard
          </.nav_link>
          <.nav_link href={~p"/student"} icon="hero-users" active={@current_scope == :student}>
            Data Siswa
          </.nav_link>
          <.nav_link navigate={~p"/scan"} icon="hero-qr-code" active={@current_scope == :scan}>
            Scan Presensi
          </.nav_link>
        </nav>

        <!-- Sidebar Footer -->
        <div class="p-5 border-t-[0.5px] border-brand-outline-variant/60 bg-brand-surface-container-low/50">
          <div class="bg-brand-surface-container-lowest border-[0.5px] border-brand-outline-variant/60 rounded-brand-md p-4 mb-4 flex items-center gap-3">
            <div class="size-9 rounded-brand-md bg-gradient-to-tr from-brand-primary to-brand-secondary flex items-center justify-center text-brand-on-primary font-black shadow-md shadow-brand-primary/10">
              A
            </div>
            <div class="flex-1 overflow-hidden">
              <p class="text-xs font-black tracking-tight truncate">Administrator</p>
              <p class="text-[9px] text-brand-success font-bold uppercase tracking-widest truncate">
                Online
              </p>
            </div>
          </div>
          <.theme_toggle />
        </div>
      </aside>

      <!-- Mobile Sidebar Drawer (Slide-out menu) -->
      <div id="mobile-sidebar-drawer" class="fixed inset-0 z-50 hidden" role="dialog" aria-modal="true">
        <!-- Backdrop overlay -->
        <div 
          phx-click={JS.hide(to: "#mobile-sidebar-drawer")}
          class="fixed inset-0 bg-brand-on-surface/40 backdrop-blur-sm transition-opacity duration-300"
        ></div>

        <!-- Drawer Content -->
        <div class="fixed inset-y-0 left-0 w-72 bg-brand-surface-container-low flex flex-col p-6 shadow-2xl border-r-[0.5px] border-brand-outline-variant/60 animate-in slide-in-from-left duration-300">
          <!-- Close button & Logo -->
          <div class="flex items-center justify-between pb-6 border-b border-brand-outline-variant/40">
            <a href="/" class="flex items-center gap-3 group">
              <div class="bg-brand-primary p-2 rounded-brand-md shadow-lg shadow-brand-primary/20">
                <.icon name="hero-academic-cap" class="size-5 text-brand-on-primary" />
              </div>
              <span class="text-base font-black tracking-tight text-brand-on-surface">
                Absensi<span class="text-brand-primary">Digital</span>
              </span>
            </a>
            <button 
              type="button" 
              phx-click={JS.hide(to: "#mobile-sidebar-drawer")}
              class="p-1.5 rounded-brand-md bg-brand-surface-container border-[0.5px] border-brand-outline-variant/60 text-brand-on-surface-variant hover:text-brand-on-surface"
            >
              <.icon name="hero-x-mark" class="size-5" />
            </button>
          </div>

          <!-- Navigation inside Mobile Drawer -->
          <nav class="flex-1 space-y-1.5 py-6">
            <div class="text-[10px] uppercase tracking-widest text-brand-on-surface-variant/50 font-black px-4 mb-3">
              Menu Utama
            </div>
            <.nav_link navigate={~p"/"} icon="hero-squares-2x2" active={@current_scope == :dashboard} phx-click={JS.hide(to: "#mobile-sidebar-drawer")}>
              Dashboard
            </.nav_link>
            <.nav_link href={~p"/student"} icon="hero-users" active={@current_scope == :student} phx-click={JS.hide(to: "#mobile-sidebar-drawer")}>
              Data Siswa
            </.nav_link>
            <.nav_link navigate={~p"/scan"} icon="hero-qr-code" active={@current_scope == :scan} phx-click={JS.hide(to: "#mobile-sidebar-drawer")}>
              Scan Presensi
            </.nav_link>
          </nav>

          <!-- Footer inside Mobile Drawer -->
          <div class="pt-6 border-t border-brand-outline-variant/60 bg-brand-surface-container-low/50">
            <div class="bg-brand-surface-container-lowest border-[0.5px] border-brand-outline-variant/60 rounded-brand-md p-4 mb-4 flex items-center gap-3">
              <div class="size-9 rounded-brand-md bg-gradient-to-tr from-brand-primary to-brand-secondary flex items-center justify-center text-brand-on-primary font-black shadow-md shadow-brand-primary/10">
                A
              </div>
              <div class="flex-1 overflow-hidden">
                <p class="text-xs font-black tracking-tight truncate">Administrator</p>
                <p class="text-[9px] text-brand-success font-bold uppercase tracking-widest truncate">Online</p>
              </div>
            </div>
            <.theme_toggle />
          </div>
        </div>
      </div>

      <!-- Main Content Container -->
      <div class="flex-1 flex flex-col overflow-hidden">
        <!-- Topbar/Header -->
        <header class="bg-brand-surface-container-lowest/80 backdrop-blur-md border-b-[0.5px] border-brand-outline-variant/60 sticky top-0 z-40 px-6 py-4 flex items-center justify-between">
          <!-- Mobile Menu Button & Brand -->
          <div class="flex items-center gap-3 md:hidden">
            <button
              type="button"
              phx-click={JS.show(to: "#mobile-sidebar-drawer")}
              class="p-2.5 rounded-brand-md bg-brand-surface-container border-[0.5px] border-brand-outline-variant/60 text-brand-on-surface hover:bg-brand-surface-container-high transition-colors"
            >
              <.icon name="hero-bars-3" class="size-5" />
            </button>
            <a href="/" class="flex items-center gap-2">
              <div class="bg-brand-primary p-1.5 rounded-brand-md shadow-lg shadow-brand-primary/20">
                <.icon name="hero-academic-cap" class="size-5 text-brand-on-primary" />
              </div>
              <span class="font-extrabold text-base tracking-tight text-brand-on-surface">
                Absensi<span class="text-brand-primary">Digital</span>
              </span>
            </a>
          </div>

          <!-- Page Title & Subtitle (Desktop only) -->
          <div class="hidden md:flex flex-col">
            <h2 class="text-lg font-bold tracking-tight text-brand-on-surface">
              <%= case @current_scope do %>
                <% :dashboard -> %>Ringkasan Dasbor Portal
                <% :student -> %>Kelola Data Siswa
                <% :scan -> %>Mesin Scan Presensi QR
                <% _ -> %>Absensi Digital Sekolah
              <% end %>
            </h2>
            <p class="text-xs text-brand-on-surface-variant/80 font-medium">
              <%= case @current_scope do %>
                <% :dashboard -> %>Pantau tingkat kehadiran, riwayat presensi, dan aktivitas terbaru.
                <% :student -> %>Lihat daftar siswa, tambahkan siswa baru, dan kelola ID Kartu.
                <% :scan -> %>Dekatkan kode QR kartu siswa ke kamera untuk mencatat presensi hari ini.
                <% _ -> %>Sistem monitoring kehadiran sekolah berbasis digital.
              <% end %>
            </p>
          </div>

          <!-- Actions & Indicators -->
          <div class="flex items-center gap-4">
            <!-- Search Quick Lens (Desktop only) -->
            <div class="hidden lg:flex items-center gap-2 bg-brand-surface-container-low border-[0.5px] border-brand-outline-variant/60 rounded-brand-md px-3.5 py-1.5 w-72 text-brand-on-surface-variant/60 hover:border-brand-primary/40 transition-colors cursor-pointer group">
              <.icon name="hero-magnifying-glass-micro" class="size-4 text-brand-on-surface-variant/40 group-hover:text-brand-primary transition-colors" />
              <span class="text-xs font-semibold">Cari siswa, kelas, or status...</span>
            </div>

            <!-- Real-time Date Panel (Desktop only) -->
            <div class="hidden sm:flex items-center gap-2 bg-brand-surface-container border-[0.5px] border-brand-outline-variant/60 rounded-brand-md px-3 py-1.5 text-xs font-bold text-brand-on-surface-variant">
              <.icon name="hero-calendar" class="size-4 text-brand-primary" />
              <span id="current-date-display" phx-update="ignore">
                <%= DateTime.utc_now() |> DateTime.add(7, :hour) |> Calendar.strftime("%A, %d %B %Y") %>
              </span>
            </div>

            <!-- Notifications Badge -->
            <button class="relative p-2 rounded-brand-md bg-brand-surface-container hover:bg-brand-surface-container-high text-brand-on-surface border-[0.5px] border-brand-outline-variant/60 transition-colors">
              <.icon name="hero-bell" class="size-5" />
              <span class="absolute top-1 right-1 size-2 rounded-full bg-brand-error animate-ping"></span>
              <span class="absolute top-1 right-1 size-2 rounded-full bg-brand-error"></span>
            </button>

            <!-- Profile Info (Desktop only) -->
            <div class="hidden md:flex items-center gap-2 border-l border-brand-outline-variant/60 pl-4">
              <div class="size-9 rounded-brand-md bg-gradient-to-tr from-brand-primary to-brand-secondary flex items-center justify-center text-brand-on-primary font-black shadow-md shadow-brand-primary/10">
                A
              </div>
              <div class="flex flex-col text-left">
                <span class="text-xs font-extrabold text-brand-on-surface leading-tight">Admin Akademik</span>
                <span class="text-[9px] font-black text-brand-success uppercase tracking-widest leading-none">Online</span>
              </div>
            </div>
          </div>
        </header>

        <!-- Main Content Area -->
        <main class="flex-1 overflow-y-auto p-6 lg:p-12 bg-brand-background">
          <div class="max-w-[1280px] mx-auto animate-in fade-in duration-300">
            <%= if assigns[:inner_block] do %>
              {render_slot(@inner_block)}
            <% else %>
              {@inner_content}
            <% end %>
          </div>
        </main>
      </div>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  attr :navigate, :string, default: nil
  attr :href, :string, default: nil
  attr :icon, :string, required: true
  attr :active, :boolean, default: false
  attr :rest, :global
  slot :inner_block, required: true

  defp nav_link(assigns) do
    ~H"""
    <.link
      {if @href, do: %{href: @href}, else: %{navigate: @navigate}}
      {@rest}
      class={[
        "flex items-center gap-3 px-4 py-3 rounded-brand-md transition-all duration-300 group",
        if(@active,
          do:
            "bg-brand-primary text-brand-on-primary shadow-lg shadow-brand-primary/20 translate-x-1",
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
