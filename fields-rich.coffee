@Test = new Meteor.Collection 'test'

if Meteor.isServer
    Meteor.publish 'test', () ->
        Test.find()
    
    Meteor.startup () ->
        if Test.find().count() is 0
            Test.insert 
                label: 'Description'
                desc: 'some description'
    
if Meteor.isClient
    
    Meteor.autorun () ->
        Meteor.subscribe 'test'
        
    Template.hello.description = () ->
        Test.findOne()
    
    Template.richtext.rendered = () ->
        $("#editor-#{@data._id}").wysiwyg
            toolbarSelector: "#toolbar-#{@data._id}"
    
    Template.editor.safeDesc = () ->
        new Handlebars.SafeString @desc
    
    Template.editor.events
        'keyup div.editor': (e) ->
            newVal = $(e.target).cleanHtml()
            console.log newVal
            Test.update {_id: @_id}, {$set: {desc: newVal}}
            