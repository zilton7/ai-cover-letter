import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["content"];

  // Action triggered on dropdown change
  load(event) {
    const selectedId = event.target.value;

    // Fetch the updated content
    fetch(`/cover_letters/${selectedId}`)
      .then((response) => {
        if (!response.ok) throw new Error("Network response was not ok");
        return response.text();
      })
      .then((html) => {
        // Replace the content in the target div
        this.contentTarget.innerHTML = html;
      })
      .catch((error) => console.error("Error loading cover letter:", error));
  }
}
