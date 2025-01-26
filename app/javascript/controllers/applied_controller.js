import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["checkbox", "jobTitle", "form"];

  submitForm() {
    this.jobTitleTarget.classList.toggle("line-through");
    this.formTarget.requestSubmit(); // Submit the form
  }
}
