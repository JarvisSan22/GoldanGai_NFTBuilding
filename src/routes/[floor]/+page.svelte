<script lang="ts">
  import { page } from "$app/stores"
  import { getFloorDetails, type Floor } from "$lib/get_floor_api"
  import { Button, Card } from "flowbite-svelte"
  import { onMount } from "svelte"
  import ImageGenerator from "$lib/components/AI_imagegen.svelte"
  import { Accordion, AccordionItem } from "flowbite-svelte"
  import { settingStore } from "../../stores/settingsStore"
  let floor: Floor | null = null
  let error: string | null = null
  let floorParam: string

  onMount(async () => {
    try {
      floorParam = $page.params.floor
      const response = await getFloorDetails(floorParam)
      if (!response.ok) {
        throw new Error("Failed to fetch floor details")
      }
      floor = await response.json()
    } catch (err) {
      error = "Failed to fetch floor details"
      console.error("Fetch error:", err)
    }
  })

  function toggleSelection(roomStyle: string) {
    console.log(roomStyle)
    settingStore.set({
      ...$settingStore,
      [$page.params.floor]: {
        roomStyle: roomStyle,
      },
    })
  }
</script>

{#if floor}
  <div class="flex flex-wrap justify-center min-h-full w-full">
    <Card size="lg" class="mx-3 mb-5 xl:mb-0">
      <h1 class="text-3xl font-bold mb-4 text-black dark:text-white">
        {$page.params.floor === "lobby"
          ? "Lobby"
          : $page.params.floor.replace("floor-", "Floor ")}
      </h1>
      <p class="mb-4">{floor.description}</p>
      <p class="mb-4">Floor theme {floor.style}</p>

      <div class="mt-8">
        <h2 class="text-2xl font-semibold mb-4">Rooms</h2>
        <Accordion multiple>
          {#each floor.rooms as room, index}
            <AccordionItem
              open={$settingStore[$page.params.floor]?.roomStyle ==
                room.roomName || index === 0}
            >
              <span slot="header"> {room.roomName}</span>
              <p>{room.description}</p>

              {#if room.room_prompt}
                <p><strong>Style:</strong> {room.room_prompt}</p>
              {/if}

              <div class="mt-3">
                <Button
                  outline={$settingStore[$page.params.floor]?.roomStyle ===
                    room.roomName}
                  on:click={(e: any) => {
                    toggleSelection(room.roomName)
                  }}>Select room</Button
                >
              </div>
            </AccordionItem>
          {/each}
        </Accordion>
      </div>
    </Card>

    <Card size="lg" class="mx-3">
      <ImageGenerator
        roomStyle={$settingStore[$page.params.floor]?.roomStyle}
        floorStyle={floor.style!}
      />
    </Card>
  </div>
{:else if error}
  <div
    class="container mx-auto p-4 flex justify-center items-center min-h-screen"
  >
    <Card class="w-full max-w-4xl p-8">
      <p class="text-red-500">{error}</p>
    </Card>
  </div>
{:else}
  <p>Loading...</p>
{/if}
