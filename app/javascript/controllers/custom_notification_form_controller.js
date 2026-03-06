import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["body", "counter", "audience", "recipient"]
  static values = {
    baseLimit: Number,
    allLimit: Number
  }

  connect() {
    this.updateLimit()
  }

  updateLimit() {
    const limit = this.effectiveLimit()

    this.bodyTarget.maxLength = limit
    if (this.bodyTarget.value.length > limit) {
      this.bodyTarget.value = this.bodyTarget.value.slice(0, limit)
    }

    this.counterTarget.textContent = `${this.bodyTarget.value.length}/${limit}`
  }

  effectiveLimit() {
    const audience = this.selectedAudience()

    if (audience === "selected") {
      const selectedLimits = this.recipientTargets
        .filter((input) => input.checked)
        .map((input) => Number(input.dataset.maxBodyLength))
        .filter((value) => Number.isFinite(value) && value > 0)

      if (selectedLimits.length > 0) {
        return Math.min(this.baseLimitValue, ...selectedLimits)
      }
    }

    return Math.min(this.baseLimitValue, this.allLimitValue || this.baseLimitValue)
  }

  selectedAudience() {
    const selected = this.audienceTargets.find((input) => input.checked)
    return selected ? selected.value : "all"
  }
}
