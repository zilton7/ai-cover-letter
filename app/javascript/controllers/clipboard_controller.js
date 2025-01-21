import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["source", "copiedIndicator"];

  connect() {}

  copy(event) {
    // prevent the default action of the trigger element
    event.preventDefault();
    let textToCopy = this.sourceTarget.innerHTML
      .replace(/<!-- .*?-->/gs, "")
      .replace(/<turbo-frame id=".*?">(.*?)<\/turbo-frame>/gs, "$1")
      .replace(/<br\s*\/?>/gi, "\n")
      .trim();
    // copy the content from the sourceTarget to the clipboard
    navigator.clipboard.writeText(textToCopy);

    // show the copied indicator
    this.copiedIndicatorTarget.classList.remove("hidden");

    // hide the copied indicator after 2 seconds
    setTimeout(() => {
      this.copiedIndicatorTarget.classList.add("hidden");
    }, 2000);
  }
}
