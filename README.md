# imgup

Server for storing images copied from your filesystem or over HTTP.

## Install

Get basics

	sudo apt-get update
	sudo apt-get install build-essential zlib1g-dev libssl1.0.0 libssl-dev git 

Install ruby environment
rbenv

	cd ~
	git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
	echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
	echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

ruby-build

	git clone https://github.com/sstephenson/ruby-build.git ~/ruby-build
	cd ~/ruby-build
	sudo ./install.sh

ruby

	source ~/.bash_profile
	rbenv install 2.1.3
	rbenv global 2.1.3
	rbenv rehash

ruby gems

	sudo apt-get install rubygems

bundler

	rbenv shell 2.1.3
	gem install bundler

Install ImageMagick dependencies

	sudo apt-get install checkinstall libx11-dev libxext-dev libpng12-dev libjpeg-dev libfreetype6-dev libxml2-dev
	sudo apt-get build-dep imagemagick'

Install ImageMagick

	wget http://www.imagemagick.org/download/ImageMagick-6.9.0-10.tar.gz
	tar -xzvf ImageMagick-6.9.0-10.tar.gz
	cd ImageMagick-6.9.0-10
	sudo ./configure
	sudo checkinstall
	sudo ldconfig /usr/local/lib

Install Redis 2.8

	sudo apt-get install python-software-properties
	sudo apt-add-repository ppa:chris-lea/redis-server
	sudo apt-get update
	sudo apt-get install redis-server

Install imgup

	mkdir -p /var/www/imgup
	git clone https://github.com/PerseusDL/imgup /var/www/imgup
	cd /var/www/imgup
	bundle install

Modify...

	imgup.conf.yml

... with custom settings if needed.

Build redis and sidekiq config files.

	rake config

## Start

	rake start

## Test

	bundle exec rake test

## RestClient examples

### Copy from filesystem

	RestClient.post(
      'http://your.imgup.server/upload',
      :file => '/fs/path/to/file.jpg'
    )

### Copy over HTTP

	RestClient.post(
	  'http://your.imgup.server/src',
	  :src => 'http://www.some.domain/path/to/file.jpg
	)

### Retrieve image

	RestClient.get( 'http://your.imgup.server/upload/2015/JAN/file.jpg' )

### Retrieve image exif data as JSON

	RestClient.get( 'http://your.imgup.server/upload/2015/JAN/file.jpg?cmd=exif' )

### Resize an image

	RestClient.post(
		'http://your.imgup.server/resize',
		:src => 'http://your.imgup.server/upload/2015/JAN/file.jpg',
		:max_width => 200,
		:max_height => 200
	)

### Resize an image, then save metadata to  JackSON

	RestClient.post(
		'http://your.imgup.server/resize',
		:src => 'http://your.imgup.server/upload/2015/JAN/file.jpg',
		:max_width => 200,
		:max_height => 200,
		:send_to => 'http://your.jackson.server/resize/urn:cite:resize:4342k,
		:json => File.read('file.json')
	)

Here's what my JSON file looks like.

	{
		"@context": {
			"urn": "http://data.perseus.org/collections/urn:",
			"cite": "http://www.homermultitext.org/cite/rdf/",
			"rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
			"dct": "http://purl.org/dc/terms/",
			"this": "https://github.com/PerseusDL/CITE-JSON-LD/blob/master/templates/img/SCHEMA.md#",
			"roi_x": {
				"@id": "this:roi_x",
				"@type": "xs:float"
			},
			"roi_y": {
				"@id": "this:roi_y",
				"@type": "xs:float"
			},
			"roi_width": {
				"@id": "this:roi_width",
				"@type": "xs:float"
			},
			"roi_height": {
				"@id": "this:roi_height",
				"@type": "xs:float"
			},
		},
		"@id": "urn:cite:resize.123758",
		"dct:type": "resize",
		"dct:references": "{{ src }}",
		"this:height": "{{ height }}",
		"this:width": "{{ width }}",
		"this:filetype": "jpg",
	}

imgup will replace the tags `{{ src }}` `{{ height }}` and `{{ width }}`.
and then save the JSON file to the path passed in `send_to`

## sidekiq monitor

imgup uses Sidekiq to run background processes.
Sidekiq has a monitoring web-app.
Start it by running...

	rake monitor

Then in your browser go to...

	localhost:9494

The `rake monitor` process must be running.
Ending the rake process will kill the web-server hosting the monitoring web-app.

## Run redis and sidekiq on system init

Write startup scripts

	rake sysinit

