import { Application } from "@hotwired/stimulus";
import { Modal } from "tailwindcss-stimulus-components";
import RevealController from "@stimulus-components/reveal";
import { Dropdown } from "tailwindcss-stimulus-components";

const application = Application.start();

application.register("modal", Modal);
application.register("reveal", RevealController);
application.register("dropdown", Dropdown);

// Configure Stimulus development experience
application.debug = false;
window.Stimulus = application;

export { application };
