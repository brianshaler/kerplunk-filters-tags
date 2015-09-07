_ = require 'lodash'
Promise = require 'when'

module.exports = (System) ->
  Characteristic = System.getModel 'Characteristic'

  hasTag = (data) ->
    {item, parameter} = data
    #console.log "hasTag: #{parameter}"
    return Promise.resolve data unless item.attributes?.characteristic?.length > 0
    parameter = parameter.toLowerCase()
    mpromise = Characteristic
    .where
      _id:
        $in: item.attributes.characteristic
    .find()
    Promise(mpromise).then (characteristics) ->
      texts = _.pluck characteristics, 'text'
      data.match = texts.indexOf("tag:#{parameter}") != -1
      # console.log 'hasTag done', data.match
      data

  doesNotHaveTag = (data) ->
    {item, parameter} = data
    #console.log "doesNotHaveTag: #{parameter}"
    hasTag item, parameter
    .then (data) ->
      data.match = !data.match
      data

  addTag = (data) ->
    {item, parameter} = data
    tag = "tag:#{parameter.toLowerCase()}"
    Characteristic.getOrCreate tag
    .then (characteristic) ->
      item.attributes = {} unless item.attributes
      unless item.attributes?.characteristic?.length > 0
        item.attributes.characteristic = []
      item.attributes.characteristic.push characteristic._id
      item

  removeTag = (data) ->
    {item, parameter} = data
    tag = "tag:#{parameter.toLowerCase()}"
    mpromise = Characteristic
    .where
      text: tag
    .findOne()
    Promise(mpromise).then (characteristic) ->
      return item unless characteristic
      return item unless item.attributes?.characteristic?.length > 0
      item.attributes.characteristic = _.filter item.attributes?.characteristic, (cid) ->
        String(cid) != String(characteristic._id)
      item

  globals:
    public:
      filters:
        conditions:
          hasTag:
            description: 'has tag'
            parameterRequired: true
          doesNotHaveTag:
            description: 'does not have tag'
            parameterRequired: true
        actions:
          addTag:
            description: "add tag"
            parameterRequired: true
          removeTag:
            description: "remove tag"
            parameterRequired: true

  events:
    filters:
      conditions:
        hasTag:
          do: hasTag
        doesNotHaveTag:
          do: doesNotHaveTag
      actions:
        addTag:
          do: addTag
        removeTag:
          do: removeTag
