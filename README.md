# Matterhorn [![Build Status](https://travis-ci.org/blakechambers/matterhorn.svg?branch=master)][travis] [![Code Climate](https://codeclimate.com/github/blakechambers/matterhorn/badges/gpa.svg)][cclimate] [![Coverage Status](https://coveralls.io/repos/blakechambers/matterhorn/badge.svg?branch=master)][coverage]

Support easy REST API creation and testing that follows the [json-api][jsonapi] spec for Rails applications (specifically [rails-api][rails-api]) using [Mongoid][mongoid].  See the [ROADMAP][roadmap] for more info.

## Notice

This gem was authored before active_model_serializers 0.10.x had become stable.  If you are looking for a path to enable JSON API under MongoDB, I would start with [this ticket](https://github.com/rails-api/active_model_serializers/issues/1022). At this time, this version will only work with Mongoid 4.x, and active_model_serializers 0.8.x.

## Contributing

1. Fork it ( https://github.com/blakechambers/matterhorn/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[issues]:    https://github.com/blakechambers/matterhorn/issues
[milestone]: https://github.com/blakechambers/matterhorn/milestones/0.1.0%20-%20Initial%20release
[roadmap]:   https://github.com/blakechambers/matterhorn/blob/master/ROADMAP.md
[rails-api]: https://github.com/rails-api/rails-api
[mongoid]:   https://github.com/mongodb/mongoid
[jsonapi]:   http://jsonapi.org/
[coverage]:  https://coveralls.io/r/blakechambers/matterhorn?branch=master
[travis]:    https://travis-ci.org/blakechambers/matterhorn
[cclimate]:  https://codeclimate.com/github/blakechambers/matterhorn
