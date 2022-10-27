#define VIEW_RANGE 9
#define ZOOM_RANGE 4

#define WHISPER_RANGE 2
#define TALK_RANGE VIEW_RANGE
#define YELL_RANGE (VIEW_RANGE + ZOOM_RANGE)

#define SOUND_RANGE (VIEW_RANGE + ZOOM_RANGE)

#define AI_DETECTION_RANGE (1 + VIEW_RANGE * 0.5)
#define AI_DETECTION_RANGE_NOISE (1 + VIEW_RANGE * 0.75)
#define AI_DETECTION_RANGE_CAUTION (1 + VIEW_RANGE)
#define AI_DETECTION_RANGE_COMBAT (1 + VIEW_RANGE + ZOOM_RANGE*0.25)

#define BOSS_RANGE (VIEW_RANGE + ZOOM_RANGE*2) //If you're out of this range, you're out of the boss fight.

#define SCREEN_SIZE (TILE_SIZE*(VIEW_RANGE*2 + 1))

#define CHUNK_SIZE (1 + VIEW_RANGE + ZOOM_RANGE)//In tiles.