# app/controllers/api/v1/comments_controller.rb
class Api::V1::CommentsController < ApplicationController
    skip_before_action :authenticate_user!, only: [:index]

    before_action :set_post, only: [:index, :create]
    before_action :set_comment, only: [:update, :destroy]

    # GET /api/v1/posts/:post_id/comments
    def index
      comments = Comment.includes(:user)
                        .where(post_id: @post.id)
                        .order(created_at: :desc)
                        .limit(200)
      render json: comments.map { |c| comment_json(c) }
    end

    # POST /api/v1/posts/:post_id/comments
    def create
      comment = current_user.comments.new(comment_params)
      comment.post = @post

      if comment.save
        render json: comment_json(comment), status: :created
      else
        render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH /api/v1/comments/:id
    def update
      return render_forbidden unless owner?(@comment)

      if @comment.update(comment_params)
        render json: comment_json(@comment)
      else
        render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/comments/:id
    def destroy
      return render_forbidden unless owner?(@comment)

      @comment.destroy!
      head :no_content
    end

    private

    def set_post
      @post = Post.find(params[:post_id])
    end

    def set_comment
      @comment = Comment.includes(:user).find(params[:id])
    end

    def owner?(record)
      record.user_id == current_user.id
    end

    def render_forbidden
      render json: { error: "Forbidden" }, status: :forbidden
    end

    def comment_params
      params.require(:comment).permit(:body)
    end
      
    def comment_json(comment)
      {
        id: comment.id,
        post_id: comment.post_id,
        body: comment.body,
        likes_count: comment.likes_count,
        created_at: comment.created_at,
        updated_at: comment.updated_at,
        user: {
          id: comment.user.id,
          name: comment.user.name,
          avatar_url: comment.user.avatar_url
        }
      }
    end
end