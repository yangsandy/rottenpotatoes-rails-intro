class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.all
    @all_ratings=Movie.uniq.pluck(:rating).reverse
    
    if(params[:ratings]!=nil)
      @cur_ratings=params[:ratings].keys
      # source: https://stackoverflow.com/questions/28954500/activerecord-where-field-array-of-possible-values
      logger.debug "yes form"
      logger.debug @cur_ratings[0]
      @movies=Movie.where('rating IN (?)', @cur_ratings)
    else
      logger.debug "no form"
    end
    
    if (params[:sortby]!=nil)
      if @cur_ratings==nil||@cur_ratings.empty?
        logger.debug "regular search"
        @movies=Movie.order(params[:sortby])
      else
        logger.debug "conditioned search"
        @movies=Movie.where('rating IN (?)', @cur_ratings).order(params[:sortby])
      end
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    @cur_ratings=[]
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    @cur_ratings=[]
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
  def sort
    params[:title]
  end
  
end
