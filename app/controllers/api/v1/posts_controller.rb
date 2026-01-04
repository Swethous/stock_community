# app/controllers/api/v1/health_controller.rb
class Api::V1::PostsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  before_action :set_post, only: [:update, :destroy]

  # GET /api/v1/stocks/:stock_id/posts
  def index
    stock = Stock.find(params[:stock_id])

    posts = Post.includes(:user) # n+1 문제 해결 관계이름적기
                .where(stock_id: stock.id)
                .order(created_at: :desc)
                .limit(50)
    
    render json: posts.map { |p| post_json(p) }
  end

  # POST /api/v1/stocks/:stock_id/posts
  def create
    stock = Stock.find(params[:stock_id])

    post = current_user.posts.new(post_params)
    post.stock = stock # 알아서 stock_id 들어감

    if post.save
      render json: post_json(post), status: :created
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/v1/posts/:id
  def update
    return render_forbidden unless owner?(@post)

    if @post.update(post_params)
      render json: post_json(@post)
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/posts/:id
  def destroy
    return render_forbidden unless owner?(@post)

    @post.destroy!
    head :no_content # 삭제성공을 204로 응답, 응답 바디는 비움(DELETE 메서드 관례)
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def owner?(record)
    record.user_id == current_user.id
  end
  
  def render_forbidden
    render json: { error: "Forbidden" }, status: :forbidden
  end

  def post_params
    params.require(:post).permit(:body, :image_url)
  end

  def post_json(post)
    {
      id: post.id,
      stock_id: post.stock_id,
      body: post.body,
      image_url: post.image_url,
      likes_count: post.likes_count,
      comments_count: post.comments_count,
      created_at: post.created_at,
      updated_at: post.updated_at,
      user: {
        id: post.user.id,
        name: post.user.name,
        avatar_url: post.user.avatar_url
      }
    }
  end
end