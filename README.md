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

### TODO Crop an image

### TODO Crop an image, then save metadata to JackSON

## Sidekiq monitor

imgup uses Sidekiq to run background processes.
Sidekiq has a monitoring web-application.
Start it by running...

	rake monitor

Then in your browser go to...

	localhost:9494

The rake process must be running.
Ending the rake process will kill the web-server.