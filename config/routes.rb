
resque_web_constraint = lambda do |request|
  current_user = request.env['warden'].user
  ability = Ability.new current_user
  rv = ability.present? && ability.respond_to?(:admin?) && ability.admin?
  rv
end

Rails.application.routes.draw do
  mount BrowseEverything::Engine => '/browse'
  mount Blacklight::Engine => '/'

  #get ':action' => 'hyrax/static#:action', constraints: { action: /about|help|use-downloaded-data|support-for-depositors|management-plan-text|file-format-preservation|how-to-upload|globus-help|prepare-your-data|retention|zotero|mendeley|agreement|terms|subject_libraries|versions|dbd-documentation-guide|metadata-guidance/ }, as: :static
  get ':action' => 'hyrax/static#:action', constraints: { action: %r{
                                                                      about|
                                                                      help|
                                                                      use-downloaded-data|
                                                                      support-for-depositors|
                                                                      management-plan-text|
                                                                      file-format-preservation|
                                                                      how-to-upload|
                                                                      globus-help|
                                                                      prepare-your-data|
                                                                      retention|
                                                                      zotero|
                                                                      mendeley|
                                                                      agreement|
                                                                      terms|
                                                                      subject_libraries|
                                                                      versions|
                                                                      dbd-documentation-guide|
                                                                      metadata-guidance
                                                                    }x
                                                        }, as: :static

  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  devise_for :users, path: '', path_names: {sign_in: 'login', sign_out: 'logout'}, controllers: {sessions: 'sessions'}
  get '/logout_now', to: 'sessions#logout_now'

  mount Qa::Engine => '/authorities'
  mount Hyrax::Engine => '/'
  resources :welcome, only: 'index'
  root 'hyrax/homepage#index'
  #curation_concerns_collections
  curation_concerns_basic_routes
  curation_concerns_embargo_management
  concern :exportable, Blacklight::Routes::Exportable.new

  namespace :hyrax,  path: :concern do
    resources :generic_works do
      member do
        post   'identifiers'
        post   'download'
        post   'globus_download'
        post   'globus_add_email'
        get    'globus_add_email'
        delete 'globus_clean_download'
        post   'globus_download_add_email'
        get    'globus_download_add_email'
        post   'globus_download_notify_me'
        get    'globus_download_notify_me'
        post   'confirm'
        delete 'tombstone'
      end
    end
  end

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  constraints resque_web_constraint do
    mount ResqueWeb::Engine => "/resque"
  end

  # For anyone who doesn't meet resque_web_constraint,
  # fall through to this controller.
  get 'resque', controller: :jobs, action: :forbid


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'hyrax/homepage#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
