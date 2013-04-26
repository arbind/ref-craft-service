class RootController < ApplicationController

  def index
    render :json => { status: :ok }
  end

  def ping
    render json: { status: :pong }
  end

  def search
    startTime = Time.new
    @query = params[:query]
    @lat = params[:lat]
    @lng = params[:lng]
    @location = params[:location]
    @radius = params[:radius] || 100 # miles
    @page = params[:page] || 1
    @limit = params[:limit] || 20
    @page = @page.to_i
    @limit = @limit.to_i
    @limit = 100 if @limit > 100

    @geo_coordinates = [@lat, @lng] if @lat.present? and @lng.present?

    # search near geo
    @crafts = Craft.near(@location, @radius).desc(:rank) if @location.present?    
    @crafts = Craft.near(@geo_coordinates, @radius).desc(:rank) if @geo_coordinates.present?

    # search for given query
    @crafts = @crafts.where(search_tags: @query) if  @query.present? and @crafts.present?
    @crafts = Crafts.where(search_tags: @query) if @query.present? and not @crafts.present?

    if @crafts.present?
      @total_crafts_count = @crafts.count
      skip = (@page-1) * @limit
      @crafts = @crafts.skip(skip).limit(@limit)

      @total_pages = 1 + (@total_crafts_count/@limit).to_i
    end

    @craft_list = @crafts.to_a if @crafts.present?
    @craft_list ||= []
    @results = {
      result_stats: {
        total: @total_crafts_count,
        count: @craft_list.count
      },
      query_info: {
        page: @page,
        limit: @limit,
        query: @query,
        lat: @lat,
        lng: @lng,
        location: @location
      },
      crafts: @craft_list
    }
    endTime = Time.new
    duration = endTime - startTime
    @results[:result_stats][:duration] = duration
    render json: @results
  end

end
