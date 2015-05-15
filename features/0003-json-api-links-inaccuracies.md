# Relation serialization issues

Currently, serializing links has some issues and is diverging from the json api spec pretty extensively in some places.  

I think some of this is due to mis-information on how top-level links are intended to work, and an attempt to hold onto some usage of URL templates.  After some thought on the issue, I think it's time to remove the URL templates from the spec and closer adhere to the current version of the json-api rc3 spec (current).

While this is a big architectural change to the library, the testing put in place by the links refactor work should help keep it manageable.  


## Strategy

General:

- [x] [#64][64] - Strictly test "type" field always returns a pluralized name.  Currently BaseSerializer returns type as a singular either sometimes or all the time.
- [x] [#65][65] - `ID_FIELD` should be changed to "id".
- [x] [#66][66] - Remove Top-level relation links will no longer contain model relation links.
- [x] [#67][67] - Foreign keys for associations should not be required.
- [ ] Linkage keys can only contain "type" and "id".  It should be impossible to create a non unique pairing (not sure how to enforce that better).
- [x] When serializing "related" links, the links should always be provided.
- [x] [#73][73] - Set return Content-Type to `application/vnd.api+json`
- [x] [#68][68] - Add [`belongs_to_many`](#belongs_to_many)

Link Resources:

- This work is now detailed in [0004-link_controller.md](0004)
## Example Relations

To better understand this, we need to setup a better example set of how the relations are expected to work.

**NOTE: all these examples are serialized from the perspective of the Article class and endpoints 'facing out' to it's other links.**

There are 4 cases we need to cover:

* `belongs_to`
* `has_one`
* `has_many`
* `belongs_to_many`

### `belongs_to`

```ruby
#./config/routes.rb
resources :articles
resources :authors

#./app/models
class Author
  include Mongoid::Document
end

class Article
  include Mongoid::Document

  belongs_to :author
end

author  = Author.create
article = Article.create author: author
```

Let's assume you have an article:

```json
GET `http://example.com/articles/1`

{
  "links": {
    "self": "http://example.com/articles/1"
  },
  "data": {
    "type": "articles",
    "id": "1",
    "links": {
      "author": {
        "related" : "http://example.com/authors/1",
        "linkage" : {
          "type" : "authors",
          "id"   : 1
        }
      }
    }
  }
}
```

Linkage **must** be represented as null when the linkage is not created.

In the above case **both** the related url and linkage can be provided, for both resource and collection.

When the relationship doesn't exist, "related" should still be available.

This article has an author stored as an `author_id` `belongs_to` style relation.  This means that the author link has access to use the actual author id without needing to perform a second lookup in the database.

### `has_one`

**Note: `has_one` relations must be nested as there is no way to provide a URL to the relation in all cases without nesting, a second request, or some caching.**

```ruby
#./config/routes.rb
resources :articles do
  resource :featured_review
  resource :comments
end

#./app/models
class FeaturedReview
  include Mongoid::Document

  belongs_to :article
end

class Article
  include Mongoid::Document

  # this may not be the best example, but imagine a case where you want to
  # create a single review, and that has a single article it is referencing.
  has_one :featured_review
end

article = Article.create
review  = FeaturedReview.create article: article

```

So given the above example, the article should be serialized like:

```json
GET `http://example.com/articles/1`

{
  "links": {
    "self": "http://example.com/articles/1"
  },
  "data": {
    "type": "articles",
    "id": "1",
    "links": {
      "featured_review": {
        "related" : "http://example.com/articles/1/featured_review"
      }
    }
  }
}
```

**Note**: The "linkage" is not provided here as part of the featured_review link output.  This is intentional, as it is impossible to tell what the "id" field is on the linkage without storing that on the article itself or performing additional queries on the system, or adding additional caching.

"Related" should always be available, however accessing that url should return a 404.

### `has_many`

**Note: `has_many` relations must be nested as there is no way to provide a URL to the relation in all cases without nesting, a second request, or some caching.**

```ruby
#./config/routes.rb
resources :articles do
  resources :comments
end

#./app/models
class Comment
  include Mongoid::Document

  belongs_to :article
end

class Article
  include Mongoid::Document

  has_many :comments
end

article = Article.create
review  = Comment.create article: article

```

So given the above example, the article should be serialized like:

```json
GET `http://example.com/articles/1`

{
  "links": {
    "self": "http://example.com/articles/1"
  },
  "data": {
    "type": "articles",
    "id": "1",
    "links": {
      "comments": {
        "related" : "http://example.com/articles/1/comments"
      }
    }
  }
}
```

### `belongs_to_many`

```ruby
#./config/routes.rb
resources :articles
resources :tags

#./app/models
class Tag
  include Mongoid::Document
end

class Article
  include Mongoid::Document

  # see http://mongoid.org/en/mongoid/docs/relations.html#has_and_belongs_to_many
  # more details.  The `inverse_of: nil` should not be required, it's just
  # to demonstrate that this association doesn't need to be dual sided to work
  # inside of matterhorn.
  has_and_belongs_to_many :tags, inverse_of: nil
end

tag = Tag.create
article = Article.create tags: [tag]
```

Let's assume you have an article:

```json
GET `http://example.com/articles/1`

{
  "links": {
    "self": "http://example.com/articles/1"
  },
  "data": {
    "type": "articles",
    "id": "1",
    "links": {
      "tags": {
        "related" : "http://example.com/articles/1/tags",
        "linkage" : [
          {
            "type" : "tags",
            "id"   : 1
          }
        ]
      }
    }
  }
}
```

Belongs to many **should** require a nested route in order to display a related link.

Empty belongs to many relationships must provide linkage as an empty array `[]`.

## Questions

*none at this time.*

-----

## Request architecture

This section has been moved to [here](https://github.com/blakechambers/matterhorn/blob/master/ROADMAP.md#request-architecture).

[64]: https://github.com/blakechambers/matterhorn/issues/64
[65]: https://github.com/blakechambers/matterhorn/issues/65
[66]: https://github.com/blakechambers/matterhorn/issues/66
[67]: https://github.com/blakechambers/matterhorn/issues/67
[68]: https://github.com/blakechambers/matterhorn/issues/68
[69]: https://github.com/blakechambers/matterhorn/issues/69
[70]: https://github.com/blakechambers/matterhorn/issues/70
[73]: https://github.com/blakechambers/matterhorn/issues/73
[77]: https://github.com/blakechambers/matterhorn/issues/77
[relationships]: http://jsonapi.org/format/#fetching-relationships
[0004]: https://github.com/blakechambers/matterhorn/blob/master/features/0004-links_controller.md
