#!/usr/bin/ruby -w
# Written by Sourav Goswami!
# GNU General Public License v3.0
require 'ruby2d'
PATH = File.dirname(__FILE__)
STARS = 200
GRASS_PARTICLES = 100
FIRE_PARTICLES = 250

define_method(:main) do
	$width, $height = 640, 480
	set(title: "Happy Halloweens Day", resizable: true, fps_cap: 45, icon: File.join(PATH, 'icon.png'), width: $width, height: $height)

	house = Image.new(File.join(PATH, 'background.png'), width: $width, height: $height, z: -500)

	# Draw the pumpkin images
	pumpkin = Image.new(File.join(PATH, 'pumpkin.png'), width: 154, height: 159, color: 'black')
	pumpkin.x, pumpkin.y = 0, $height - pumpkin.height

	pumpkin2 = Image.new(File.join(PATH, 'pumpkin2.png'), width: 154, height: 159, color: 'black')
	pumpkin2.x, pumpkin2.y = $width - pumpkin2.width, pumpkin.y

	# check if any pumpkin is touched or not.
	pumpkin_touched, pumpkin2_touched = false, false

	# Create the lamp post image!
	lantern = Image.new(File.join(PATH, 'lantern.png'), z: -100, color: '#ffff00')
	lantern.width /= 10
	lantern.height /= 10
	lantern.y = $height - lantern.height - 60
	lantern.x = $width - lantern.width - 100
	light = Array.new(20) { |i| Circle.new(radius: i, color: '#FFFFFF', opacity: (18.0 - i) / 50, x: lantern.x + lantern.width / 2, y: lantern.y + 20) }

	# Background
	Rectangle.new(width: $width, height: $height, color: %w(#000055 #000055 #0000aa #0000aa), z: -1000)

	# window of the house
	window1 = Rectangle.new(width: 35, height: 15, x: 230, y: 205, z: house.z - 1, color: %w(#ff0000 #ff0000 #005500 #002200))
	window2 = Rectangle.new(width: 20, height: 35, x: 310, y: 185, z: house.z - 1, color: %w(#ff0000 #ffff00 #000000 #000000))
	Rectangle.new width: 20, height: 15, x: 310, y: 70, z: house.z - 1, color: %w(#FFFF00 #FF0000 #FF00FF  #0000FF)

	# Draw the halloween fires!
	circles, circles2 = [], []
	50.times do |i|
		circles << Circle.new(radius: i, z: -i, color: i < 32 ? '#ffffff' : '#ffff00', x: pumpkin.x + pumpkin.width / 2, y: pumpkin.y + pumpkin.height - i - 10, opacity: (65.5 - i) / 120)
		circles2 << Circle.new(radius: i, z: -i, color: i < 32 ? '#ffffff' : '#ffff00', x: pumpkin2.x + pumpkin2.width / 2, y: pumpkin2.y + pumpkin2.height - i - 10, opacity: (65.5 - i) / 120)
	end

	# Particles on the black grass (bg image)
	grasses = Array.new(GRASS_PARTICLES) { Square.new(x:rand(0..$width), y: rand($height - 50..$height), size: rand(1..2), z: -100, color: %w(#3ce3b4 #ffffff).sample) }

	# Draw the fires (drawn while moving the mouse), fire_base is its variable
	fire_base = Array.new(30) { |i| Circle.new(radius: i, y: i, color: i < 20 ? '#ffffff' : '#ffff00', z: 150, opacity: (30.0 - i) / 50) }

	# Draw the bigger stars
	stars = []
	15.times do
		posx, posy = rand(0..$width), rand(0..$height)
		stars.concat(0.step(1, 0.2).map { |i| Circle.new(radius: i * 2, z: -1000, color: i < 0.5 ? '#ffffff' : '#ffff00', x: posx, y: posy) })
	end

	# Declare movex, and movey to store the cursor position
	movex, movey = 0, 0

	# fire_particles stores all the fires that are drawn while moving the cursor
	fire_particles = Array.new(FIRE_PARTICLES) { |i| Circle.new(radius: rand(1..12), x: 100, y: 100, z: -i + 200, color: %w(#FFEF00 #FFFFFF #FFFF00).sample, opacity: (i / 20.0)) }

	# small_stars are drawn below the haunted house
	small_stars = Array.new(STARS) { Square.new(size: 1, x: rand(0..$width), y: rand(0..$height - 100), color: '#FFFFFF', z: -505) }

	eye_particles = Array.new(20) do
		Circle.new(z: -100, radius: rand(5..10), y: $height, color: "#ffffff",
			x: [rand(pumpkin.x + 40..pumpkin.x + pumpkin.width - 40), rand(pumpkin2.x + 40..pumpkin2.x + pumpkin2.width - 40)].sample)
	end

	on :key_down do |k| exit if %w(escape p q).include?(k.key) end
	on :mouse_move do |e|
		movex, movey = e.x, e.y
		pumpkin_touched, pumpkin2_touched = pumpkin.contains?(e.x, e.y), pumpkin2.contains?(e.x, e.y)
	end
	i = 0

	update do
		i += 1

		# flash the light of the house randomly, give the haunted house look and feel
		house.color = [true, [false] * 3].flatten.sample ? '#000000' : '#ffffff'
		window1.color = [true, false].sample ? '#ffff00' : %w(#ff0000 #ff0000 #005500 #002200)
		window2.color = [true, [false] * 3].flatten.sample ? %w(#ff0000 #ffff00 #000000 #000000 ) : 'black'

		# flash the lamp
		light.each do |l|
			l.r = [true, false].sample ? 0 : 1
			l.b = [true, false].sample ? 0 : 1
		end

		# flash the stars
		stars.each { |val| val.opacity = [0, 1].sample }

		# Move the fire_base with mouse
		fire_base.each { |f| f.x, f.y = movex + Math.sin(i), movey + Math.cos(i) }

		small_stars.each_with_index do |pixel, index|
			pixel.y, pixel.opacity = pixel.y - index / (STARS / 10.0), [1, 0].sample
			pixel.x, pixel.y = rand(0..$width), $height if pixel.y <= 0
		end

		# Draw fires inside the curved eyes of the pumpkins
		eye_particles.each do |particle|
			particle.y -= 15
			if particle.y < pumpkin.y + 48
				particle.y = $height - rand(26..40)
				particle.x = [rand(pumpkin.x + 40..pumpkin.x + pumpkin.width - 40), rand(pumpkin2.x + 40..pumpkin2.x + pumpkin2.width - 40)].sample
			end
		end

		fire_particles.each do |particle|
				particle.y -= 10
				particle.x += Math.sin(i/rand(1..3))
				particle.radius -= rand(1..2)
				particle.opacity -= 0.05
				particle.x, particle.y, particle.radius, particle.opacity = rand(movex - 10..movex + 10), rand(movey - 10..movey + 10), rand(1..12), 1 if particle.radius <= 0
		end

		grasses.sample.opacity = [1 ,0].sample if Time.new.strftime('%N')[0].to_i % 2 == 0

		pumpkin_touched ? (pumpkin.r += 0.025 if pumpkin.r < 0.8) : (pumpkin.r -= 0.05 if pumpkin.r > 0)
		pumpkin2_touched ? (pumpkin2.r += 0.025 if pumpkin2.r < 0.8) : (pumpkin2.r -= 0.05 if pumpkin2.r > 0)

		(0...circles.size).each do |val|
			circles[val].x += Math.sin(i)
			circles2[val].x += Math.sin(i)
		end
	end
	"Happy::Halloween"
end

END { puts(main) || show }
