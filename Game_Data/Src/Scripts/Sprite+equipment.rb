#==============================================================================
# ** Sprite_Character
#------------------------------------------------------------------------------
#  This sprite is used to display the character.It observes the Game_Character
#  class and automatically changes sprite conditions.
#==============================================================================

class Sprite_Character < RPG::Sprite
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :character                # character
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     viewport  : viewport
  #     character : character (Game_Character)
  #--------------------------------------------------------------------------
  def initialize(viewport, character = nil)
    super(viewport)
    @character = character
    update
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  
  alias sprite_update update
  def update
    super
    if @character != $game_player
      sprite_update
    else
      player_update
    end
  end
  def player_update
    actor = $game_party.actors[0]
    # If tile ID, file name, or hue are different from current ones
    if @tile_id != @character.tile_id or
       @character_name != @character.character_name or
       @character_hue != @character.character_hue or
       @character_armor1 != actor.armor1_id or
       @character_armor2 != actor.armor2_id or
       @character_armor3 != actor.armor3_id or
       @character_weapon != actor.weapon_id
      
      # Remember tile ID, file name, and hue
      @tile_id = @character.tile_id
      @character_name = @character.character_name
      @character_hue = @character.character_hue
      
      # Remember ID of equipment
      @character_armor1 = actor.armor1_id
      @character_armor2 = actor.armor2_id
      @character_armor3 = actor.armor3_id
      @character_weapon = actor.weapon_id
      begin
        bitmap = Hash.new
        
          # If tile ID value is valid
        if @tile_id >= 384
          bitmap["base"] << RPG::Cache.tile($game_map.tileset_name,
            @tile_id, @character.character_hue)
          
          self.src_rect.set(0, 0, 32, 32)
          self.ox = 16
          self.oy = 32
        # If tile ID value is invalid
        else
          char_bitmap = RPG::Cache.character(@character.character_name,
            @character.character_hue)
          bitmap["base"] = char_bitmap
          @cw = char_bitmap.width / 4
          @ch = char_bitmap.height / 4
          self.bitmap = Bitmap.new(char_bitmap.width, char_bitmap.height)
          self.ox = @cw / 2
          self.oy = @ch
        end
        
        
        if @character_armor2 != 0
          bitmap["accessories"] =
            RPG::Cache.character("Garnet Slave Collar.png", 
                @character.character_hue)
        end
        if @character_weapon != 0
          bitmap["weapon"] =
            RPG::Cache.character("Garnet Sword.png", 
              @character.character_hue)
        end
        if @character_armor1 != 0
          bitmap["shield"] =
            RPG::Cache.character("Garnet Shield.png", 
                @character.character_hue)
        end
        
        draw_order = 
        {
          2 => ["base", "accessories", "shield", "weapon"], #facing down
          4 => ["weapon", "base", "accessories", "shield"], #facing left (shield in left hand)
          6 => ["shield", "base", "accessories", "weapon"], #facing right (weapon in right hand)
          8 => ["shield", "weapon", "accessories", "base"]  #facing up
        }

        draw_order[@character.direction].each do |layer_name|
          layer = bitmap[layer_name]
          if layer != nil
            rect = Rect.new(0,0,layer.width,layer.height)
            self.bitmap.blt(0,0,layer,rect)
          end
        end
      rescue Exception => e
        print e if $DEBUG
      end
    end

    # Set visible situation
    self.visible = (not @character.transparent)
    # If graphic is character
    if @tile_id == 0
      # Set rectangular transfer
      sx = @character.pattern * @cw
      sy = (@character.direction - 2) / 2 * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    end
    # Set sprite coordinates
    self.x = @character.screen_x
    self.y = @character.screen_y
    self.z = @character.screen_z(@ch)
    # Set opacity level, blend method, and bush depth
    self.opacity = @character.opacity
    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
    # Animation
    if @character.animation_id != 0
      animation = $data_animations[@character.animation_id]
      animation(animation, true)
      @character.animation_id = 0
    end
  end
end