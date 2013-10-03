# Cloud-Native DevOps. v1b

## me

* Digg in 2010
    * used puppet
    * owned hardware in a local DC
    * puppet ran on a timer
    * beautiful
* first experienced chef at CloudScaling in 2011
    * using it to provision clusters of OpenStack
    * tftp pxe boot to run chef
    * decided to use chef-solo because we didn't have anywhere to provision chef-server
* came to Simple where we use Chef and chef-server for the most part


## Chef at Simple
* We run entirely in AWS
* use a fairly stripped down version of chef
    * chef-server
    * rarely roles
    * no environments
    * production attributes.rb committed to master
        * trying to work with attribute precedence rules is too complicated

## Considering the utility of chef

* let's talk about what chef is doing
    * cookbooks stored in Github
    * on push to master, start a Jenkins job
    * Jenkins publishes the cookbook to chef-server
    * every instance is configured to run chef-client every 15min or so
    * so far a good rhythm
    * cheap CI. Ignoring tests, code gets deployed in &lt; 15 minutes

* But
    * We have roughly 200 instances.
        * Not a huge load, but it does make you realize that there are 13 opportunities a minute for something to go wrong
    * What type of thing are we worried about going wrong?
        * As I mentioned earlier, clobbering attributes accidentally is worrying
        * if chef-server goes down, we have no capacity to deploy
        * mutating state nondeterministically 800 times an hour should scare you

* Why do we mutate state?
    * These operations are one way. No commutative property means rolling forward is the only option.
    * Even in the best case, when nothing has changed, idempotency is left to the cookbook maintainers.
        * "Oh that's why that web server restarts every 15 minutes..."
    * Applying the same work flow above to bare metal – you don't have any other choice.
      * except smartOS, docker, coreOS, etc.

## Say Cloud one more time! I dare you.
* "Cloud sucks, it's so expensive, it's so unreliable, the performance is so bad."
* The ops silver backs are defending their territory.
* Though there's some truth to the criticism, it's different in positive ways, too.

* Our thesis is that chef in the cloud is an anti-pattern.
    * When we start thinking about taking away the parts we don't like
        * live state mutation
        * chef-server SPOF
        * crazy configuration semantics
        * legacy of brutality
    * And start to look at replacing them with things we do like
        * Chef-solo to reduce dependencies
        * use ZooKeeper instead of search
        * and the linchpin of the whole system: pre-baked images (AMIs for us)

* Pre-baked AMIs
    * smart people like at smart companies already know this (Benjamin Black, Adrian Cockcroft)
    * decide what your instances will look like before you put them in to production
    * configure at build time any way you want
        * though we've reduced as many variables as possible.
    * 40-50 second boot time
    * same exact everything from development to staging to prod
    * no live state mutation

## Tool kit

* very lucky to have Packer getting stable.
* from the same guy that does vagrant, Mitchell Hashimoto
* Packer is a tool for generating images from conversion scripts
    * builders
        * EC2 (ebs, instance, chroot), OpenStack, VirtualBox, VMWare
    * provisioners
        * chef, puppet, bash, saltstack
* The same code creates artifacts for the whole work flow: dev -> stage -> prod
* Anyone can download an image and run it in vagrant.


## Lean in
### Orient: you are not in kansas any more.
* The utility of AWS doesn't end here
* The way to deploy changes becomes much safer
* auto-scaling groups
    * System is now programatically defined. Sort of looks like a node...
    * ASGs allow us to treat instances as what they are: ephemeral
    * if an instance is sick, we can just kill it. The ASG will build a new one.
    * Deploys are amazing, too.
        * Our initial plan is to update the ASG configuration to use the latest AMI and slowly kill off the old instances. They'll be replaced with new ones
        * As an anecdote, Netflix deploy by spinning up a parallel infrastructure and adding it to the rotation. Canary tier built right in to the deploy system.

* Fringe benefits
    * Instance metadata is pretty powerful when you think about it
    * Our Bind9 cookbook queries our instances for their preferred domain names
        * same principal when we move it to AMI-based deploy.


## A note on bare metal

* AWS and chef are simply the oldest and therefor more built and accessible.
* I have confidence that projects like CoreOS, Docker, and SmartOS will turn applications into atomic components, facilitating the same kind of work flow as above.


## What's next
* I want to see a convergence tool that's slimmed down and purpose built for this.
