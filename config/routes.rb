Rails.application.routes.draw do
  
  resources :bill_payments do
    member do
      get :send_to_leads_online
    end
  end
  
  resources :bills do
    collection do
      get :line_item_fields
    end
    member do
      #get :update_qb
      post :update_qb
      get :send_to_leads_online
      get :send_to_bwi
    end
  end
  
  resources :items do
    member do
      get :update_qb
    end
    collection do
      get :items_by_category
    end
  end
  
  resources :purchase_orders do
    collection do
      get :line_item_fields
    end
    member do
      #get :update_qb
      post :update_qb
      get :download
      get :send_to_leads_online
    end
  end
  
  resources :purchases
  
  resources :quickbooks do
    collection do
      get :authenticate
      get :oauth_callback
    end
  end
  
  resources :vendors do
    member do
      post :update_qb
    end
  end
  
  resources :lookup_defs
  
  resources :user_settings do
    collection do
      post :set_user_location
    end
  end
  
  resources :tud_devices do
    collection do
      get :drivers_license_scan
      get :scale_read
      get :show_scanned_jpeg_image
    end
  end
  
  resources :devices do
    member do
      get :drivers_license_scan
      get :scale_read
      get :scale_camera_trigger
      get :show_scanned_jpeg_image
      get :drivers_license_camera_trigger
      get :get_signature
      get :call_printer_for_purchase_order_pdf
      get :finger_print_trigger
      get :scanner_trigger
    end
    collection do
      get :customer_camera_trigger
      get :customer_scanner_trigger
      get :customer_scale_camera_trigger
      get :customer_camera_trigger_from_ticket
      get :drivers_license_camera_trigger_from_ticket
    end
  end
  
#  resources :contracts
  
  resources :jpegger_contracts
  
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  
  ### Start sidekiq stuff ###
  require 'sidekiq/web'
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end if Rails.env.production?
  mount Sidekiq::Web => '/sidekiq'
  ### End sidekiq stuff ###
  
  resources :image_files
  
  resources :shipment_files
  
  resources :cust_pic_files

#  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  
  resources :images do
    member do
      get 'show_jpeg_image'
      get 'show_preview_image'
      get 'send_pdf_data'
    end
    collection do
      get 'advanced_search'
    end
  end
  
  resources :shipments do
    member do
      get 'show_jpeg_image'
      get 'show_preview_image'
    end
  end
  
  resources :cust_pics do
    member do
      get 'show_jpeg_image'
      get 'show_preview_image'
      get 'send_pdf_data'
    end
  end
  
  resources :companies

  # You can have the root of your site routed with "root"
  root 'welcome#index'
  
  get 'welcome/privacy' => 'welcome#privacy'
  get 'welcome/tos' => 'welcome#tos'
  
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  
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
