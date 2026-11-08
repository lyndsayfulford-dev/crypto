import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="alert"
export default class extends Controller {
  close() {
    // Add Bootstrap's default clean fade animations
    this.element.classList.remove('show')
    
    // Smoothly strip the element off the DOM row view after the transition completes
    setTimeout(() => {
      this.element.remove()
    }, 150)
  }
}
