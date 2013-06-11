# A Proxy to Forward your PayPal Sandbox's IPN's to your Development Machine

## The Problem!

You can already set up PayPal sandboxes to interact with for your credit-card and other monetary handlings.
Indeed, your development machine can "talk" directly w/ the sandbox.  However, if your production system
receives IPN notifications from PayPal, you have probably already encountered the following problem:

Can the PayPal sandbox "talk" directly to your development computer?  Not unless your development computer has a static IP address
(which many find problematic -- security concerns, etc) or a public domain.

![Blocked!](http://s3.hedgeye.com/dev_images/paypal_ipn_proxy/blocked.svg)

Hence, if not, then you know you are unable to do "end-to-end" testing because you cannot test the PayPal IPN
notification.

So, you're stuck, unless you can find a way to forward PayPal sandbox IPN addresses to your development computer.

## The Solution!

In addition to setting up this tool, you need a public facing *server*.  A cloud-based server
such as Heroku will work fine. One of the gems in this project will operate as a Sinatra
server to receive and queue the PayPal IPN requests.

Your development machine must be run the other gem in this project; this will
send HTTP requests to this public facing server to retrieve the
IPN records in the *server*'s queue.  For each IPN record retrieved, this gem will
forward it to your PayPal client as though PayPal had sent it directly.

When your PayPal client
responds, this gem will relay the response back to the *server*, which will in turn relay the response
to the PayPal sandbox that made the request.

### In More Detail

Here are the components that play together:

PayPal
The *PayPal sandbox* that you want to include in your end-to-end testing.

Server
: This package's gem implements a Sinatra server for the *PayPal sandbox* that stores the IPNs in a queue.  This Sinatra
must run on a server exposed to the *PayPal sandbox*.

Queue
: Part of the Sinatra server.  The Sinatra server puts IPN requests from the *PayPal sandbox* into the *queue*.  The *router*
retrieves them.

Router
: Part of the gem running as a process on the development computer.  It retrieves IPNs from the *queue* and relays them
as requests to the *PayPal client*.

PayPal Client
: Part of the developer's business application that receives and processes IPN requests from (normally) the *PayPal sandbox*.
Of course, in this case, it will be receiving the requests from the *router* instead.

The sequence diagram shows how the messages are exchanged.

![Forwarder/Proxy](http://s3.hedgeye.com/dev_images/paypal_ipn_proxy/simple.svg)

Notice some assumptions that are implied from this flow:

1.  This setup assumes that all requests are successful.  This is a tradeoff to prevent the multiple hops and router queuing
    from inadvertently timing out the PayPal sandbox's request.  Hence, for this reason, the *server* completes the HTTP cycle
    as soon as it's stored the IPN into the queue.

1.  While the *server* is filling the *queue*, the *router* is polling the *queue* to see if any IPNs have arrived for it to retrieve.
    If there is, then the *router* retrives it, pops it off the *queue* so that it isn't reused, and passes it via
    an HTTP request to the *PayPal client*.  The *PayPal client*'s response is accepted as "good".  We're considering an
    enhancement in which whether the response should be `success` or `failure` can be programmed into the *server*/*queue* to
    test the `failure` path.

Ultimately, you probably have multiple development computers that you'd like to have a PayPal sandbox for
each one.  The *server* can manage multiple connections; this will be described later.

## Features

1.  This Sinatra app only needs to be set up once to handle multiple PayPal sandboxes
    and multiple development machines.
1.  PayPal IPN's received while the target development machine is unavailable are responded to with a success
    response by this app.  The resulting IPN record is queued until the development machine's IPN handling
    process comes on line at which time the queued acknowledges requests are forwarded to the local machine's
    handling process.  The local machine's response is silently discarded by the Sinatra app.

## Requirements

If you have these resources, then this project may be useful to you:

1. A publicly-facing server that can host this project's Sinatra gem. Both your PayPal sandbox and development
   computer must be able to perform HTTP requests against this server.

1. This server must have a Ruby 1.9 or later to run this project with, and must be able to accept
   gems (such as [Sinatra](https://github.com/sinatra/sinatra/#readme)).

## Installation

You will need the identifiers for your PayPal sandboxes and your corresponding
development computers as follows:

### PayPal Sandbox ID

For this, you can identify this in the IPN in the `receiver_email`.

### Development Machine ID

Invent a unique development "name" for each development computer that you want to hook up to a PayPal sandbox.

### Assemble a config.ru file:

On your server, put together this `config.ru` Ruby task:

      require 'paypal-ipn-proxy'

      # Gotta have some kind of security; this is the cheapest.
      # Feel free to use something more rigorous.
      use Rack::Auth::Basic, YARD_SERVER_TITLE_FOR_LOGIN do |username, password|
        username == 'admin' and password == 'admin'  # Please use creds more challenging than these
      end

      MAP = {
        # PayPal Sandbox ID               => Your target development computer name
        'paypal_1362421868_biz@gmail.com' => 'joe blow\'s machine'

      }
      run PaypalIpnProxy.new(MAP)

### Configure the IPN address in your PayPal sandbox(es).

In each PayPal sandbox, configure the *server*'s URL for PayPal to send the IPN messages to.

TODO: provide information on where to do this in PayPal, at least a link.

### Configure the Router Component on Each Development Computer

This consists of installing the *router* gem and configuring it with the development computer's
"name" described above so that the queue knows which IPNs belong to it.

### Run on Your Server

_NOTE: Recommend using `thin` if you are using more than one PayPal sandbox._

On your server:

      rackup -p <whatever port is set up to receive the PayPal IPN messages> -s thin

### Start your Development computer's server that talks w/ its PayPal sandbox

When you set up recurring payments on PayPal, PayPal will start sending IPN notifications to you whenever
it deems necessary.  This will happen, among other activities, when it notifies you that it charged
a credit card or that someone issued a refund on the PayPal sandbox side.

## Future Features

1.  Find a way to configure one PayPal sandbox to service multiple development machines.
