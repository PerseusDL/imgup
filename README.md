# imgup

Server for storing images copied from your filesystem or over HTTP.

## Install

Install ImageMagick

	git clone https://github.com/caesarfeta/imgup /var/www/imgup
	bundle install

## Start

	rake redis
	rake sidekiq
	rake start

## RestClient examples

Copy from filesystem

	RestClient.post(
      'http://your.imgup.server/upload',
      :file => '/fs/path/to/file.jpg'
    )

Copy over HTTP

	RestClient.post(
	  'http://your.imgup.server/src',
	  :src => 'http://www.some.domain/path/to/file.jpg
	)

Retrieve image

	RestClient.get( 'http://your.imgup.server/upload/2015/JAN/file.jpg' )

Retrieve image exif data as JSON

	RestClient.get( 'http://your.imgup.server/upload/2015/JAN/file.jpg?cmd=exif' )

## Sidekiq monitor

imgup uses Sidekiq to run background processes.
Sidekiq has a monitoring web-application.
Start it by running...

	rake monitor

Then in your browser go to...

	localhost:9494

