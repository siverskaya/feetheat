class Listing < ActiveRecord::Base
	if Rails.env.development?
		has_attached_file :image, :styles => { :medium => "200x", :thumb => "100x100>" }, :default_url => "default.jpg"
	else
		has_attached_file :image, :styles => { :medium => "200x", :thumb => "100x100>" }, :default_url => "default.jpg",
			:storage => :dropbox,
    		:dropbox_credentials => Rails.root.join("config/dropbox.yml"),
    		:path => ":style/:id_:filename"
    end

    # validating image uploads to ensure that they are indeed images
    validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

    # ensure all fields in each new listing are filled out
    validates :name, :description, :price, presence: true
    # ensure that values in price field are numbers and non-negative
    validates :price, numericality: {greater_than: 0}
    # ensure that an image is attached to each listing
    validates_attachment_presence :image

    belongs_to :user
end
