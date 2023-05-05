class AlbumsController < ApplicationController
  before_action :authenticate_with_api_key!, only: %i[create update destroy]

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing do |e|
    missing_param_error(e)
  end

  # GET /albums
  def index
    @albums = Album.all

    render json: @albums
  end

  # GET /albums/1
  def show
    album = Album.find_by_id(params[:id])
    if album.nil?
      render json: "Album #{params[:id]} was not found", status: 404
    else
      render json: album
    end
  end

  # POST /albums
  def create
    album = Album.new(album_params)

    if album.save
      render json: album, status: :created
    else
      render json: album.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /albums/1
  def update
    @album = Album.find_by_id(params[:id])
    if @album.update(album_params)
      render json: @album
    else
      render json: @album.errors, status: :unprocessable_entity
    end
  end

  # DELETE /albums/1
  def destroy
    album = Album.find(params[:id])
    render json: "Album #{params[:id]} was deleted", status: :ok unless album.destroy
  end

  private

  # Only allow a trusted parameter "white list" through.
  def album_params
    # raise EmptyPayloadError if params.empty? || params[:data].nil?

    params.require(:data).permit(:title, :performer, :cost)
  end

  def record_not_found
    render json: {
             status: 404,
             title: 'Record not found',
             detail: "Album #{params[:id]} was not found",
             source: { parameter: 'id' }
           },
           status: 404
  end

  def missing_param_error(error)
    render json: {
             status: 400,
             title: 'Not valid payload',
             detail: error.message
           },
           status: 400
  end

  def empty_payload_error
    render json: {
             status: 400,
             title: 'Payload is empty',
             detail: 'Payload must be a valid JSON'
           },
           status: 400
  end
end
