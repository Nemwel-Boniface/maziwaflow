import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["body", "counter", "audience", "recipient", "preview", "previewName"]
  static values = {
    baseLimit: Number,
    allLimit: Number,
    maxSmsLength: Number,
    signOff: String
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
    this.updatePreview()
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

  updatePreview() {
    if (!this.hasPreviewTarget) return

    const firstName = this.selectedPreviewName()
    const cleanBody = this.bodyTarget.value.trim().replace(/\s+/g, " ")
    const composed = this.composeMessage(firstName, cleanBody)

    if (this.hasPreviewNameTarget) {
      this.previewNameTarget.textContent = firstName
    }

    this.previewTarget.textContent = composed
  }

  selectedPreviewName() {
    const checkedRecipient = this.recipientTargets.find((input) => input.checked)
    const fullName = checkedRecipient ? checkedRecipient.dataset.customerName : "Customer"

    return this.firstName(fullName)
  }

  firstName(fullName) {
    const firstToken = (fullName || "").trim().split(/\s+/).filter(Boolean)[0] || "Customer"
    return firstToken.charAt(0).toUpperCase() + firstToken.slice(1).toLowerCase()
  }

  composeMessage(firstName, body) {
    const greeting = `Hi ${firstName}, `
    const signOff = this.signOffValue || "Friends at Maziwa flow"
    const availableBodyLength = this.maxSmsLengthValue - greeting.length - 1 - signOff.length

    if (availableBodyLength <= 0) {
      return `${greeting}${signOff}`
    }

    const truncatedBody = body.slice(0, availableBodyLength).trimEnd()
    return `${greeting}${truncatedBody} ${signOff}`
  }
}
