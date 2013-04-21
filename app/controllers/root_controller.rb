class RootController < ApplicationController

  def index
    render :text => 'ok'
  end

  def ping
    respond_to do |format|
      format.html { render text: :pong}
      format.json { render json: {ping: :pong} }
    end    
  end

  def search
    @query = params[:query]
    @lat = params[:lat]
    @lng = params[:lng]
    @location = params[:location]
    @radius = params[:radius] || 100 # miles
    @page = params[:page] || 1
    @limit = params[:limit] || 20
    @page = @page.to_i
    @limit = @limit.to_i

    @geo_coordinates = [@lng, @lat] if @lng.present? and @lat.present?

    @crafts = Craft.near(@geo_coordinates, @radius).desc(:rank) if @geo_coordinates
    # @crafts ||= Craft.near(@geo_place, @radius).desc(:ranking_score) if @geo_place

    if @crafts.present?
      @total_crafts_count = @crafts.count
      skip = (@page-1) * @limit
      @crafts = @crafts.skip(skip).limit(limit)

      @total_pages = 1 + (@total_crafts_count/@limit).to_i
      # js_var(total_crafts_count: @total_crafts_count, page: @page, total_pages: @total_pages)
    end

    if @query.present?
      @crafts = @crafts.where(search_tags: @query) if @crafts.present?
      @crafts ||= Craft.where(search_tags: @query)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: nil }
    end
  end

end
