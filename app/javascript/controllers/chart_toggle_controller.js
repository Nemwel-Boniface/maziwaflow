import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["chart"]

  switch(event) {
    const selectedType = event.target.value
    
    this.chartTargets.forEach((element) => {
      if (element.dataset.chartType === selectedType) {
        element.classList.remove("hidden")
      } else {
        element.classList.add("hidden")
      }
    })
  }
}