import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String, streamName: String, zipCode: String, countryCode: String }

  connect() {
    const source = this.element.querySelector("turbo-cable-stream-source")
    if (!source) return

    this.whenConnected(source).then(() => this.enqueue())
  }

  disconnect() {
    this.observer?.disconnect()
  }

  whenConnected(source) {
    if (source.hasAttribute("connected")) return Promise.resolve()

    return new Promise((resolve) => {
      this.observer = new MutationObserver(() => {
        if (!source.hasAttribute("connected")) return
        this.observer.disconnect()
        resolve()
      })
      this.observer.observe(source, { attributes: true, attributeFilter: ["connected"] })
      if (source.hasAttribute("connected")) {
        this.observer.disconnect()
        resolve()
      }
    })
  }

  enqueue() {
    const token = document.querySelector('meta[name="csrf-token"]')?.content

    fetch(this.urlValue, {
      method: "POST",
      headers: {
        "X-CSRF-Token": token,
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: new URLSearchParams({
        stream_name: this.streamNameValue,
        zip_code: this.zipCodeValue,
        country_code: this.countryCodeValue
      })
    })
  }
}
