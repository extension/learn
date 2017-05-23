# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
module AuthLib

  def current_learner
    if(!@current_learner)
      if(session[:learner_id])
        @current_learner = Learner.find_by_id(session[:learner_id])
      end
    end

    if(@current_learner and !@current_learner.signin_allowed?)
      @current_learner = nil
      nil
    else
      @current_learner
    end
  end

  def set_current_learner(learner)
    if(learner.blank?)
      @current_learner = nil
      reset_session
    elsif(!learner.signin_allowed?)
      @current_learner = nil
      reset_session
    else
      @current_learner = learner
      session[:learner_id] = learner.id
    end
  end

  private


  def signin_required
    if session[:learner_id]
      learner = Learner.find_by_id(session[:learner_id])
      if (learner.signin_allowed?)
        set_current_learner(learner)
        return true
      else
        set_current_learner(nil)
        return redirect_to(root_url)
      end
    end

    # store current location so that we can
    # come back after the user logged in
    store_location
    access_denied
    return false
  end


  def signin_optional
    if session[:learner_id]
      learner = Learner.find_by_id(session[:learner_id])
      if (learner.signin_allowed?)
        set_current_learner(learner)
      end
    end
    return true
  end

  def access_denied
    redirect_to '/auth/people'
  end


  # store current uri in  the session.
  # we can return to this location by calling return_location
  def store_location
    session[:return_to] = request.fullpath
    true
  end

  def clear_location
    session[:return_to] = nil
    true
  end

  # move to the last store_location call or to the passed default one
  def redirect_back_or_default(default)
    if session[:return_to].nil?
      redirect_to default
    else
      redirect_to session[:return_to]
      session[:return_to] = nil
    end
  end


  def admin_signin_required
    if session[:learner_id]
      learner = learner.find_by_id(session[:learner_id])
      if (learner.signin_allowed? and learner.is_admin?)
        set_current_learner(learner)
        return true
      else
        set_current_learner(nil)
        return redirect_to(:controller => '/notice', :action => 'admin_required')
      end
    end

    # store current location so that we can
    # come back after the user logged in
    store_location
    access_denied
    return false
  end

end
