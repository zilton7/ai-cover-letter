# Pin npm packages by running ./bin/importmap

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'

pin 'tailwindcss-stimulus-components' # @6.1.3
pin '@fortawesome/fontawesome-free', to: '@fortawesome--fontawesome-free.js' # @6.7.2
pin '@stimulus-components/reveal', to: '@stimulus-components--reveal.js' # @5.0.0
pin 'add' # @2.0.6
pin '@hotwired/stimulus', to: '@hotwired--stimulus.js' # @3.2.2
pin '@stimulus-components/dropdown', to: '@stimulus-components--dropdown.js' # @3.0.0
pin 'stimulus-use' # @0.52.3
