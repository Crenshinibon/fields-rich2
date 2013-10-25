@Test = new Meteor.Collection 'test'

if Meteor.isServer
    Meteor.publish 'test', () ->
        Test.find()
    
    Meteor.startup () ->
        if Test.find({name: {$exists: true}}).count() is 0
            nameId = createDynamicField 'name'
            descId = createDynamicField 'desc'
            Test.insert 
                name: {id: nameId, collection: 'name'}
                desc: {id: descId, collection: 'desc'}
    
if Meteor.isClient
    
    Meteor.subscribe 'test'
    
    Template.hello.obj = () ->
        Test.findOne {name: {$exists: true}}
        
                