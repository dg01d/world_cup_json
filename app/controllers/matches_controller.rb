class MatchesController < ApplicationController
  after_filter :set_content_type
  protect_from_forgery with: :null_session
  layout false
  respond_to :json

  def ordered_class
    klass = Match
    if params[:by_date]&.upcase == 'DESC'
      klass.order('datetime DESC')
    elsif params[:by_date]&.upcase == 'ASC'
      klass.order('datetime ASC')
    elsif params[:by].present?
      case params[:by].downcase
      when "total_goals"
        klass.order('home_team_score + away_team_score DESC')
      when "home_team_goals"
        klass.order('home_team_score DESC')
      when "away_team_goals"
        klass.order('away_team_score DESC')
      when "closest_scores"
        klass.order('abs(home_team_score - away_team_score) ASC')
      else
        klass.order('datetime ASC')
      end
    else
      klass.order('datetime ASC')
    end
  end

  def index
    @matches = ordered_class.all
    render 'index.json.rabl'
  end

  def current
    @matches = ordered_class.where(status: "in progress")
    render 'index.json.rabl', callback: params['callback']
  end

  def complete
    @matches = ordered_class.where(status: "completed")
    render 'index.json.rabl', callback: params['callback']
  end

  def future
    @matches = ordered_class.where(status: "future")
    render 'index.json.rabl', callback: params['callback']
  end

  def country
    @team = Team.where(fifa_code: params['fifa_code']).first
    @matches = ordered_class.where("home_team_id = ? OR away_team_id = ?", @team.id, @team.id)
    render 'index.json.rabl', callback: params['callback']
  end

  def today
    @matches = ordered_class.today
    render 'index.json.rabl', callback: params['callback']
  end

  def tomorrow
    @matches = ordered_class.tomorrow
    render 'index.json.rabl', callback: params['callback']
  end
end
