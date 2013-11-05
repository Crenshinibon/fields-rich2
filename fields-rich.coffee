@Test = new Meteor.Collection 'test'

if Meteor.isServer
    Meteor.publish 'test', () ->
        Test.find()
    
    Meteor.startup () ->
        if Test.find().count() is 0
            Test.insert 
                label: 'Description'
                description: 'some description'
    
if Meteor.isClient
    
    Meteor.autorun () ->
        Meteor.subscribe 'test'
        
    Template.hello.description = () ->
        Test.findOne()
            
                