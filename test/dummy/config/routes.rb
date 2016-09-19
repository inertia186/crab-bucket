Rails.application.routes.draw do
  mount Bucket::Engine => "/bucket"
end
