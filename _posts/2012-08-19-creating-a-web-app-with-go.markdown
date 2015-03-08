---
layout: post
categories: development code
title: Creating a web app with Go
date: Sun Aug 19 2012 20:23:33 GMT-0600 (MDT)

# Old tumblr stuff
id: 29800695185
link: http://joneisen.tumblr.com/post/29800695185/creating-a-web-app-with-go
slug: creating-a-web-app-with-go
publish: 2012-08-019
tags:
---


My project over the last two weeks was to create a web app with Go, or
at least a framework for one that I could use to bootstrap further web
apps in Go.

I had two primary goals with this project: - Create a framework for a Go
web app that could scale easily and be organized. - Learn
[Backbone.js](http://backbonejs.org) so I could framework my client-side
code.

I started with what I knew, basic Go server-side code (like the stuff in
[goauth2](http://github.com/yanatan16/goauth2)) and basic client-side
javascript with jQuery. I decided to use a basic Todo-list application
as a simple example. Getting this set up was pretty simple, but I wanted
to make myself use an MVC framework, or something like it. I’ve never
done a project with an MVC-like framework before, so this was kind of
new ground. Using [web.go](http://github.com/hoisie/web), I was free to
organize the code however I liked. The core model (a todo-list) went in
the `model` folder. Views, which were just templates got stuck in the
`view` folder. And controllers, things like ajax request handlers would
go in the `controller` folder, updating the model as necessary. This
seemed like a workable framework. You can see what I had at this point
with [this
commit](https://github.com/yanatan16/go-todo-app/tree/e508f29e365986f5ffb6ab66318e3e0e8a6fbac2).

But this only accomplished one of my goals. I wanted to learn a
client-side framework like Backbone. I know it had built-in server-side
persistence and syncing, and I yearned to easily scale this framework to
a large application, so I needed a client-side and server-side framework
that worked hand-in-hand. After a few Backbone.js tutorials (I recommend
[this one](http://arturadib.com/hello-backbonejs/)), I kind-of
understood what was going on and jumped in.

I soon realized the Backbone.sync function makes 4 different CRUD calls
to the server: POST, GET, PUT, and DELETE. I decided to map the
client-side CRUD to a server-side CRUD and made the following Go
interface (see
[controller.go](https://github.com/yanatan16/go-todo-app/blob/master/helpers/controller.go)
for full code):

    // A Controller for a corresponding Backbone Model object.
    type Controller interface {
        // Create model object based on parameters
        // attr is a json-formatted string of attributes
        // Return a json-formattable object of all model attributes
        Create(id, attr string) (interface{}, error)
        // Read a model object back
        // ID may be empty string
        // Return a json-formattable object of all model attributes
        Read(id string) (interface{}, error)
        // Update a model object based on parameters.
        // ID is required and will be non-empty
        // attr is a json-formatted string of attributes
        // Return a json-formattable object of updated model attributes
        // If no attributes other than the updated ones changed, it is acceptable to return nil
        Update(id, attr string) (interface{}, error)
        // Delete a model object.
        // ID is required and will be non-empty
        Delete(id string) error
    }

Using this interface, I defined
`func BindController(svr *web.Server, path string, ctrl Controller)`
which bound the 4 CRUD methods to their HTTP verb equivalents, taking
care of ID handling (for backbone), and JSON serialization. I left the
incoming JSON un-deserialized because of Go’s interesting (and sometimes
crazy) JSON handling.

In the [end (this
commit)](https://github.com/yanatan16/go-todo-app/tree/42ce62f47e3a71bcedeb5c8da683fd4d9b1df5ae),
I was able to rid myself of the `controller` folder all-together. The
total amount of Go-Code that isn’t a test or in the `helpers` folder is
less than 200 lines and most of that is the model itself. This is a
framework that can scale. It will never be as fast to write as rails or
node, but the performance will beat rails and node at scale.

Upcoming, I’ll go into a post about the speed of Go web servers (I’ll
back up the claim I just made), and one about a few of the tricks I used
in this todo app. For now, check the
[source](http://github.com/yanatan16/go-todo-app)!

