# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class SettingsController < ApplicationController
  before_filter :authenticate_learner!
  
  def profile
    @learner = current_learner
    if request.put?      
      if @learner.update_attributes(params[:learner])
        redirect_to(settings_profile_path, :notice => 'Profile was successfully updated.')
      else
        render :action => 'profile'
      end
    end
  end
  
  def notifications
    @learner = current_learner
    if request.post?
      if(notification_type = params[:notification_type])
        case notification_type
          when 'sms_reminder_notification'
            if params['notification.reminder.sms'] && params['notification.reminder.sms'] == '1' 
              preference = Preference.create_or_update(@learner, 'notification.reminder.sms', true)
              if params['notification.reminder.sms.notice']
                preference = Preference.create_or_update(@learner, 'notification.reminder.sms.notice', params['notification.reminder.sms.notice'])
              end
            else
              preference = Preference.create_or_update(@learner, 'notification.reminder.sms', false)
            end
          when 'email_reminder_notification'
            if params['notification.reminder.email'] && params['notification.reminder.email'] == '1'
              preference = Preference.create_or_update(@learner, 'notification.reminder.email', true)
            else
              preference = Preference.create_or_update(@learner, 'notification.reminder.email', false)
            end
          when 'activity_notification'
            if params['notification.activity'] && params['notification.activity'] == '1'
              preference = Preference.create_or_update(@learner, 'notification.activity', true)
            else
              preference = Preference.create_or_update(@learner, 'notification.activity', false)
            end
          when 'recording_notification'
            if params['notification.recording'] && params['notification.recording'] == '1'
              preference = Preference.create_or_update(@learner, 'notification.recording', true)
            else
              preference = Preference.create_or_update(@learner, 'notification.recording', false)
            end
          when 'recommendation_notification'  
            if params['notification.recommendation'] && params['notification.recommendation'] == '1'
              preference = Preference.create_or_update(@learner, 'notification.recommendation', true)
            else
              preference = Preference.create_or_update(@learner, 'notification.recommendation', false)
            end
          else
            # do nothing
          end
      end
    end
  end
  
  def portfolio
  end
  
  def learning_profile
    @learner = current_learner
    @learner.portfolio_setting.present? ? @learning_profile = @learner.portfolio_setting : @learning_profile = PortfolioSetting.new
    if request.post? or request.put?
      if @learning_profile.persisted?
        if @learning_profile.update_attributes(params[:portfolio_setting])
          flash[:notice] = "Learning profile updated."
          redirect_to portfolio_learner_url(@learner)
        end
      else
        learning_profile = PortfolioSetting.new(params[:portfolio_setting])
        if learning_profile.save
          flash[:notice] = "Learning profile saved"
          redirect_to portfolio_learner_url(@learner)
        end
      end
    end
  end
  
  def privacy
    @learner = current_learner
    if request.post?
      if params['sharing.events.presented'].present? && params['sharing.events.presented'] == '1'
        preference = Preference.create_or_update(@learner, 'sharing.events.presented', true)
      else
        preference = Preference.create_or_update(@learner, 'sharing.events.presented', false)
      end
      
      if params['sharing.events.attended'].present? && params['sharing.events.attended'] == '1'
        preference = Preference.create_or_update(@learner, 'sharing.events.attended', true)
      else
        preference = Preference.create_or_update(@learner, 'sharing.events.attended', false)
      end
      
      if params['sharing.events.watched'].present? && params['sharing.events.watched'] == '1'
        preference = Preference.create_or_update(@learner, 'sharing.events.watched', true)
      else
        preference = Preference.create_or_update(@learner, 'sharing.events.watched', false)
      end
      
      if params['sharing.events.bookmarked'].present? && params['sharing.events.bookmarked'] == '1'
        preference = Preference.create_or_update(@learner, 'sharing.events.bookmarked', true)
      else
        preference = Preference.create_or_update(@learner, 'sharing.events.bookmarked', false)
      end
      
      if params['sharing.events.commented'].present? && params['sharing.events.commented'] == '1'
        preference = Preference.create_or_update(@learner, 'sharing.events.commented', true)
      else
        preference = Preference.create_or_update(@learner, 'sharing.events.commented', false)
      end
      
      if params['sharing.events.rated'].present? && params['sharing.events.rated'] == '1'
        preference = Preference.create_or_update(@learner, 'sharing.events.rated', true)
      else
        preference = Preference.create_or_update(@learner, 'sharing.events.rated', false)
      end
      
      if params['sharing.events.answered'].present? && params['sharing.events.answered'] == '1'
        preference = Preference.create_or_update(@learner, 'sharing.events.answered', true)
      else
        preference = Preference.create_or_update(@learner, 'sharing.events.answered', false)
      end
      
      if params['sharing.portfolio'].present? && params['sharing.portfolio'] == '1'
        preference = Preference.create_or_update(@learner, 'sharing.portfolio', true)
      else
        preference = Preference.create_or_update(@learner, 'sharing.portfolio', false)
      end
      
      flash[:notice] = "Privacy settings updated"
    end
  end
  
end
