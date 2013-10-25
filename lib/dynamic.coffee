@collections = {}
getCollection = (name) ->
    unless name?
        return [new Meteor.Collection(null), true]
    
    unless collections[name]?
        collections[name] = new Meteor.Collection name
        [collections[name], true]
    else
        [collections[name], false]
    
    
@createDynamicField = (collectionName) ->
    [collection, created] = getCollection collectionName
    c = 
        label: collectionName
        value: 'some initial value'
    collection.insert c
    
if Meteor.isServer
    Meteor.methods 
        initPublication: (name) ->
            if name?
                [collection, created] = getCollection name
                if created
                    Meteor.publish name, (id) ->
                        collection.find {_id: id}
    
    Meteor.methods
        initCollection: (name) ->
            [col, created] = getCollection name
            created
            
    
if Meteor.isClient
    
    class Manager
        constructor: (@ref) ->
            if @ref.collection? and @ref.id
                Meteor.call 'initPublication', @ref.collection
                Meteor.subscribe @ref.collection, @ref.id
                @_readData()
            else
                console.log 'Incomplete instantiation: ' + @ref
            
        _col: () =>
            [col, created] = getCollection @ref.collection
            col
            
        _readData: () =>
            @data = @_col().findOne {_id: @ref.id}
            
        save: (newValue) =>
            console.log 'saved: ', @, @ref, newValue
            @_col().update {_id: @ref.id}, {$set: {value: newValue}}
            #@_readData()
            
        label: () =>
            #unless @data?
            #    @_readData()
            @data?.label
            
        value: () =>
            #unless @data?
            #    @_readData()
            @data?.value
    ###        
    updateEvent = (man) ->
        'keyup input': (e) ->
            val = e.target.value
            man.save val
    ###
    ###
    @managers = {}
    managerId = (ref) ->
        ref.id + '-' + ref.collection
    
    getManager = (ref) ->
        if ref.id? and ref.collection?
            mId = managerId ref
            unless managers[mId]?
                managers[mId] = new Manager ref
            managers[mId]
    ###
    
    subscribeCollection = (ref) ->
        Meteor.call 'initPublication', ref.collection
        Meteor.subscribe ref.collection, ref.id
        [col, created] = getCollection ref.collection
        col
    
    wrap = (ref) ->
        if ref? and ref.collection? and ref.id?
            col = subscribeCollection ref
            fieldData = col.findOne {_id: ref.id}
            if fieldData?
                fieldData.save = (newValue) ->
                    col.update {_id: ref.id}, {$set: {value: newValue}}
            fieldData
            
    
    Template.dynamic.events 
        'keyup input': (e) ->
            val = e.target.value
            @save val
    
    Template.dynamic._fieldData = () ->
        console.log @
        wrap @
    
    ###
    @managers = []
    Template.dynamic._fieldData = () ->
        man = new Manager @
        managers.push man
        #Template.dynamic.events updateEvent man
        console.log man, @
        man
        
    
    Template.dynamic._fieldDataWoM = () ->
        if @id? and @collection?
            Meteor.call 'initCollection', @collection
            [col, created] = getCollection @collection
            col.findOne {_id: @id}
    ###