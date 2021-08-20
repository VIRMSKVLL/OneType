# * -------------------------------------------------------------------------------------                                                                                                                                                      
# * Window Message Config
# ? Read the Documentation for more info --> https://github.com/CryroFox/OneType/wiki/Config
# * -------------------------------------------------------------------------------------               

# TODO add the little sprite cursor arrow at the bottom of the box :P


class Window_Message < Window_Selectable
	BLIP_TIME = 4
	def config
		
		# * Window Positions
		# -------------------#
		@TopY = 16
		@MiddleY = 160
		@BottomY = 336
		
		# * \c[#] Colours
		# -------------------#
		@colours = [
			Color.new(255, 255, 255, 255),		#> 0 <#
			Color.new(255, 64, 64, 255),		#> 1 <#
			Color.new(0, 224, 0, 255),		#> 2 <#
			Color.new(255, 255, 0, 255),		#> 3 <#
			Color.new(64, 64, 255, 255),		#> 4 <#
			Color.new(255, 64, 255, 255),		#> 5 <#
			Color.new(64, 255, 255, 255),		#> 6 <#
			Color.new(128, 128, 128, 255),		#> 7 <#
		]
		
		# * Blip Properties
		# -------------------#
		@Blips = { 
			1 => 'text',
			2 => 'text_robot',
		}
		
		@Blip_Prefixes = {
			'[' => 'text_robot',
		}
		
		@Blip_Faces = {

		}
		
		@Blip_Ranges = {
			'text' => 100..100,
			'text_robot' => 100..100,
		}
		
		# * Misc Properties
		# -------------------#
		@MessageCursor = false
		@BlipFolder = 'SE'
		
	end
	
	# * Text Effects
	# -------------------#
	def charAnimate(i)
		spr= @characters[i]
		effect = @letters[i][:Effect]
		initX= @letters[i][:InitX]
		initY= @letters[i][:InitY]
		color= @letters[i][:Color]
		c= @letters[i][:Char]
		
		case effect
			
		when 0 # ? Reset effect
			return
			
		when 1 # ? Shaky
			spr.x = initX + rand(-1..1)
			spr.y = initY + rand(-1..1)
			
		when 2 # ? Wavy
			@letters[i][:Extra] = {Pos: i * 2} if @letters[i][:Extra] == {}
			@letters[i][:Extra][:Pos] += 0.0015
			spr.y = initY + Math.sin(@letters[i][:Extra][:Pos] * 100) * 3
		
		when 3 # ? Rainbow
			@letters[i][:Extra] = {Shift: 0} if @letters[i][:Extra] == {}
			@letters[i][:Extra][:Shift] += 0.001
			@letters[i][:Extra][:Shift] = 0 if @letters[i][:Extra][:Shift] > 0.3
			frequency = i
			ii = @letters[i][:Extra][:Shift]
			red= Math.sin(frequency * ii + 0 + 0.30) * 127 + 128
			green = Math.sin(frequency * ii + 2 + 0.30) * 127 + 128
			blue= Math.sin(frequency * ii + 4 + 0.30) * 127 + 128
			spr.bitmap.font.color = Color.new(red,green,blue,255)

		when 4 # ? Rainbow Wavy
			@letters[i][:Extra] = {Pos: i * 2, Shift: 0} if @letters[i][:Extra] == {}
			@letters[i][:Extra][:Pos] += 0.0015
			@letters[i][:Extra][:Shift] += 0.0005
			@letters[i][:Extra][:Shift] = 0 if @letters[i][:Extra][:Shift] > 0.3
			frequency = i
			ii = @letters[i][:Extra][:Shift]
			red= Math.sin(frequency * ii + 0 + 0.30) * 127 + 128
			green = Math.sin(frequency * ii + 2 + 0.30) * 127 + 128
			blue= Math.sin(frequency * ii + 4 + 0.30) * 127 + 128
			spr.bitmap.font.color = Color.new(red,green,blue,255)
			spr.y = initY + Math.sin(@letters[i][:Extra][:Pos] * 100) * 3
			
		when 5 # ? Flickering
			@letters[i][:Extra] = {Timer: rand(0..5)} if @letters[i][:Extra] == {}
			@letters[i][:Extra][:Timer] -= 1 if @letters[i][:Extra][:Timer] != 0
			if @letters[i][:Extra][:Timer] == 0
				r = rand(0..1)
				spr.opacity = (r == 1 ? 100 : 255)
				@letters[i][:Extra][:Timer] = rand(0..5)
			end
			
		end
		spr.bitmap.draw_text(0, 0, spr.bitmap.width, spr.bitmap.height, c) if spr.bitmap.font.color != Color.new(255,255,255,255)		
		end
	end
	
	# * -------------------------------------------------------------------------------------                                                                                                                                                      
	# * ED Message Config
	# ? Read the Documentation for more info --> https://github.com/CryroFox/OneType/wiki/Config
	# * -------------------------------------------------------------------------------------    
	class Ed_Message
		def config 
			
		# * \c[#] Colours
		# -------------------#
		@colours = [
			Color.new(255, 255, 255, 255),		#> 0 <#
			Color.new(255, 64, 64, 255),		#> 1 <#
			Color.new(0, 224, 0, 255),		#> 2 <#
			Color.new(255, 255, 0, 255),		#> 3 <#
			Color.new(64, 64, 255, 255),		#> 4 <#
			Color.new(255, 64, 255, 255),		#> 5 <#
			Color.new(64, 255, 255, 255),		#> 6 <#
			Color.new(128, 128, 128, 255),		#> 7 <#
		]
			
		end
		
		# * Text Effects
		# -------------------#
		def charAnimate(i)	
			spr= @characters[i]
			effect = @letters[i][:Effect]
			initX= @letters[i][:InitX]
			initY= @letters[i][:InitY]
			color= @letters[i][:Color]
			c = @letters[i][:Char]
			
			case effect
				
			when 0 # ? Reset effect
				return
				
			when 1 # ? Shaky
				spr.x = initX + rand(-1..1)
				spr.y = initY + rand(-1..1)
				
			when 2 # ? Glitch
				@temp = @temp_remem = nil if @temp_remem != @characters
				@temp_remem = @characters
				@temp = true if @characters[i] == @characters.last
				unless @temp == true
					r = rand(1..@characters.length)
					if r.between?(@characters.length / 2,@characters.length) || @letters[i][:Extra][:Ye] == true
						@letters[i][:Extra] = {Var: rand(0..5), Ye: true} if @letters[i][:Extra] == {} || @temp == false
					end
				end
				
				case @letters[i][:Extra][:Var]
				when 1
					spr.y = initY - 5
					spr.zoom_y = rand(1.0..1.5)
					spr.angle = rand(-5..5)
				when 2
					spr.vmirror = (rand(0..1) == 1) ? true : false 
				when 3
					if spr.angle >= 14
						spr.angle = 0
					elsif spr.angle <= -14
						spr.angle = 0
					end
					spr.angle += rand(-2..2)
				when 4
					spr.zoom_y = rand(1.2..1.4)
				when 5
					spr.x = initX + rand(-1..1)
					spr.y = initY + rand(-2..2)
				when 0
					spr.x = initX + rand(-2..2)
					spr.y = initY + rand(-1..1)
				end
				
			when 3 # ? Wavy
				@letters[i][:Extra] = {Pos: i * 2} if @letters[i][:Extra] == {}
				@letters[i][:Extra][:Pos] += 0.0015
				spr.y = initY + Math.sin(@letters[i][:Extra][:Pos] * 100) * 3
				
			when 4 # ? Rainbow Wavy
				@letters[i][:Extra] = {Pos: i * 2, Shift: 0} if @letters[i][:Extra] == {}
				@letters[i][:Extra][:Pos] += 0.0015
				@letters[i][:Extra][:Shift] += 0.0005
				@letters[i][:Extra][:Shift] = 0 if @letters[i][:Extra][:Shift] > 0.3
				frequency = i
				ii = @letters[i][:Extra][:Shift]
				red= Math.sin(frequency * ii + 0 + 0.30) * 127 + 128
				green = Math.sin(frequency * ii + 2 + 0.30) * 127 + 128
				blue= Math.sin(frequency * ii + 4 + 0.30) * 127 + 128
				spr.bitmap.font.color = Color.new(red,green,blue,255)
				spr.y = initY + Math.sin(@letters[i][:Extra][:Pos] * 100) * 3
				
			end
			
			
			spr.bitmap.draw_text(0, 0, spr.bitmap.width, spr.bitmap.height, c) if spr.bitmap.font.color != Color.new(255,255,255,255)	
		end
	end
