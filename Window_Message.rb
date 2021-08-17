
class Window_Message < Window_Selectable	 
	attr_accessor :colours
	#-------------------------------------------------------------------------#
	# * Object Initialization
	#-------------------------------------------------------------------------#
	def initialize
		super(16, 336, 608, 128)
		self.contents = Bitmap.new(width - 32, height - 32)
		Language.register_text_sprite(self.class.name + "_contents", self.contents)
		
		self.visible = false
		self.z = 9998
		self.back_opacity = 210
		@opaque = true
		@fade_out = false
		
		# * Face Sprites
		@face = Sprite.new(@viewport)
		@face.bitmap = Bitmap.new(96,96)
		@face.x = 640 - 32 - 96
		@face.y = self.y + 16
		@face.z = 9999
		@face.opacity = 255
		
		# * Text drawing flags
		@text = nil
		@text_y = @text_x = 0
		@drawing_text = false # ? set to true when message text is drawing
		@skip_text = false
		@size = 20
		@bliprange = "100..100"
		@message_started = false
		
		# * text rendering variables
		@characters = []
		@letters = {}
		@pause = 0
		@face_frame = 0
		@cursor_height = 24
		@cursor_width_chop = 8
		@cursor_width_offset = 4
		@end_square = 0
		
		# * Temporary Text Modifyers
		@color = Color.new(255,255,255,255)
		@effect = 0
		@blipsound = "text"
		
		# * Number/Choices
		self.active = false
		self.index = -1
		@choice_start = -1
		@number_start = -1
		@blip = 0
		
		# * skip message proc if we have choices/numbers buffered
		@skip_message_proc = false
		
		config
	end
	
	#--------------------------------------------------------------------------
	# * Write_message
	#--------------------------------------------------------------------------
	def write_message
		@text = ""
		text = $game_temp.message_text
		reset
		# ? Handle Formatting
		# ? Substitute variables, actors, player name, newlines, etc
		text.gsub!(/\\v\[([0-9]+)\]/) do $game_variables[$1.to_i] end
			
			# add a space to the beginning of the player name to better deal with longer names in asian languages
			if (Language::FONT_WESTERN == Font.default_name)
				text.gsub!("\\p", $game_oneshot.player_name)
			else
				text.gsub!("\\p", " " + $game_oneshot.player_name)
			end
			
			text.gsub!("\\n", "\n")
			# Handle text-rendering escape sequences
			text.gsub!(/\\c\[([0-9]+)\]/, "\0[\\1]")
			text.gsub!("\\.", "\001")
			text.gsub!("\\|", "\002")
			text.gsub!("\\>", "\004")
			text.gsub!("\\*", "\010")
			text.gsub!(/\\f\[([0-9]+)\]/, "\005[\\1]")
			
			text.gsub!("\\@", "\003")
			text.gsub!(/\\s\[([0-9]+)\]/, "\006[\\1]")
			text.gsub!(/\\b\[([0-9]+)\]/, "\007[\\1]")
			
			# Finally convert the backslash back
			text.gsub!("\\\\", "\\")
			
			# ? Blit face graphic
			if $game_temp.message_face != nil
				$game_temp.message_face = $game_temp.message_face.start_with?("niko") ? "niko_gasmask" : "en_gasmask" if $game_player.character_name.end_with?("_gasmask")
				face = RPG::Cache.face($game_temp.message_face)
				@face.bitmap = face
			else
				@face.bitmap = nil
			end
			
			# ? Handle Newlines
			x = y = 0
			maxwidth = 608 - 12 - ($game_temp.message_face == nil ? 0 : 96)
			spacewidth = self.contents.text_size(" ").width
			text.split("\n").each do |line|
				line.split(" ").each do |word|
					# ?Get width of this word and insert a newline if it goes out of bounds
					width = self.contents.text_size(word.gsub(/(\000\[[0-9]+\]|\001|\002\005\004|\005\[[0-9]+\])/, "")).width
					width = 0 if word.include?("\003")
					
					if x + width > maxwidth
						@text << "\n"
						x = 0
						y += 1
						break if y >= 4
					end
					
					# Append word to list
					if x == 0
						@text << word
					else
						@text << " " << word
					end
					x += width + spacewidth
				end
				
				# Newline
				@text << "\n"
				x = 0
				y += 1
				break if y >= 4
			end
			
			# ? Append choices to the dialogue
			if $game_temp.choices != nil
				$game_temp.choices.each_with_index do |choice, i|
					@text.gsub!("\n", '') if @text.gsub!('‏ ', '') #ENSPACE
					@text << ' ' # ? EM QUAD ! || this is used as another null character lmao fuck me
					c = i > 0 ? "\n #{choice}" : " #{choice}"
					@text << c
					@text.gsub!(/\\c\[([0-9]+)\]/, "\0[\\1]")
					@text.gsub!(/\\f\[([0-9]+)\]/, "\005[\\1]")
				end
			end

			
			# ? Remove white-spaces and count the lines in cccase of a dialogue choice!
			@text.rstrip!
			lines = @text.empty? ? 0 : @text.count("\n") + 1
			
			if $game_temp.num_input_variable_id > 0
				lines = 0 if @text.gsub!('‏ ', '') #ENSPACE
				# Prepare number input, if it fits
				if lines < 3
					@number_start = lines
				else
					# Don't call the message callback till we get a number
					@skip_message_proc = true
				end
			end
			
			# ? Prepare renderer
			self.contents.clear
			self.contents.font.color = normal_color
			@text_y = @text_x = 0
			
			# ? Handle Blips
			@Blip_Prefixes.each do |key, value|
				@blipsound = value if text.start_with?(key)
			end
			
			unless $game_temp.message_face == nil
				@Blip_Faces.each do |key, value|
					@blipsound = value if $game_temp.message_face.start_with?(key)
				end
			end
			
			# ? Split text and start rendering
			@text = @text.split('')
			@drawing_text = true
	end
		
	#--------------------------------------------------------------------------
	# * Blip
	#--------------------------------------------------------------------------
	def blip
		return if @pause == -1 || $game_temp.message_window_showing == false || @text.nil?
		return @pause -= 1 if @pause != 0
		c = @text.shift
		return if c.nil?
		
		
		case c
		when "\n"
			@text_x = 0
			@text_y += 24
			return
		when "\000"
			@text = @text.join
			@text.sub!(/\[([0-9]+)\]/, "")
			color = $1.to_i
			if color >= 0 and color <= (@colours.length - 1)
				@color = @colours[color]
			end
			@text = @text.split('')
			return
		when "\001"
			@pause = 20
			return
		when "\002"
			@pause = 50
			return
		when "\003"
			@text = @text.join
			face_name = @text.slice!(/^[^\s]+ */).strip()
			$game_temp.message_face = face_name
			$game_temp.message_face = $game_temp.message_face.start_with?("niko") ? "niko_gasmask" : "en_gasmask" if $game_player.character_name.end_with?("_gasmask")
			face = RPG::Cache.face($game_temp.message_face)
			@face.bitmap = face
			@text = @text.split('')
			return
		when "\004"
			@pause = -1
			return
		when "\005"
			@text = @text.join
			@text.sub!(/\[([0-9]+)\]/, "")
			@effect = $1.to_i
			@text = @text.split('')
			return
		when "\006"
			@text = @text.join
			@text.sub!(/\[([0-9]+)\]/, "")
			@size = $1.to_i
			@text = @text.split('')
			return
		when "\007"
			@text = @text.join
			@text.sub!(/\[([0-9]+)\]/, "")
			@blipsound = @Blips[$1.to_i]
			@text = @text.split('')
			return
		when "\010"
			@skip_text = true
			@text = []
			return terminate_message
		when " " #EM Quad
			@cursor_offset = 24 unless $game_temp.message_text == '‏ '
			@choice_start = 0
			@item_max = $game_temp.choices.size
			@skip_text = true
			@blipsound = 'none'
			return
		end
		
		# ? Draw the new letter to the message box!
		spr = Sprite.new(@viewport)
		spr.bitmap = Bitmap.new(32, 32)
		spr.x = 37 + @text_x
		spr.y = self.y + 12 + @text_y
		spr.z = 99999
		spr.bitmap.font.color = @color
		spr.bitmap.font.size = @size
		spr.opacity = 255
		spr.bitmap.draw_text(0, 0, spr.bitmap.width, spr.bitmap.height, c)
		
		# ? Append the sprite and it's associated properties to the Array and hash
		@characters << spr
		@letters.store(@characters.length - 1, {Char: c, InitX: spr.x, InitY: spr.y, InitOpacity: spr.opacity, Color: @color, Effect: @effect, Extra: {}})
		@text_x += spr.bitmap.text_size(c).width
		
	end
	
	#--------------------------------------------------------------------------
	# * Update
	#--------------------------------------------------------------------------
	def update
		super
		if @MessageCursor == true
			@end_square += 1
			rect = Rect.new(8 + @text_x, 24 * @text_y + 3, 8, 16)
			self.contents.clear
			self.contents.fill_rect(rect, Color.new(255, 255, 255, @end_square < 15 ? 255 : 0))
			@end_square = 0 if @end_square > 30
		end
		blip
		
		if $game_temp.message_face != nil
			if File.exist? "Graphics/Faces/#{$game_temp.message_face}_1.png"
				@face_frame += 0.2
				@face_frame = 1 if !File.exist? "Graphics/Faces/#{$game_temp.message_face}_#{@face_frame.round}.png"
				face = RPG::Cache.face("#{$game_temp.message_face}_#{@face_frame.round}")
				@face.bitmap = face
			end
		end
		
		if @pause == -1
			self.pause = true
			if Input.trigger?(Input::CANCEL) || (Input.trigger?(Input::ACTION))
			@pause = 0  
			self.pause = false
			return
			end
		end
		$game_temp.message_text = '‏ ' if $game_temp.num_input_variable_id > 0 and $game_temp.message_text == nil
		if $game_temp.message_text != nil && !$game_temp.message_text.empty? && @drawing_text == false || $game_temp.choices != nil && @drawing_text == false and @message_started == false
			if $game_temp.choices != nil and $game_temp.message_text == nil
				$game_temp.message_text = '‏ ' # EN SPACE (really hacky standin that I don't think anyone will ever use)
			end
			@message_started = true
			@cursor_offset = 0 
			@fade_in = true
			self.visible = true
			@drawing_text = true
			write_message
		end
		
		if @skip_text == true
			for c in @characters do
				blip if @drawing_text == true
			end
			@skip_text = false
			return
		end
		
		if @drawing_text == true and @choice_start == -1
			return if @skip_text
			@bliprange = @Blip_Ranges[@blipsound]
			if @blip >= BLIP_TIME and @pause == 0
				#april fools
				t = Time.now
				unless @blipsound == 'none'
					if $game_temp.message_face != nil && t.month == 4 && t.day == 1 && $game_temp.message_face.start_with?("niko")
						niko_sounds = ["cat_2"]
						@blipsound = niko_sounds[rand(niko_sounds.length)]
						Audio.se_play("Audio/SE/#{@blipsound}.wav", 50, rand(100..125)) unless @text.empty?
					else
						Audio.se_play("Audio/#{@BlipFolder}/#{@blipsound}.wav", 50, rand(@bliprange)) unless @text.empty?
					end
				end
				@blip = 0
			else
				@blip += 1
			end
		end
		
		if @characters != []
			@characters.each_index do |index|
				charAnimate(index)
			end
		end
		
		# Handle fade-out effect
		if @fade_out
			self.opacity -= 48
			self.contents_opacity -= 48 * 2
			@face.opacity -= 48 * 2
			if self.opacity == 0
				@fade_out = false
				@face.bitmap = nil
				self.visible = false
				self.contents.clear
				$game_temp.message_window_showing = false
			end
			return
		end
		
		# Handle fade-in effect
		if @fade_in
			self.opacity += 48 if @opaque
			self.contents_opacity += 48
			@face.opacity += 48
			@input_number_window.contents_opacity += 48 if @input_number_window != nil
			if self.contents_opacity == 255
				@fade_in = false
				@drawing_text = true
				$game_temp.message_window_showing = true
			end
			return
		end
		
		@skip_text = true if Input.trigger?(Input::CANCEL) || (Input.trigger?(Input::ACTION) && @drawing_text) || (Input.press?(Input::R) && $game_switches[253])
		
		if @text == [] and self.active == false
			@drawing_text = false
			if @choice_start >= 0 and $game_temp.choices != nil
				# Setup and draw choices
				self.index = 0
				self.active = true
			end
		end
		if @number_start >= 0 and @input_number_window == nil
			# Setup numbers
			digits_max = $game_temp.num_input_digits_max
			number = $game_variables[$game_temp.num_input_variable_id]
			@input_number_window = Window_InputNumber.new(digits_max)
			@input_number_window.number = number
			@input_number_window.x = self.x + 8
			@input_number_window.y = self.y + @number_start * 24
		end
		
		# Handle user input
		if @choice_start >= 0
			# Cancel
			if Input.trigger?(Input::CANCEL) && $game_temp.choice_cancel_type > 0
				$game_system.se_play($data_system.cancel_se)
				$game_temp.choice_proc.call($game_temp.choice_cancel_type - 1)
				terminate_message
			elsif Input.trigger?(Input::ACTION)
				$game_system.se_play($data_system.decision_se)
				$game_temp.choice_proc.call(self.index)
				terminate_message
			end
		elsif @number_start >= 0
			rect = Rect.new(4 + @text_x, 24 * @text_y + 4, 8, 16)
			
			self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
			@input_number_window.update
			
			# Confirm
			if Input.trigger?(Input::ACTION)
				$game_system.se_play($data_system.decision_se)
				$game_variables[$game_temp.num_input_variable_id] = @input_number_window.number
				$game_map.need_refresh = true
				# Dispose of number input window
				@input_number_window.dispose
				@input_number_window = nil
				terminate_message
				@drawing_text = false
			end
			return
		else
			self.pause = true
			# ? Message is over and should be hidden or advanced to next
			if @text == nil
				if $game_temp.message_text == nil && $game_temp.choices == nil && $game_temp.num_input_digits_max == 0
					@fade_out = true if self.visible
				end
			else
				# Advance/Close message
				if Input.trigger?(Input::ACTION) || Input.trigger?(Input::CANCEL) || (Input.press?(Input::R) && $game_switches[253])
					if @text.length <= 0
						terminate_message
						@drawing_text = false
					else
						@drawing_text = true
					end
				end
			end
		end
		
	end
	
	#--------------------------------------------------------------------------
	# * Terminate Message
	#--------------------------------------------------------------------------
	def terminate_message
		$game_temp.choices = nil
		for c in @characters do 
			c.dispose
		end
		@characters = []
		
		@drawing_text = false
		
		# Call message callback
		if !@skip_message_proc && $game_temp.message_proc != nil
			$game_temp.message_proc.call
			$game_temp.message_proc = nil
		end
		
		# Clear variables related to text, choices, and number input
		$game_temp.message_text = nil
		$game_temp.message_face = nil
		if @choice_start >= 0
			$game_temp.choices = nil
			$game_temp.choice_cancel_type = 0
			$game_temp.choice_proc = nil
		elsif @number_start >= 0
			$game_temp.num_input_variable_id = 0
			$game_temp.num_input_digits_max = 0
		end
		
		reset
		
		# Reset state
		self.pause = false
		@text = nil
		@choice_start = -1
		@number_start = -1
		@skip_message_proc = false
		self.active = false
		self.pause = false
		self.index = -1
		@message_started = false
	end
	
	#--------------------------------------------------------------------------
	# * Reset
	#--------------------------------------------------------------------------
	def reset
		reset_window
		@color = Color.new(255,255,255,255)
		@face_frame = 0
		@effect = 0
		@size = 20
		@blip = BLIP_TIME
		@blipsound = "text"
		@characters = []
		@letters = {}
	end
	
	#--------------------------------------------------------------------------
	# * Reset Window
	#--------------------------------------------------------------------------
	def reset_window
		case $game_system.message_position
		when 0 # up
			self.y = @TopY
		when 1 # middle
			self.y = @MiddleY
		when 2 # down
			self.y = @BottomY
		end
		@opaque = $game_system.message_frame == 0 ? true : false
	end
	
	#--------------------------------------------------------------------------
	# * Dispose
	#--------------------------------------------------------------------------
	def dispose
		terminate_message
		$game_temp.message_window_showing = false
		if @input_number_window != nil
			@input_number_window.dispose
		end
		super
		#Graphics.transition
	end
	
	end