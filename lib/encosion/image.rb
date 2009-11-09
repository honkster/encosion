module Encosion

  class Image < Base
    ENUMS = { :image_type => { :thumbnail => "THUMBNAIL", :video_still => "VIDEO_STILL"}}

    attr_accessor(
      :name,
      :type,
      :reference_id,
      :remote_url,
      :video_id
    )

    #
    # Class methods
    #
    class << self

      # the actual method that calls a post (user can use this directly if they want to call a method that's not included here)
      def write(method, options)
        # options.merge!(Encosion.options)
        options.merge!({:token => Encosion.options[:write_token]}) unless options[:token]

        Image.post( Encosion.options[:server],
                    Encosion.options[:port],
                    Encosion.options[:secure],
                    Encosion.options[:write_path],
                    method,
                    options,
                    self)
      end

    end

    #
    # Instance methods
    #
    def initialize(args={})
      @video_id = args[:video_id]
      @name = args[:name]
      @reference_id = args[:reference_id]
      @remote_url = args[:remote_url]
      @type = args[:type]
    end


    # Saves an image to Brightcove. Returns the Brightcove ID for the image that was just uploaded.
    #   new_image = Encosion::Image.new(:remote_file => "http://example.com/image.jpg", :display_name => "My Awesome Image", :type => "VIDEO_STILL", :video_id = > "brightcove_video_id")
    #   brightcove_id = new_image.save(:token => '123abc')

    def save(args={})
      # check to make sure we have everything needed for a create_video call
#      raise NoFile, "You need to attach a file to this video before you can upload it: Video.file = File.new('/path/to/file')" if @file.nil?
      options = args.merge({ 'image' => self.to_brightcove, :video_id => self.video_id }) # take the parameters of this video and make them a valid video object for upload
      options.merge!({:token => Encosion.options[:write_token]}) unless options[:token]
      response = Image.post(Encosion.options[:server],
                            Encosion.options[:port],
                            Encosion.options[:secure],
                            Encosion.options[:write_path],
                            'add_image',
                            options,
                            self)
      return response['result'] # returns the Brightcove ID of the video that was just uploaded
    end


    # Output the image as JSON
    def to_json
      {
        :name => @name,
        :remote_url => @remote_url,
        :type => ENUMS[:image_type][@type],
        :reference_id => @reference_id
      }.to_json
    end


    # Outputs the image object into Brightcove's expected format
    def to_brightcove
      {
        'displayName' => @name,
        'remoteUrl' => @remote_url,
        'type' => ENUMS[:image_type][@type],
        'referenceId' => @reference_id
      }
    end

  end

end
