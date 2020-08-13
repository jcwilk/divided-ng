// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("@rails/activestorage").start()
// require("channels")

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import consumer from "channels/consumer"

// set up the dependencies for hyperagent
window.Q = require("q");
window.$ = require("jquery")
window.jQuery = require("jquery")
window.URI = require("URIjs")
window.URITemplate = require('URIjs/src/URITemplate');


require("vendor/hyperagent")
Hyperagent.configure('defer', window.Q.defer);
const Resource = Hyperagent.Resource;

window.GameAdapter = {} // temporary holding place for callbacks til I get less lazy

var userUuid

$(document).ready(function() {
  userUuid = $('#frame').attr("data-user-uuid")
  require("game")
})

const api = new Resource("/dv").fetch().then(function(root) {
  return root.links["dv:rooms"].fetch()
},function(err){
  debugger
}).then(function(rooms) {
  //debugger
  var firstRoom = rooms.embedded.rooms[0]
  var currentRoundLink = firstRoom.links["dvlisten:current_round"].href
  var joinLink = firstRoom.links["dv:join"].href
  var uri = new URI(currentRoundLink)
  var options = Object.fromEntries(new URLSearchParams(uri.query()))
  options["channel"] = uri.fragment()
  //debugger

  consumer.subscriptions.create(options, {
    connected() {
      //debugger
      // Called when the subscription is ready for use on the server
    },

    disconnected() {
      //debugger
      // Called when the subscription has been terminated by the server
    },

    received(data) {
      console.log("Received current round data!")
      console.log(data)
      var res = new Hyperagent.Resource()
      res._load(data)

      var participants = res.embedded.participants
      var participantPositions = {participants: []}

      var seenMe = false

      for(var i = 0; i < participants.length; i++) {
        if(participants[i].props["user_uuid"] == userUuid) {
          // It's us!
          seenMe = true
          participantPositions.moves = []
          var moves = participants[i].embedded.moves
          for(var j = 0; j < moves.length; j++) {
            var move = moves[j]
            participantPositions.moves.push({
              x: move.props.x,
              y: move.props.y,
              onClick: (function(){
                var move = moves[j]
                return function(){
                  $.post(move.links.self.href)
                }
              })()
            })
          }
        }

        participantPositions.participants.push({
          x: participants[i].embedded.move.props.x,
          y: participants[i].embedded.move.props.y
        })
      }
      GameAdapter.onNewRound(participantPositions)

      if(!seenMe) $.post(joinLink)
    }
  });
})
