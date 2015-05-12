require "spec_helper"
require "class_builder"
require "action_dispatch/routing"

RSpec.describe "Matterhorn::Links" do
  include ClassBuilder

  let(:klass) do
    define_model(:Message) do
      belongs_to :author, class_name: "User"
      add_link :author
    end
  end

  context "when adding LinkSupport" do
    subject { klass }

    context "and initialized" do
      let(:message) { klass.new }
      it { expect(message.links).to be_a(Matterhorn::Links::LinkSet) }
    end
  end

  context "link_config testing" do
    include ClassBuilder
    include UrlTestHelpers
    include SerialSpec::ItExpects
    #
    # routes_config do
    #   resources :articles
    #   resources :authors
    # end

    let!(:article_class) do
      define_model(:Article) do
        belongs_to :author
        add_link   :author
      end
    end

    let!(:author_class) do
      define_model(:Author) do
        field :name
      end
    end

    let(:author)  { Author.create }
    let(:article) { article_class.create author: author}
    let(:link_config) { article_class.__link_configs[:author] }

    it "should set link config name" do
      expect(link_config.name).to eq(:author)
    end

    context '#relation_name' do
      it "should infer relation_name from name if relation exists" do
        expect(link_config.relation_name).to eq(:author)
      end

      context "when relation doesn't exist" do
        let!(:article_class) do
          define_class(:Article, base_class) do
            add_link   :author
          end
        end

        # it "should set relation_name to nil" do
        #   expect(link_config.relation_name).to eq(nil)
        # end

      end
      # context "when relation_name is not a mongoid relation"

    end

    context '#type' do
      it "should infer type from relation_name" do
        expect(link_config.type).to eq(:belongs_to)
      end

      it "should raise and error when type cannot be found" do
        expect {
          define_model(:Article) do
            add_link   :author
          end
        }.to raise_error
      end

      context 'belongs_to' do
        let!(:article_class) do
          define_model(:Article) do
            belongs_to :author
            add_link   :author
          end
        end

        it "should infer belongs_to type to ':belongs_to'" do
          expect(link_config.type).to eq(:belongs_to)
        end

      end

      context 'has_many' do
        let(:link_config) { article_class.__link_configs[:authors] }

        let!(:article_class) do
          define_model(:Article) do
            has_many :authors
            add_link :authors
          end
        end

        it "should infer has_many type to ':has_many'" do
          expect(link_config.type).to eq(:has_many)
        end

      end

      context 'has_one' do
        let(:link_config) { article_class.__link_configs[:author] }

        let!(:article_class) do
          define_model(:Article) do
            has_one :author
            add_link :author
          end
        end

        it "should infer has_one type to ':has_one'" do
          expect(link_config.type).to eq(:has_one)
        end

      end

    end



    it "should accept 'singleton' option" do
      define_model(:Article) do
        has_many :authors
        add_link :author, relation_name: :authors, singleton: true
      end

      expect(Article.__link_configs[:author].singleton).to eq(true)
    end

    it "should accept 'nested' option" do
      define_model(:Article) do
        belongs_to :author
        add_link   :author, nested: true
      end

      expect(Article.__link_configs[:author].nested).to eq(true)
    end


  end

  context "provided link types" do
    include UrlTestHelpers
    include SerialSpec::ItExpects

    context ':belongs_to' do
      let(:author)  { Author.create }
      let(:article) { article_class.create author: author}

      let!(:article_class) do
        define_model(:Article) do
          belongs_to :author
          add_link   :author
        end
      end

      let!(:author_class) do
        define_class(:Author) do
          include Mongoid::Document

          field :name
        end
      end

      it "should set relation to type Links::BelongsTo" do
        expect(article.links[:author]).to be_kind_of(Matterhorn::Links::Relation::BelongsTo)
      end
    end

    context ':has_many' do
      let(:article) { article_class.create }
      let(:author)  { Author.create article: article }

      let!(:article_class) do
        define_class(:Article, base_class) do
          has_many  :authors
          add_link  :authors,
            nested: true
        end
      end

      let!(:author_class) do
        define_class(:Author) do
          include Mongoid::Document

          belongs_to :article
          field :name
        end
      end

      it "should set relation to type Links::HasMany" do
        expect(article.links[:authors]).to be_kind_of(Matterhorn::Links::Relation::HasMany)
      end

    end


    context ':has_one' do
      let(:article)   { article_class.create }
      let(:author)    { Author.create article: article }

      let!(:article_class) do
        define_model(:Article) do
          has_one  :author
          add_link :author,
            nested: true
        end
      end

      let!(:author_class) do
        define_class(:Author) do
          include Mongoid::Document

          belongs_to :article
          field :name
        end
      end

      it "should set relation to type Links::HasOne" do
        expect(article.links[:author]).to be_kind_of(Matterhorn::Links::Relation::HasOne)
      end

    end
  end
end
