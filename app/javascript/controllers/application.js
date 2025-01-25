import { Application } from "@hotwired/stimulus";
import { Modal, Dropdown, Alert } from "tailwindcss-stimulus-components";
import RevealController from "@stimulus-components/reveal";

const application = Application.start();

application.register("modal", Modal);
application.register("reveal", RevealController);
application.register("dropdown", Dropdown);
application.register("alert", Alert);

// Configure Stimulus development experience
application.debug = false;
window.Stimulus = application;

export { application };
