module StoryFinder
  extend ActiveSupport::Concern

  def current_story
    return @story if defined?(@story)

    story = Story.find_by(short_id: params[:story_id] || params[:id])
    # convenience to use PK (from external queries) without generally permitting enumeration:
    story ||= Story.find(params[:id]) if @user&.is_admin?

    if @user && story
      story.current_vote = Vote.find_by(
        user: @user,
        story: story.id,
        comment: nil
      ).try(:vote)
    end

    @story = story
  end

  def current_story_missing?
    current_story.nil? || current_story.is_gone?
  end

  def require_story_exists
    raise ActiveRecord::RecordNotFound unless current_story
  end
end
