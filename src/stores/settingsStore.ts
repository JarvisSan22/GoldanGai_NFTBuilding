import { browser } from '$app/environment';
import { writable } from 'svelte/store'

// Define the type for an setting object
export interface Setting {
  roomStyle: string;
  imageurl?: string;
}

// Helper function to check if localStorage is available
function isLocalStorageAvailable() {
  try {
    const testKey = '__test__'
    localStorage.setItem(testKey, testKey)
    localStorage.removeItem(testKey)
    return true
  } catch (e) {
    return false
  }
}

// Load initial data from localStorage if available
let initialSettingStore: {
  [key: string]: Setting;
} = {};



if (browser) {
  if (isLocalStorageAvailable()) {
    const ls = localStorage.getItem('settingStore') || '[]'
    console.log(ls);

    initialSettingStore = JSON.parse(ls)
  }
}
// Create a writable store for an array of settings
export const settingStore = writable<{
  [key: string]: Setting
}>(initialSettingStore)

if (browser) {
  if (isLocalStorageAvailable()) {
    // Persist store changes to localStorage
    settingStore.subscribe((value) => {
      localStorage.setItem('settingStore', JSON.stringify(value))
    })
  }
}
