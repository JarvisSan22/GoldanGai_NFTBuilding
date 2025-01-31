<script lang="ts">
  //import { page } from '$app/stores';
  import {
    Sidebar,
    SidebarGroup,
    SidebarItem,
    Button,
    Toggle,
    Drawer,
    CloseButton,
  } from "flowbite-svelte"
  import { page } from "$app/stores"

  import {
    ChartPieSolid,
    CartSolid,
    GridSolid,
    MailBoxSolid,
    UsersSolid,
    ShoppingBagSolid,
    ArrowRightToBracketOutline,
    EditOutline,
    ArrowLeftOutline,
  } from "flowbite-svelte-icons"
  import { sineIn } from "svelte/easing"
  let hidden2 = true
  let spanClass = "flex-1 ms-3 whitespace-nowrap"
  let transitionParams = {
    x: -320,
    duration: 200,
    easing: sineIn,
  }

  import { floorNames } from "$lib/get_floor_api"
  import { onMount } from "svelte"
  import "../app.css"
  //import ConnectWallet from "$lib/components/ConnectWallet.svelte"
  import WalletConnectV2 from "$lib/components/WalletConnect_v2.svelte"
  import ToggleButton from "$lib/components/ToggleButton.svelte"
  import { browser } from "$app/environment"
  import { isMintOverlayOpen } from "../stores/overlaysStore"
  import MintOverlay from "$lib/components/MintOverLay.svelte"

  let sidebarOpen = false
  let width: number
  function toggleSidebar() {
    sidebarOpen = !sidebarOpen
  }
  onMount(() => {
    width = window.innerWidth
    isMintOverlayOpen.set(false) //set to falce on reload
  })

  let darkMode = true

  function handleSwitchDarkMode() {
    darkMode = !darkMode

    localStorage.setItem("theme", darkMode ? "dark" : "light")

    darkMode
      ? document.documentElement.classList.add("dark")
      : document.documentElement.classList.remove("dark")
  }

  if (browser) {
    if (
      localStorage.theme === "dark" ||
      (!("theme" in localStorage) &&
        window.matchMedia("(prefers-color-scheme: dark)").matches)
    ) {
      document.documentElement.classList.add("dark")
      darkMode = true
    } else {
      document.documentElement.classList.remove("dark")
      darkMode = false
    }
  }
</script>

<div class="header flex items-center justify-between bg-primary">
  <ToggleButton toggleSidebar={() => (hidden2 = false)} />
  {#if $page.url.pathname.includes("floor-")}
    <Button href="/" size="sm" class="absolute left-20"
      ><ArrowLeftOutline /><span class="hidden md:block">Back to Lobby</span
      ></Button
    >
  {/if}
  <h1 class="text-center flex-grow text-lg font-bold">
    GoldenGai AI gen party
  </h1>

  <WalletConnectV2 />
</div>
<div class="flex h-screen">
  <Drawer
    transitionType="fly"
    {transitionParams}
    bind:hidden={hidden2}
    id="sidebar2"
  >
    <Sidebar class="">
      <SidebarGroup>
        <ToggleButton toggleSidebar={() => (hidden2 = true)} />
        {#each floorNames as floor}
          <SidebarItem
            href={floor.floorName === "lobby" ? "/" : `/${floor.floorName}`}
            label={floor.floorName === "lobby"
              ? "Lobby"
              : floor.floorName.replace("floor-", "Floor ")}
            on:click={toggleSidebar}
          />
        {/each}
        <div class="mr-2">
          <label for="theme-toggle" class="flex ms-5 mt-8">
            <span class="mr-2">DarkTheme</span>
            <Toggle
              checked={darkMode}
              on:click={handleSwitchDarkMode}
              type="checkbox"
              id="theme-toggle"
            />
          </label>
        </div>
      </SidebarGroup>
    </Sidebar>
  </Drawer>

  <main class="flex-grow relative p-4">
    <div class="z-50">
      <slot />
    </div>
  </main>
</div>
