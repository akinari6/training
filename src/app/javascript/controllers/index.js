import { Application } from "@hotwired/stimulus"
import { registerControllersFrom } from "@hotwired/stimulus-loading"

const application = Application.start()
application.debug = false

registerControllersFrom("controllers", application)

export { application }
