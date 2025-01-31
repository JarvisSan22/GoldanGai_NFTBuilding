<script lang="ts">
  import { afterNavigate } from "$app/navigation"
  import { page } from "$app/stores"
  import {
    Accordion,
    AccordionItem,
    Button,
    Input,
    Label,
  } from "flowbite-svelte"
  import { type Image, imageStore } from "../../stores/imageStore"
  import { isMintOverlayOpen } from "../../stores/overlaysStore"

  import { afterUpdate } from "svelte"
  import { settingStore } from "../../stores/settingsStore"

  let isLoading: boolean = false
  let errorMessage: string | null = null

  export let roomStyle: string
  export let floorStyle: string

  let canSubmit = roomStyle !== ""

  async function generateImage() {
    if (!roomStyle || !floorStyle) {
      errorMessage = "Both room style and floor style are required."
      return
    }

    isLoading = true
    errorMessage = null
    const inputText = `${roomStyle} in the stlye of ${floorStyle} style`
    try {
      const response = await fetch("/api/generate-image", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ prompt: inputText }),
      })
      if (response.ok) {
        const data = await response.json()
        imageStore.update((items) => {
          items.push({
            url: data.output[0],
            prompt: inputText,
            genInfo: data,
            model: data.model,
            date: new Date(),
            author: "TEST",
            path: window.location.pathname,
            id: items.length,
          })
          return items
        })
        floorImages = $imageStore.filter(
          (i) => i.path === window.location.pathname,
        )
      } else {
        errorMessage = "Failed to generate image. Please try again."
      }
    } catch (error) {
      console.error("Error:", error)
      errorMessage = "An error occurred while generating the image."
    } finally {
      isLoading = false
    }
  }

  afterUpdate(() => {
    canSubmit = roomStyle !== ""
  })
  let floorImages: Image[]
  floorImages = $imageStore.filter((i) => i.path === window.location.pathname)
  let disabled = !canSubmit || $settingStore[$page.params.floor]
  afterNavigate(() => {
    floorImages = $imageStore.filter((i) => i.path === window.location.pathname)
    disabled = !canSubmit || $settingStore[$page.params.floor]
  })

  function toggleSelectionImage(image: Image) {
    settingStore.set({
      ...$settingStore,
      [$page.params.floor]: {
        ...$settingStore[$page.params.floor],
        imageurl: image.url,
      },
    })
  }
</script>

<div class="relative">
  <div
    class="absolute inset-0 bg-gray-800 transition-opacity z-10 flex flex-col justify-center text-center text-white"
    class:opacity-0={canSubmit}
    class:pointer-events-none={canSubmit}
  >
    <h3 class="text-2xl">Please select a room first</h3>
  </div>

  <!-- Generate button -->
  <Button disabled={!canSubmit} on:click={generateImage} class="mb-4"
    >Generate Image</Button
  >

  <!-- Show loading state -->
  {#if isLoading}
    <div class="loading-box p-4 text-center bg-gray-200">
      <p>Generating image... Please wait.</p>
    </div>
  {/if}

  <!-- Show error message -->
  {#if errorMessage}
    <div class="mt-4 p-4 bg-red-200 text-red-700">
      <p>{errorMessage}</p>
    </div>
  {/if}

  <!-- Show generated image -->
  {#if $imageStore.length > 0}
    <Accordion multiple class="mb-4">
      {#each floorImages as fI, index}
        <AccordionItem
          open={$settingStore[$page.params.floor]?.imageurl === fI.url ||
            index == 0}
        >
          <span slot="header">{fI.prompt} </span>
          <div class="">
            <!-- <label for="image_{index}"> -->
            <!-- <h3 class="text-xl font-semibold mb-2"> -->
            <!--   <input -->
            <!--     id="image_{index}" -->
            <!--     type="checkbox" -->
            <!--     class="border p-2" -->
            <!--     on:change={() => toggleSelectionImage(fI)} -->
            <!--     checked={$settingStore[$page.params.floor]?.imageurl == -->
            <!--       fI.url} -->
            <!--   /> -->
            <!--   Generated Image -->
            <!-- </h3> -->
            <!-- </label> -->
            <div class="flex overflow-hidden">
              <div class="w-40 flex-none mr-2">
                <img alt="generated image" src={fI.url} />
                <Button
                  class="mt-3"
                  outline={$settingStore[$page.params.floor]?.imageurl ===
                    fI.url}
                  on:click={(e) => {
                    toggleSelectionImage(fI)
                  }}>Select image</Button
                >
              </div>
              <div class="flex-1">
                <!-- <h4 class="text-lg font-medium">Generation Info:</h4> -->
                <pre class="text-sm overflow-auto max-h-48">{JSON.stringify(
                    fI.genInfo,
                    null,
                    2,
                  )}</pre>
              </div>
            </div>
          </div>
        </AccordionItem>
      {/each}
    </Accordion>
  {/if}

  <div class="mb-4">
    <Label for="roomStyle" class="block mb-2">Select room style</Label>
    <Input
      bind:value={roomStyle}
      id="roomStyle"
      size="sm"
      placeholder="Select room style"
    />
  </div>
  <div class="mb-4">
    <Label for="floorStyle" class="block mb-2">Enter floor style</Label>
    <Input
      bind:value={floorStyle}
      id="floorStyle"
      size="sm"
      placeholder="Default floor"
    />
  </div>
  <div class="mb-4">
    <Label for="roomStyle" class="block mb-2">Select room style</Label>
    <div class="flex">
      <img
        class="w-12 mr-3"
        alt="selected image"
        src={$settingStore[$page.params.floor]?.imageurl}
      />
      <Input
        value={$settingStore[$page.params.floor]?.imageurl}
        id="mintImageId"
        size="sm"
        placeholder="Select room style"
      />
    </div>
  </div>
  <Button
    disabled={roomStyle == "" || !$settingStore[$page.params.floor]?.imageurl}
    on:click={(e) => {
      isMintOverlayOpen.set(true)
    }}
    class="mb-4">Mint</Button
  >
</div>

<style>
  .loading-box {
    background-color: #f3f3f3;
    color: #333;
    font-size: 16px;
    border-radius: 4px;
  }
</style>
