Rails.application.routes.draw do

  root to: 'game#run'

  get 'run' => 'game#run'

  get 'score' => 'game#score'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
