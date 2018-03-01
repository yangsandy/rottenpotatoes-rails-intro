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
      @cur_ratings=params[:ratings]
      @query=[""]
      for r in params[:ratings].keys
        @query[0]+="rating = ?"
        @query.push(r)
        if @query.length-1<params[:ratings].keys.length
          @query[0]+=" or "
        end
      end
      logger.debug @query[0]
      @movie=Movie.where(@query)
    else
      logger.debug "no form"
    end
    
    if (params[:sortby]!=nil)
      if @cur_ratings.empty?
        @movies=Movie.order(params[:sortby])
      else
        @movies=Movie.where(@query).order(params[:sortby])
      end
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
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
