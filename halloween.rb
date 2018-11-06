#!/usr/bin/ruby
# Written by Sourav Goswami!
# GNU General Public License v3.0

require 'ruby2d'

def main
	$width, $height = 640, 480
	set title: "Happy Halloweens Day", resizable: true, fps_cap: 45

	house = Image.new 'background.png', width: $width, height: $height, z: -500

	pumpkin = Image.new 'pumpkin.png', width: 154, height: 159, color: 'black'
	pumpkin.x, pumpkin.y = 0, $height - pumpkin.height

	pumpkin2 = Image.new 'pumpkin.png', width: 154, height: 159, color: 'black'
	pumpkin2.x, pumpkin2.y = $width - pumpkin2.width, pumpkin.y

	lantern = Image.new 'lantern.png', z: -100, color: '#ffff00'
	lantern.width /= 10
	lantern.height /= 10
	lantern.y = $height - lantern.height - 60
	lantern.x = $width - lantern.width - 100

	bg = Rectangle.new width: $width, height: $height, color: %w(#000055 #000055 #0000aa #0000aa), z: -1000

	Rectangle.new width: 20, height: 15, x: 310, y: 70, z: house.z - 1, color: 'yellow'

	window1 = Rectangle.new width: 35, height: 15, x: 230, y: 205, z: house.z - 1, color: %w(#ff0000 #ff0000 #005500 #002200)

	window2 = Rectangle.new width: 20, height: 35, x: 310, y: 185, z: house.z - 1, color: %w(#ff0000 #ffff00 #000000 #000000)

	stars, circles, circles2, circles3 = [], [], [], []

	# Draw the halloween fires!
	50.times do |i|
		circle = Circle.new radius: i, color: '#ffff00', z: -i
		circle.color = i < 32 ? '#ffffff' : '#ffff00'
		circle.x, circle.y = pumpkin.x + pumpkin.width/2, pumpkin.y + pumpkin.height - i - 10
		circle.opacity = (65.5 - i)/120
		circles << circle

		circle = Circle.new radius: i, color: '#ffff00', z: -i
		circle.color = i < 32 ? '#ffffff' : '#ffff00'
		circle.x, circle.y = pumpkin2.x + pumpkin2.width/2, pumpkin2.y + pumpkin2.height - i - 10
		circle.opacity = (65.5 - i)/120
		circles2 << circle
	end

	# Particles on the black grass (bg image)
	grasses = []
	100.times do |i|
		grasses << Square.new(x:rand(0..$width), y: rand($height - 50..$height), size: rand(1..2), z: -100, color: %w(#3ce3b4 #ffffff).sample)
	end

	# Draw the fires (drawn while moving the mouse), fire_base is its variable
	fire_base = []
	30.times do |i|
		circle = Circle.new radius: i, y: i
		circle.color, circle.z = i < 20 ? '#fefffd' : '#ffff00', -i + 150
		circle.opacity = (30.0 - i)/50
		fire_base << circle
	end

	# Draw the bigger stars
	20.times do
		posx, posy = rand(0..$width), rand(0..$height)
		0.step(1, 0.2) do |i|
			circle = Circle.new radius: i * 2, color: '#ffff00', z: -100
			circle.color = i < 0.5 ? '#ffffff' : '#ffff00'
			circle.x, circle.y = posx, posy
			stars << circle
		end
	end

	light = []
	18.times do |i|
		l = Circle.new radius: i
		l.color = '#fdffff'
		l.opacity = (18.0 - i)/50
		l.x, l.y = lantern.x + lantern.width/2, lantern.y + 20
		light << l
	end

	# Declare movex, and movey to store the cursor position
	movex, movey = 0, 0

	# fire_particles stores all the fires that are drawn while moving the cursor
	fire_particles = []
	350.times do |i|
		circle = Circle.new radius: rand(1..12), x: 100, y: 100, z: -i + 200
		circle.color = %w(#ffff00 #ffffff).sample
		circle.opacity = (i/20.0)
		fire_particles << circle
	end

	# smokes are drawn below the haunted house
	smoke, speed = [], []
	150.times do
		pixel = Square.new size: 1, x: rand(0..$width), y: rand(0..$height - 100), color: 'gray', z: -505
		smoke << pixel
		speed << rand(3.0..10.0)
	end

	eye_particles = []
	20.times do
		circle = Circle.new z: -100, radius: rand(5..10), y: rand($height - rand(26..40))
		circle.x = [rand(pumpkin.x + 40..pumpkin.x + pumpkin.width - 40), rand(pumpkin2.x + 40..pumpkin2.x + pumpkin2.width - 40)].sample
		circle.color = "#ffffff"
		eye_particles << circle
	end

	on :key_down do |k| exit if %w(escape p q).include?(k.key) end
	on :mouse_move do |e|
		movex, movey = e.x, e.y
		particle = fire_particles.sample ; particle.x, particle.y = e.x, e.y
		fire_base.each do |particle| particle.x, particle.y = e.x, e.y end
	end
	i = 0

	update do
		i += 1

		# flash the light of the house randomly, give the haunted house look and feel
		house.color = [true, [false] * 3].flatten.sample ? '#000000' : '#ffffff'
		window1.color = [true, false].sample ? '#ffff00' : %w(#ff0000 #ff0000 #005500 #002200)
		window2.color = [true, [false] * 3].flatten.sample ? %w(#ff0000 #ffff00 #000000 #000000 ) : 'black'

		# flash the lantern
		light.each do |l|
			l.r = [true, [false] * 3].flatten.sample ? 0 : 1
			l.b = [true, [false] * 6].flatten.sample ? 0 : 1
		end

		# flash the stars
		for circle in stars do circle.opacity = [0, 1].sample end

		smoke.each_with_index do |pixel, index|
			pixel.y -= speed[index]
			pixel.x += Math.sin(i/rand(1..10))
			pixel.x, pixel.y = rand(0..$width), rand(0..$height - 100) if pixel.y <= 0
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
				particle.y -= 8
				particle.x += Math.sin(i/rand(1..3))
				particle.radius -= rand(1..2)
				particle.opacity -= 0.05

				if particle.radius <= 0
					particle.x, particle.y = rand(movex - 10..movex + 10), rand(movey - 10..movey + 10)
					particle.radius = rand(1..12)
					particle.opacity = 1
				end
		end

		grasses.sample.opacity = [1 ,0].sample if Time.new.strftime('%N')[0].to_i % 2 == 0

		fire_base.each do |particle|
			particle.x = movex + Math.cos(i)
			particle.y = movey + Math.sin(i)
		end

		for val in 0...circles.size
			circle = circles[val]
			circle.x += Math.sin(i/6.0)
			circle.y += Math.cos(i/3.0) * 3

			circle = circles2[val]
			circle.x += Math.sin(i/5.0)
			circle.y += Math.cos(i/2.5) * 3
		end
	end
	show
end
main
