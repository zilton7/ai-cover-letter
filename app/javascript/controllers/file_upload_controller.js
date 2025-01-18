import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="file-upload"
export default class extends Controller {
  static targets = ["fileInput", "fileLabel"];

  updateLabel() {
    const files = this.fileInputTarget.files;
    if (files.length > 0) {
      const fileNames = Array.from(files)
        .map((file) => file.name)
        .join(", ");
      this.fileLabelTarget.textContent = `'${fileNames}' selected`;
    }
  }
}
