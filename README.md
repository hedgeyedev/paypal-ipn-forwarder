# A Proxy to Forward your PayPal Sandbox's IPN's to your laptop

You can already set up PayPal sandboxes to interact with for your credit-card and other monetary handlings.
Indeed, your development machine can "talk" directly w/ the sandbox.  However, if your production system
receives IPN notifications from PayPal, you have probably already encountered the following problem:

Can the PayPal sandbox "talk" directly to your laptop?  Not unless your laptop has a static IP address
(which many find problematic -- security concerns, etc) or a public domain.

Hence, if not, then you know you are unable to do "end-to-end" testing because you cannot test the PayPal IPN
notification.

So, you're stuck, unless you can find a way to forward PayPal sandbox IPN addresses to your laptop.  That
is the purpose of this project.

## Features

1.  This Sinatra app only needs to be set up once to handle multiple PayPal sandboxes
    and multiple development machines.
1.  PayPal IPN's received while the target development machine is unavailable are responded to with a success
    response by this app.  The resulting IPN record is queued until the development machine's IPN handling
    process comes on line at which time the queued acknowledges requests are forwarded to the local machine's
    handling process.  The local machine's response is silently discarded by the Sinatra app.

## Requirements

If you have these resources, then this project may be useful to you:

1. A _Virtual Private Network_ (VPN) that your development machine is connected to.
1. On this network, you need to have an available server that you can set up a
   [Sinatra](http://www.sinatrarb.com/) application on.
1. This server must have a publicly exposed static IP or domain that is available for PayPal
   sandbox to send IPN HTTP requests to.  This must be available for your Sinatra sandbox to serve.
1. This server must have a Ruby 1.9 or later to run this project with, and must be able to accept
   gems (such as [Sinatra](https://github.com/sinatra/sinatra/#readme)).

## Installation

You will need the identifiers for your PayPal sandboxes and your corresponding
development laptops as follows:

### PayPal Sandbox ID

For this, you can identify this in the IPN in the `receiver_email`.

### Development Machine ID

This can be found in your development machine's network connection; simply identify its network address.

_Hint: if you can successfully use the development computer's network **name** instead of *IP*, that
will likely be more stable._

### Assemble a config.ru file:

On your server, put together this `config.ru` Ruby task:

      require 'paypal-ipn-proxy'

      # Gotta have some kind of security; this is the cheapest.
      # Feel free to use something more rigorous.
      use Rack::Auth::Basic, YARD_SERVER_TITLE_FOR_LOGIN do |username, password|
        username == 'admin' and password == 'admin'  # Please use creds more challengine than these
      end

      MAP = {
        # PayPal Sandbox ID => Your target development URL
        'paypal_1362421868_biz@gmail.com' => 'developmentmachine:9999/'

      }
      run PaypalIpnProxy.new(MAP)

### Configure the IPN address in your PayPal sandbox(es).

In each PayPal sandbox, configure the target URL for PayPal to send the IPN messages to.

TODO: provide information on where to do this in PayPal, at least a link.

### Run on Your Server

_NOTE: Recommend using +thin+ if you are using more than one PayPal sandbox.

On your server:

      rackup -p <whatever port is set up to receive the PayPal IPN messages> -s thin

### Start your Laptop server that talks w/ its PayPal sandbox

When you set up recurring payments on PayPal, PayPal will start sending IPN notifications to you whenever
it deems necessary.  This will happen, among other activities, when it notifies you that it charged
a credit card or that someone issued a refund on the PayPal sandbox side.

### Future Features

1.  Find a way to configure one PayPal sandbox to service multiple development machines.
