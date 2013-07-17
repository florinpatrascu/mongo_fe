# MongoFe

This is a simple Sinatra based web front-end that can be used for experimenting and learning MongoDB. The MongoFe gem can also be used for simple administrative tasks, managing collections and document basic operations such as: create new documents, delete existing ones, search by various criteria and document indexing.

### Installation

    $ gem install mongo_fe

### Credentials

Create a file in your home directory called: `.mongo_fe`

In this file add the following:

    uri: mongodb://localhost:27017

Examples:

    uri: mongodb://nemo:clownfish@ds02231897.mongolab.com:33897/Reef
    
### Usage

Verify first that you have access to a MongoDB instance. [See the install guides](http://www.mongodb.org/display/DOCS/Quickstart/), if need be. I used the [Homebrew](http://mxcl.github.com/homebrew/) package manager to install mongodb. If you have Homebrew, run the following commands:

    $ brew update
    $ brew install mongodb

To start the MongoFe web server:

    $ mongofe

or you can start the web server pointing it to a remote MongoDB url, example:

    $ mongofe -C mongodb://sheppard:arterius@masseffect3.mongolab.com:33897/datamelee
    $ mongofe -C mongodb://Genetically:Enhanced@"spiritual_successor.mongohq.com:10075/BioShock

(fictive links, real syntax)

MongoFe works well with remote MongoDB instances, see: [mongolab.com](https://mongolab.com/home) or [mongohq.com](https://mongohq.com), for example.
    
To stop the server:

    $ mongofe -K

### Screenshots

In the mean time, I'd love for you to check out these screenshots to get a feel for MongoFe and see some of the administrative interfaces designed to make your day to day tasks easier.

**database info**
![Database info](https://img.skitch.com/20120716-g4cbs3yrrwifa5pscnafitw3hw.png)

**documents query and management**
![Documents view](screens/example_doc_view.png)

**index management**
![Indexes view](https://img.skitch.com/20120716-c7bwmw31wr3kmsb9ebsufhsrtj.png)

Have fun!


### Contributing

* Fork it
* Create your feature branch (``git checkout -b my-new-feature``)
* Add some tests and please make sure they pass
* Commit your changes (``git commit -am 'Added some feature'``)
* Push to the branch (``git push origin my-new-feature``)
* Create new Pull Request

### License
MIT License
    
