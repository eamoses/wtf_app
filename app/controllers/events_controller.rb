class EventsController < ApplicationController

  def index
    @events = Event.all
    @hash = Gmaps4rails.build_markers(@events) do |event, marker|
      marker.lat event.latitude
      marker.lng event.longitude
      marker.infowindow render_to_string(:partial => "/events/info", :locals => { :event => event.title,
        :user_path => user_path(event.user), :username => event.user.username, :content => event.content,
        :user => event.user, :avatar => event.user.avatar, :category => event.category
      })
    end
  end

  def new
     @user = User.find_by(id: params[:user_id])
     @event = Event.new
    #  @longitude = (@event[:user_id])
     if params[:category]
       @event.category = params[:category]
     end
     render :new
  end

  def create
    @user = current_user
    @event = Event.new(event_params)
    @event.longitude = request.location.longitude
    @event.latitude = request.location.latitude
    # @event.ip_address = "198.200.32.4"

    # lat = params[:latitude].to_s
    # long = params[:longitude].to_s
    #
    # puts "latitude: " + lat.to_s
    # puts "lat params: " + params[:latitude].to_s

    # @event.latitude = lat
    # @event.longitude = long

    @event.save!

    @user.events << (@event)

    if @event.save
      redirect_to root_path
    else
      flash[:error] = @event.errors.full_messages.to_sentence
      redirect_to new_user_event_path(@event[:user_id])
    end
  end

  def edit
     @event = Event.find_by(id: params[:id])
     if current_user == @event.user
       render :edit
     else
       flash[:error] = "You can only edit your own events"
       redirect_to to root_path
     end
  end

  def update
    event = Event.find_by(id: params[:id])
    event.update(event_params)
    redirect_to root_path
  end

  def destroy
    event = Event.find_by(id: params[:id])
    event.destroy
    redirect_to user_path(current_user)
  end



  private
  def event_params
    params.require(:event).permit(:title, :content, :category, :longitude, :latitude, :address)
  end
end
