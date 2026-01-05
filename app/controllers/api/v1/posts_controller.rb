# app/controllers/api/v1/posts_controller.rb
class Api::V1::PostsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  before_action :set_post, only: [:update, :destroy]

  # GET /api/v1/stocks/:symbol/posts
  def index
    stock = find_or_create_stock!(params[:stock_symbol])

    limit = params[:limit].presence&.to_i || 20

    limit = [[limit, 1].max, 50].min

    # 기본 쿼리(scope) 만들기
    scope = Post.includes(:user) # n+1 문제 해결 관계이름적기
                .where(stock_id: stock.id)
                .order(created_at: :desc, id: :desc)
    # cursor 가 있으면 그 커서보다 더 오래된 글만 가져오도록 조건 추가
    if params[:cursor].present?
        # cursor 파싱
        cursor_time, cursor_id = decode_cursor(params[:cursor])
        scope = scope.where("created_at < ? OR (created_at = ? AND id < ?)", cursor_time, cursor_time, cursor_id)
    end

    rows = scope.limit(limit + 1).to_a # 다음 페이지 존재 여부 확인을 위해 한 개 더 가져오기

    has_next = rows.length > limit
    posts = has_next ? rows.first(limit) : rows

    # next_cursor 생성
    next_cursor = if has_next && posts.any?
        encode_cursor(posts.last.created_at, posts.last.id)
    else
        nil
    end

    # 응답 포맷 고정 ( cursor pagination)
    render json: {
        data: posts.map { |p| post_json(p) },
        meta: {
          limit: limit,
          has_next: has_next,
          next_cursor: next_cursor
        }
    }
  end

  # POST /api/v1/stocks/:symbol/posts
  def create
    stock = find_or_create_stock!(params[:stock_symbol])

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

  def find_or_create_stock!(raw_symbol)
    symbol = raw_symbol.to_s.strip.upcase
    raise ActionController::BadRequest, "Invalid symbol" unless symbol.match?(/\A[A-Z0-9.\-]+\z/)

    Stock.find_or_create_by!(yahoo_symbol: symbol).tap do |s|
            s.update_column(:last_seen_at, Time.current) # optional
    end
  end

  def decode_cursor(cursor)
    # cursor 문자열을 "시간|id" 형태로 분해
    # split("|", 2) : | 기준으로 최대 2조각만 나눔
    t_str, id_str = cursor.to_s.split("|", 2)

    # 둘 중 하나라도 없으면 잘못된 cursor
    raise ActionController::BadRequest, "Invalid cursor" if t_str.blank? || id_str.blank?

    # Time.iso8601(t_str) : ISO8601 문자열을 Time 객체로 파싱
    # Integer(id_str)     : 숫자 변환(안되면 예외)
    [Time.iso8601(t_str), Integer(id_str)]
    rescue ArgumentError
    # 파싱 실패하면 cursor 형식이 잘못된 것 → 400 BadRequest
    raise ActionController::BadRequest, "Invalid cursor"
  end

  def encode_cursor(time, id)
    # 커서 생성: "UTC ISO8601 시간|id"
    # time.utc.iso8601: 서버/로컬 타임존 상관없이 항상 같은 기준(UTC)으로 고정
    "#{time.utc.iso8601}|#{id}"
  end


  def post_json(post)
    {
      id: post.id,
      stock_id: post.stock_id,
      preview: post.body.to_s.truncate(120),
      body: post.body,
      image_url: post.image_url,
      likes_count: post.likes_count,
      comments_count: post.comments_count,
      created_at: post.created_at.iso8601,
      updated_at: post.updated_at.iso8601, # 시간 포맷 통일
      user: {
        id: post.user.id,
        name: post.user.name,
        avatar_url: post.user.avatar_url
      }
    }
  end
end