# === COPYRIGHT:
# Copyright (c) North Carolina State University
# === LICENSE:
# see LICENSE file
class AuthController < ApplicationController
  skip_before_filter :signin_required
  skip_before_filter :verify_authenticity_token
  skip_before_filter :store_location

  def start
  end

  def end
    set_current_learner(nil)
    flash[:success] = "You have successfully signed out."
    return redirect_to(root_url)
  end

  def success
    authresult = request.env["omniauth.auth"]
    uid = authresult['uid']
    email = authresult['info']['email']
    name = authresult['info']['name']
    nickname = authresult['info']['nickname']

    logger.info "#{authresult.inspect}"

    learner = Learner.find_by_openid(uid)

    if(learner)
      if(learner.retired?)
        flash[:error] = "Your account is currently marked as retired."
        return redirect_to(root_url)
      else
        set_current_learner(learner)
        flash[:success] = "You are signed in as #{current_learner.name}"
      end
    else
      flash[:error] = "Unable to find your account, please contact an Engineering staff member to create your account"
    end

    return redirect_back_or_default(root_url)

  end

  def failure
    raise request.env["omniauth.auth"].to_yaml
  end



end
