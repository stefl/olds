class SnippetsController < ApplicationController
  protect_from_forgery except: :create

  def create
    @story = Story.friendly.find(params[:story_id])
    file = Tempfile.new("snippet")
    file.binmode
    file.write Base64.decode64(snippet_params[:image])
    file.rewind
    image = Cloudinary::Uploader.upload(file)
    @snippet = Snippet.create(:text => snippet_params[:text], :story_id => @story.id, :image => image)
    respond_to do |format|
      format.html { render text: @snippet.to_json}
      format.json { render json: @snippet.to_json}
    end
  end

  private
    def snippet_params
      p = params.require(:snippet).permit! #todo
    end
end
