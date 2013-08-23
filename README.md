# A Proxy to Forward your PayPal Sandbox's IPN's to your Development Machine

## The Problem!

You can already set up PayPal sandboxes to interact with your credit-card and other monetary handlings.
Indeed, your development machine can "talk" directly w/ the sandbox.  However, if your production system
receives IPN notifications from PayPal, you have probably already encountered the following problem:

Can the PayPal sandbox "talk" directly to your development computer?  Not unless your development computer has a static IP address
(which many find problematic -- security concerns, etc) or a public domain.

![Blocked!](https://rawgithub.com/dostapenko/paypal-ipn-forwarder/master/doc/seq_diagrams/blocked.svg)

Hence, if not, then you know you are unable to do "end-to-end" testing because you cannot test the PayPal IPN
notification.

So, you're stuck, unless you can find a way to forward PayPal sandbox IPN addresses to your development computer.

## The Solution!

In addition to setting up this tool, you need a public facing *server*.  A cloud-based server
such as Heroku will work fine. The gem in this project will operate as a Sinatra
server app to receive and queue the PayPal IPN requests on the server.

The gem will be run on you development machine as well; it will
send HTTP requests to this public facing server app to retrieve the
IPN records in the *server app*'s queue.  For each IPN record retrieved, the gem will
forward it to your PayPal client as though PayPal had sent it directly.

Your PayPal client will need to be modified in order to not send out responses to the PayPal sandboxes.

### In More Detail

There are three main components which interact in order to make this process work: **Paypal**,
**Server**, and the **Development Computer**

This gem implements a Sinatra server that stores the *PayPal sandbox* notification IPNs into a queue.
When the *Development Computer* requests a notification IPN, this server pops the oldest one from the
queue and returns it.

This Sinatra app must run on a server exposed to both the *PayPal sandbox* and the *Development Computer*.

####Development Computer


The *Development Computer* is the local machine that a developer uses for everyday work.
It needs to have a internet connection with the *server*.

Inside the *development computer* is the **PayPal Client**, the
part of the developer's business application
that receives and processes IPN requests from (normally) the *PayPal sandbox*.
But, in this case, it will be receiving the requests from the *router* instead.

The **router** is a daemon that retrieves notification IPNs from the *server*'s *queue* and relays them
as requests to the developer's *payPal client*.

#### How the messages are exchanged

![Forwarder/Proxy](https://rawgithub.com/dostapenko/paypal-ipn-forwarder/server_client_fleshing/doc/seq_diagrams/simple.svg)

Notice some assumptions that are implied from this flow:


1.  This setup assumes that all requests are successful.
    This is a tradeoff to prevent the multiple hops and router queuing
    from inadvertently timing out the PayPal sandbox's request.
    Hence, for this reason, the *server* completes the HTTP cycle

    as soon as it's stored the IPN into the queue.

1.  The *PayPal client*'s response is muted. Usually, once the *PayPal client* receives an IPN,
    it conducts a handshake with PayPal to make sure that the IPN is valid. This is not performed during testing
    because, as noted above, it introduces too much timing variability for the handshake.

1.  Lastly, note that the *queue* is part of the *server* and is not run outside or independently of the *server*.


Ultimately, you probably have multiple development computers that you'd like to have a PayPal sandbox for
each one.  The *server app* can manage multiple connections; this will be described later.

## Features

1.  This Sinatra app only needs to be set up once to handle multiple PayPal sandboxes
    and multiple development machines.
1.  PayPal IPNs received while the target development machine is unavailable are responded to with a success
    response by this app.  The resulting IPN record is not queued.

## Prerequisites

If you have these resources, then this project may be useful to you:

1. A publicly-facing server that can host this project's Sinatra gem. Both your PayPal sandbox and development
   computer must be able to perform HTTP requests against this server.

1. This server must have a Ruby 1.9 or later to run this project with, and must be able to accept
   gems (such as [Sinatra](https://github.com/sinatra/sinatra/#readme)).

## Installation

You will need the identifiers for your PayPal sandboxes and your corresponding
development computers as follows:

### PayPal Sandbox ID

For this, you can use the `Secure Merchant Id` located which can be found in the PayPal sandbox. In the
profile tab, it is the second item which is presented.

### Development ID

For this, the developer's email is used in order to deliver some notifications and identify the developer.

### Assemble a config.ru file:

On your server, put together this `config.ru` Ruby task:

```ruby
require 'paypal-ipn-proxy'

# Gotta have some kind of security; this is the cheapest.
# Feel free to use something more rigorous.
use Rack::Auth::Basic, 'PayPal IPN Forwarder' do |username, password|
  username == 'admin' and password == 'admin'  # Please use creds more challenging than these
end

run PaypalIpnProxy.new
```
*NOTE: Actually, we need to update this to have the user* **modify** *the sample config.ru.*

### Configure the IPN address in your PayPal sandbox(es).

In each PayPal sandbox, configure the server's URL for PayPal to send the IPN messages to.

[PayPal's guide](https://cms.paypal.com/cms_content/CA/en_US/files/developer/IPNGuide.pdf) describes
how to do this in section 3 on page 23.

### Configure the Router Component on Each Development Computer

This consists of installing the *router* gem and creating two aliases
so that the developer does not have to find the id of the
Sandbox every time that they run the gem.

The aliases should be saved in a bash config file (or equivalent) using:

```bash
alias paypal_testing_on='ruby start_paypal sandbox_id developer_id'
alias paypal_testing_off='ruby stop_paypal sandbox)id developer_id'
```

where `sandbox_id` is the id of the sandbox that the developer will be using
and `developer_id` is the email of the developer.

#### Running the Router

To start the *router*:

     paypal_testing_on

To stop:

     stop

If you inadvertently `control-c` out of the terminal window, that will not stop the process.
In this case, in another terminal you can stop the *router* process by:

     paypal_testing_off

### Run on Your Server

_NOTE: Recommend using `thin` if you are using more than one PayPal sandbox._

On your server:

      rackup -s thin

Note that PayPal only allows their test sandbox to talk to port 80.

_NOTE: The server gem sends out emails when errors occur. In order to make sure that they are sent to your inbox
and not stuck in the spam folder, hit the url of the server with the extensions '/test_email' with the email as a parameter and mark the email that
will be received in your inbox as "not spam".

To assemble the url to trigger the test email, use the url of the forwarder, then add '/test_email' followed by '?' and the email. But, the '@'
symbol of the email must be replaced with '%40'. So an email of 'bob@example.com' would have a url of 'url.com/test_email?bob%40example.com'

### Start your Development computer's Router that talks with the server app


Using the alias, run the gem on the Developer's computer. Once started, the gem will alert the developer
if something goes wrong in that terminal window.

### Start your Development computer's server that talks w/ its PayPal sandbox

When you set up recurring payments on PayPal, PayPal will start sending IPN notifications to you whenever
it deems necessary. This will happen, among other activities, when it notifies you that it charged
a credit card or that someone issued a refund on the PayPal sandbox side.

## Capabilities

The gem can handle any reasonable number of Sandbox's running at the same time. Below, is a big picture explanation of
how it occurs:

![2_Developers!](https://rawgithub.com/dostapenko/paypal-ipn-forwarder/server_client_fleshing/doc/seq_diagrams/multiple.svg)

However, two developers can not be using the same sandbox. If this occurs, both users will have their testing session
turned off on the *server app* and an email will be sent to both of them.

### Router interactions

The following flow diagrams illustrate the interactions that the router partakes in:

![No IPN!](https://rawgithub.com/dostapenko/paypal-ipn-forwarder/server_client_fleshing/doc/seq_diagrams/router_server.svg)

If there is an IPN, the following occurs:

![IPN!](https://rawgithub.com/dostapenko/paypal-ipn-forwarder/server_client_fleshing/doc/seq_diagrams/router.svg)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

