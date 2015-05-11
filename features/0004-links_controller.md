# Links controller

## Fetching relationships

This is based around [#70][70].

see [fetching relationships](http://jsonapi.org/format/#fetching-relationships).

> A server MUST support fetching relationship data for every relationship URL
> provided as a self link as part of a link object.

The docs provide a sample request for a link related.

```json
HTTP/1.1 200 OK
Content-Type: application/vnd.api+json

{
  "links": {
    "self": "/articles/1/links/author",
    "related": "/articles/1/author"
  },
  "data": {
    "type": "people",
    "id": "12"
  }
}
```

## Updating Relationships

This is based around [#77][77].

See [updating relationships](http://jsonapi.org/format/#crud-updating-relationships).

## Strategy

### Fetching

- [x] Add Matterhorn::LinksController to ./app/controllers.
- [x] Add a new top level serializer path (specifically [in the code][inthecode]) in the responder, for serializing instances of `set_member`.  Currently it delegates to ScopedCollectionSerializer and ScopedResourceSerializer.  When instances or kinds_of SetMember are passed it, it should elect to use a newly created `Matterhorn::Serialization::LinkSerializer`.  
- [x] Each instance of set_member, should have the option to set it's serializer, via setting `active_model_serializer`.  It's possible that this would just need to be set on the base class of `SetMember`.
- each response should provide a top level "self" link, for the above example that would be "/articles/1/links/author".
- [x] related should call the set_members url_for method with the parent object.  assuming the example above that would be: `set_member.url_for(article)`  where article is `Article.find("1")`.
- [x] `data` should be set to the output of [`linkage` from the set_member instance][linkage] and should always be available.  Linkage is not always provided in the current serialization due to concerns for creating n+1 queries.  On has_many and has_one relations, linkage **should** still be provided by the new LinkSerializer (under the data top-level key), but **should not** be added back into the normal links serialization (i.e. when serializing the article).
- [ ] When a link relation is fetched that **DOES NOT** exist, the
  server should respond with 404. - http://jsonapi.org/format/#fetching-relationships-responses-404

To be able to get the "related" link, you'll need to rewrite the association chain to where it works correctly.

### Updating/Creating

- [ ] When a PATCH, POST or DELETE is requested that **DOES NOT** exist for a link relation, the
  server should respond with 404. While the JSON API spec is not
  specific here, it does not prevent it. Also:
    * For a fetch a 404 is specifically specified when relation does
      not exist
    * THe following section supports that a 404 is valid:
        http://jsonapi.org/format/#crud-updating-relationship-responses-other
- [ ] A `has_one`/`belongs_to` relation must allow a `PATCH` via linkage to:
    * Create a relation (JSON API & PATCH HTTP spec infers this)
    * Update a relation via linkage.
    * linkage data of `null` should clear/delete the relation
    * If relation PATCH is successful server responds with 204.
- [ ] A `has_many` relation must allow `PATCH` that provides:
    * `data` body must be array either empty or containing linkages.
    * A PATCH will also create members if none exist.
    * PATCH linkage data will replace all prior relation members.
    * A PATCH with an empty data array, will clear all relation members.
- [ ] A `has_many` relation must allow `POST` that provides:
    * appends relation to current has_many relationships, **duplicates
      should not be created**
    * `data` body must be array either empty or containing linkages.
    * `null` bodies should not modify existing relations.
    * A 204 sent to client if either relation member(s) already exist **OR** were
      created.
- [ ] For `DELETE` of `has_many` the server should:
    * Delete **all** relation linkage members supplied in client request **or** return 403. The JSON API spec is specific about this:

    > If the client makes a DELETE request to a relationship URL, the
    > server MUST delete the specified members from the relationship or
    > return a 403 Forbidden response.

    * If members do not exist on relation already **OR** members are
      successfully deleted the server should reply with 204.
- [ ] Errors
    * If relation member(s) are not able to be created, updated or deleted the server should reply with 422 and error message as to cause.

# Usage

In the case of all successful examples, the response should be with an
empty body:

```
  HTTP/1.1 204 OK
  Content-Type: application/vnd.api+json
```

#### has_one/belongs_to

In this example, the Post's author could be added or updated as
relation.

`PATCH /posts/23/links/author`

```json
  {
    "data": {"type": "user", "id": "56"}
  }
```

This demonstrates where a relation is removed from parent.

`PATCH /posts/23/links/author`

```json
  {
    "data": null
  }
```

#### has_many

Example of `PATCH`. In this example **all** the tags for Post are
replaced or created.

`PATCH /posts/23/links/tags`

```json
  {
    "data": [
        {"type": "tag", "id": "2"},
        {"type": "tag", "id": "7"}
     ]
  }
```

Example of `POST`, below the tags sent to server are added to parent,
existing members are unmodified.

`POST /posts/23/links/tags`

```json
  {
    "data": [
        {"type": "tag", "id": "99"}
     ]
  }
```

Example of `null` data POST on relation. Any existing relation(s) should be unmodified.

`POST /posts/23/links/tags`

```json
  {
    "data": [
      null
     ]
  }
```

Lastly, example of `DELETE` for has_many. The linkage members will be
removed from parent relation, but any other members on relation are
unchanged. So if this post has 4 tags, only 2 are deleted.

`DELETE /posts/23/links/tags`

```json
  {
    "data": [
        {"type": "tag", "id": "99"},
        {"type": "tag", "id": "2"}
     ]
  }
```



## Questions

[70]: https://github.com/blakechambers/matterhorn/issues/70
[77]: https://github.com/blakechambers/matterhorn/issues/77
[inthecode]: https://github.com/blakechambers/matterhorn/blob/master/lib/matterhorn/serialization/builder_support.rb#L36
[linkage]: https://github.com/blakechambers/matterhorn/blob/8d39e0040392a86bbe655d7980d67ce6c5f42770/lib/matterhorn/links/relation/base.rb#L92-L99
