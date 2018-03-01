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
      #@cur_ratings=params[:ratings].keys
      # reference: https://stackoverflow.com/questions/28954500/activerecord-where-field-array-of-possible-values
      @movies=Movie.where('rating IN (?)', params[:ratings].keys)
      session[:cur_ratings]=params[:ratings].keys
    else
      logger.debug "no form"
    end
    
    if (params[:sortby]!=nil)
      if session[:cur_ratings]==nil||session[:cur_ratings].empty?
        @movies=Movie.order(params[:sortby])
      else
        @movies=Movie.where('rating IN (?)', session[:cur_ratings]).order(params[:sortby])
      end
      session[:sortby]=params[:sortby]
      logger.debug session[:sortby]
    elsif (session[:sortby]!=nil)
      if session[:cur_ratings]==nil||session[:cur_ratings].empty?
        @movies=Movie.order(session[:sortby])
      else
        @movies=Movie.where('rating IN (?)', session[:cur_ratings]).order(session[:sortby])
      end
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    flash.keep
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
    flash.keep
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    flash.keep
    redirect_to movies_path
  end
  
  def sort
    params[:title]
  end
  
end
