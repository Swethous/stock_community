### ERD図
https://gyazo.com/82c37820fdbee48e457fa7a4f754d988

---

### 本サービスの概要（700文字以内）
本サービスは、米国株・日本株を対象に、ユーザー同士がリアルタイムで意見交換できる株式コミュニティサービスです。投資家が情報収集・分析・コミュニケーションを一つの画面で完結できるよう設計されており、シンプルかつ高速な UI を特徴としています。既存の株式情報サービスはチャートやニュースに特化しているものが多く、コミュニティ機能が乏しい、または UI が複雑で初心者には使いづらいという課題があります。本サービスでは、軽量なリアルタイムチャート、出来高、コメント機能、ブックマークなど、投資判断に必要な最低限の機能に焦点を当て、ユーザーが直感的に利用できる環境を提供します。

また、未ログイン状態でも記事やコメントの閲覧が可能で、利用ハードルを低くすることで新規ユーザーの流入を促します。ログイン後はコメント投稿、いいね、ブックマーク登録による個別のポートフォリオ管理が可能です。今後はニュース API 連携や AI による記事要約、WebSocket を用いたリアルタイムコメント配信、Google ログイン、動的 OGP、自動補完検索などの拡張を予定しています。最終的には React Native を用いたモバイルアプリ化を目指し、投資家がいつでもどこでも情報交換できる利便性の高いサービスを目指します。

---

#### 🅐 users テーブル（ユーザー情報）
- (string) email : ログイン認証用のメールアドレス（ユニーク制約）
- (string) encrypted_password : ハッシュ化されたパスワード
- (string) name : ユーザーの表示名
- (string) avatar_url : プロフィール画像URL
- (string) role : 権限区分（normal / admin）
- (datetime) created_at : 作成日時
- (datetime) updated_at : 更新日時

#### 🅑 stocks テーブル（銘柄情報）
- (string) symbol : 銘柄コード（例：7203.T）/ ユニーク制約
- (string) name_ja : 銘柄名（日本語）
- (string) name_en : 銘柄名（英語）
- (string) market : 上場市場名
- (string) sector : 業種・セクター名称
- (datetime) created_at : 作成日時
- (datetime) updated_at : 更新日時

#### 🅒 posts テーブル（投稿）
- (bigint) user_id : 投稿者ユーザーID（外部キー）
- (bigint) stock_id : 対象銘柄ID（外部キー）
- (text) body : 投稿本文
- (text) image_url : 添付画像URL（任意・1枚）
- (integer) comments_count : コメント数（counter cache）
- (integer) likes_count : いいね数（counter cache）
- (datetime) created_at : 作成日時
- (datetime) updated_at : 更新日時

#### 🅓 comments テーブル（コメント）
- (bigint) user_id : コメントしたユーザーID（外部キー）
- (bigint) post_id : 対象投稿ID（外部キー）
- (text) body : コメント本文
- (integer) likes_count : コメントへのいいね数
- (datetime) created_at : 作成日時
- (datetime) updated_at : 更新日時

#### 🅔 post_likes テーブル（投稿へのいいね）
- (bigint) user_id : いいねしたユーザーID（外部キー）
- (bigint) post_id : 対象投稿ID（外部キー）
- (datetime) created_at : 作成日時
- (datetime) updated_at : 更新日時
  ※ user_id + post_id にユニーク制約（同じ投稿へ複数回いいね不可）

#### 🅕 comment_likes テーブル（コメントへのいいね）
- (bigint) user_id : いいねしたユーザーID（外部キー）
- (bigint) comment_id : 対象コメントID（外部キー）
- (datetime) created_at : 作成日時
- (datetime) updated_at : 更新日時
  ※ user_id + comment_id にユニーク制約

#### 🅖 bookmarks テーブル（ブックマーク）
- (bigint) user_id : ブックマークしたユーザーID
- (bigint) post_id : ブックマーク対象の投稿ID
- (datetime) created_at : 作成日時
- (datetime) updated_at : 更新日時
  ※ user_id + post_id にユニーク制約

#### 🅗 price_candles テーブル（株価キャッシュ）
- (bigint) stock_id : 対象銘柄ID
- (datetime) time : 足の基準時刻
- (string) interval : 足種別（例：1m / 5m / 1d）
- (decimal) open : 始値
- (decimal) high : 高値
- (decimal) low : 安値
- (decimal) close : 終値
- (bigint) volume : 出来高
- (datetime) created_at : 作成日時
- (datetime) updated_at : 更新日時

---

### ER図の注意点
- [✔] プルリクエストに最新のER図のスクリーンショットを画像が表示される形で掲載できているか？
- [✔] テーブル名は複数形になっているか？
- [✔] カラムの型は記載されているか？
- [✔] 外部キーは適切に設けられているか？
- [✔] リレーションは適切に描かれているか？多対多の関係は存在しないか？
- [✔] STIは使用しないER図になっているか？
- [✔] Postsテーブルにpost_nameのように"テーブル名+カラム名"を付けていないか？