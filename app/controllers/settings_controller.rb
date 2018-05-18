# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class SettingsController < ApplicationController
  before_filter :signin_required

  def profile
    @learner = current_learner
    if request.put?
      @learner.attributes = params[:learner]
      @learner.time_zone = params[:learner][:time_zone] if !@learner.is_extension_account?
      if @learner.save
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
          when 'rescheduled_or_canceled'
            if params['notification.rescheduled_or_canceled'] && params['notification.rescheduled_or_canceled'] == '1'
              preference = Preference.create_or_update(@learner, 'notification.rescheduled_or_canceled', true)
            else
              preference = Preference.create_or_update(@learner, 'notification.rescheduled_or_canceled', false)
            end
          when 'location_changed'
            if params['notification.location_changed'] && params['notification.location_changed'] == '1'
              preference = Preference.create_or_update(@learner, 'notification.location_changed', true)
            else
              preference = Preference.create_or_update(@learner, 'notification.location_changed', false)
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

      if params['sharing.events.viewed'].present? && params['sharing.events.viewed'] == '1'
        preference = Preference.create_or_update(@learner, 'sharing.events.viewed', true)
      else
        preference = Preference.create_or_update(@learner, 'sharing.events.viewed', false)
      end

      if params['sharing.events.followed'].present? && params['sharing.events.followed'] == '1'
        preference = Preference.create_or_update(@learner, 'sharing.events.followed', true)
      else
        preference = Preference.create_or_update(@learner, 'sharing.events.followed', false)
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
