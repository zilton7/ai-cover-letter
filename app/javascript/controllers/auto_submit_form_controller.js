import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["checkbox"];

  connect() {
    // Automatically submit the form when the checkbox changes
    this.checkboxTarget.addEventListener("change", this.submitForm.bind(this));
  }

  submitForm() {
    this.element.requestSubmit(); // Submit the form
  }
}
